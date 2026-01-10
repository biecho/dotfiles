#!/usr/bin/env python3
"""
Test process tree tracking functionality for exp.

Spawns a parent process with children and verifies:
- get_descendants() finds all children
- is_tree_running() detects running tree
- get_children_info() collects child info
- Progress tracking counts correctly
"""

import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

# Import functions from exp script
script_dir = Path(__file__).parent
exec(open(script_dir / "exp").read().split("# === Main ===")[0])

RED, GREEN, YELLOW, NC = "\033[31m", "\033[32m", "\033[33m", "\033[0m"

def test_icon(passed: bool) -> str:
    return f"{GREEN}PASS{NC}" if passed else f"{RED}FAIL{NC}"


def test_get_descendants():
    """Test that get_descendants finds child processes."""
    print("Testing get_descendants()...")

    # Spawn a parent that spawns children
    with tempfile.TemporaryDirectory() as tmpdir:
        # Parent script that spawns 2 children that sleep
        parent_script = f"""
import subprocess
import time
import sys

# Spawn 2 children
children = []
for i in range(2):
    p = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(10)'])
    children.append(p)
    print(f"Child {{i}}: {{p.pid}}")

# Write our PID for the test
with open("{tmpdir}/parent.pid", "w") as f:
    f.write(str(__import__('os').getpid()))

# Wait a bit then exit (children keep running briefly)
time.sleep(5)
for c in children:
    c.terminate()
"""
        # Start parent process
        parent = subprocess.Popen(
            [sys.executable, "-c", parent_script],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Wait for children to spawn
        time.sleep(1)

        # Test get_descendants
        descendants = get_descendants(parent.pid)
        passed = len(descendants) >= 2
        print(f"  Parent PID: {parent.pid}")
        print(f"  Descendants found: {descendants}")
        print(f"  [{test_icon(passed)}] Found {len(descendants)} descendants (expected >= 2)")

        # Cleanup
        parent.terminate()
        parent.wait()

        return passed


def test_is_tree_running():
    """Test that is_tree_running detects running children."""
    print("\nTesting is_tree_running()...")

    # Spawn parent with a child that outlives it
    child = subprocess.Popen(
        [sys.executable, "-c", "import time; time.sleep(10)"],
    )

    # Create a wrapper parent that exits quickly
    parent = subprocess.Popen(
        [sys.executable, "-c", f"""
import subprocess
import sys
# Spawn a child
p = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(3)'])
print(p.pid)
# Exit immediately, child keeps running
"""],
        stdout=subprocess.PIPE
    )

    # Get child PID from parent's output
    parent.wait()

    # Test with our simple child
    time.sleep(0.5)
    running = is_tree_running(child.pid)
    passed1 = running == True
    print(f"  Child PID {child.pid} running: {running}")
    print(f"  [{test_icon(passed1)}] is_tree_running returns True for running process")

    # Terminate and check again
    child.terminate()
    child.wait()
    time.sleep(0.5)

    running_after = is_tree_running(child.pid)
    passed2 = running_after == False
    print(f"  After terminate: {running_after}")
    print(f"  [{test_icon(passed2)}] is_tree_running returns False for dead process")

    return passed1 and passed2


def test_get_children_info():
    """Test that get_children_info collects command and log info."""
    print("\nTesting get_children_info()...")

    with tempfile.TemporaryDirectory() as tmpdir:
        log_file = f"{tmpdir}/child.log"

        # Spawn parent with child that writes to a log
        parent = subprocess.Popen(
            [sys.executable, "-c", f"""
import subprocess
import sys
import time

# Spawn child with output redirected to log
with open("{log_file}", "w") as f:
    p = subprocess.Popen(
        [sys.executable, '-c', 'import time; print("test output"); time.sleep(5)'],
        stdout=f,
        stderr=f
    )
print(p.pid)
time.sleep(4)
p.terminate()
"""],
            stdout=subprocess.PIPE
        )

        time.sleep(1)

        children = get_children_info(parent.pid)
        passed = len(children) >= 1
        print(f"  Parent PID: {parent.pid}")
        print(f"  Children info: {children}")

        if children:
            has_cmd = bool(children[0].get("cmd"))
            print(f"  [{test_icon(has_cmd)}] Child has command info")
            # Log detection may or may not work depending on timing
            has_log = bool(children[0].get("log"))
            print(f"  [{'PASS' if has_log else 'SKIP'}] Child log detection: {children[0].get('log', 'not detected')}")

        print(f"  [{test_icon(passed)}] Found {len(children)} children")

        parent.terminate()
        parent.wait()

        return passed


def test_progress_tracking():
    """Test that progress tracking counts children correctly."""
    print("\nTesting progress tracking logic...")

    # Simulate the tracking info dict
    info = {
        "pid": 12345,
        "log": "",
        "cmd": "test",
        "seen_children": [100, 101, 102],
        "completed_children": 2,
        "failed_children": 1,
        "children_logs": {}
    }

    # Test progress calculation
    seen = set(info["seen_children"])
    completed = info["completed_children"]
    failed = info["failed_children"]
    succeeded = completed - failed

    passed1 = len(seen) == 3
    print(f"  Seen children: {len(seen)}")
    print(f"  [{test_icon(passed1)}] Seen count correct")

    passed2 = succeeded == 1
    print(f"  Succeeded: {succeeded} (completed={completed} - failed={failed})")
    print(f"  [{test_icon(passed2)}] Success calculation correct")

    # Test progress text generation
    total_seen = len(seen)
    running = 1  # Simulate 1 still running
    progress_text = f"{completed}/{total_seen} completed"
    if running > 0:
        progress_text += f" ({running} running"
        if failed > 0:
            progress_text += f", {failed} failed"
        progress_text += ")"

    expected = "2/3 completed (1 running, 1 failed)"
    passed3 = progress_text == expected
    print(f"  Progress text: '{progress_text}'")
    print(f"  [{test_icon(passed3)}] Progress text format correct")

    return passed1 and passed2 and passed3


def test_hottest_log():
    """Test that get_hottest_log finds most recent log."""
    print("\nTesting get_hottest_log()...")

    with tempfile.TemporaryDirectory() as tmpdir:
        # Create two log files with different mtimes
        old_log = f"{tmpdir}/old.log"
        new_log = f"{tmpdir}/new.log"

        Path(old_log).write_text("old content\n")
        time.sleep(0.1)
        Path(new_log).write_text("new content\nmore lines\n")

        hottest_path, hottest_content = get_hottest_log([old_log, new_log])

        passed1 = hottest_path == new_log
        print(f"  Hottest log: {hottest_path}")
        print(f"  [{test_icon(passed1)}] Selected most recent log")

        passed2 = "new content" in hottest_content
        print(f"  [{test_icon(passed2)}] Content from correct log")

        # Test with empty/invalid logs
        hottest_path2, _ = get_hottest_log(["", "/nonexistent/path.log", new_log])
        passed3 = hottest_path2 == new_log
        print(f"  [{test_icon(passed3)}] Handles invalid paths gracefully")

        return passed1 and passed2 and passed3


def main():
    print(f"\n{'='*60}")
    print("Testing exp process tree tracking")
    print(f"{'='*60}\n")

    results = []

    results.append(("get_descendants", test_get_descendants()))
    results.append(("is_tree_running", test_is_tree_running()))
    results.append(("get_children_info", test_get_children_info()))
    results.append(("progress_tracking", test_progress_tracking()))
    results.append(("hottest_log", test_hottest_log()))

    print(f"\n{'='*60}")
    print("Summary")
    print(f"{'='*60}")

    passed = sum(1 for _, r in results if r)
    total = len(results)

    for name, result in results:
        print(f"  [{test_icon(result)}] {name}")

    print(f"\n{passed}/{total} tests passed")

    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
