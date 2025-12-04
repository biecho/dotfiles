# Custom tab bar for kitty
# Features: tab index, process name, SSH indicator, zoom indicator

from kitty.boss import get_boss
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# Tokyo Night Storm theme colors (hardcoded to avoid get_options() at load time)
BG = as_rgb(0x24283B)
FG = as_rgb(0xC0CAF5)
DIM = as_rgb(0x414868)
CYAN = as_rgb(0x7DCFFF)
ORANGE = as_rgb(0xFF9E64)
BLACK = as_rgb(0x1F2335)
# Dimmer variants for inactive tabs
DIM_CYAN = as_rgb(0x394B70)
DIM_ORANGE = as_rgb(0x4D3D2E)

# Powerline symbols
SEP = ""

# Minimum tab width (characters, excluding separators)
MIN_TAB_WIDTH = 18


def _get_proc_name(tab: TabBarData) -> str:
    """Get the foreground process name for this tab."""
    try:
        boss = get_boss()
        if boss is None:
            return ""
        tm = boss.active_tab_manager
        if tm is None:
            return ""
        kitty_tab = tm.tab_for_id(tab.tab_id)
        if kitty_tab is None:
            return ""
        active_window = kitty_tab.active_window
        if active_window is None:
            return ""
        procs = active_window.child.foreground_processes
        if procs:
            proc = sorted(procs, key=lambda p: p["pid"])[-1]
            cmdline = proc.get("cmdline", [])
            if cmdline:
                return cmdline[0].split("/")[-1]
    except Exception:
        pass
    return ""


def _get_ssh_info(tab: TabBarData) -> tuple[bool, str]:
    """Check if this tab is an SSH session and get hostname.

    Returns: (is_ssh, hostname) tuple
    """
    try:
        boss = get_boss()
        if boss is None:
            return False, ""
        tm = boss.active_tab_manager
        if tm is None:
            return False, ""
        kitty_tab = tm.tab_for_id(tab.tab_id)
        if kitty_tab is None:
            return False, ""
        active_window = kitty_tab.active_window
        if active_window is None:
            return False, ""

        # SSH kitten - parse hostname from cmdline
        ssh_cmdline = active_window.ssh_kitten_cmdline()
        if ssh_cmdline:
            # Format: ['kitten', 'ssh', 'hostname', ...]
            for i, arg in enumerate(ssh_cmdline):
                if arg == "ssh" and i + 1 < len(ssh_cmdline):
                    host = ssh_cmdline[i + 1]
                    # Strip user@ prefix if present
                    if "@" in host:
                        host = host.split("@")[-1]
                    return True, host
            return True, "remote"

        # Regular SSH - check child_is_remote
        if active_window.child_is_remote:
            # Try to get hostname from foreground processes
            procs = active_window.child.foreground_processes
            for proc in procs:
                cmdline = proc.get("cmdline", [])
                if cmdline and "ssh" in cmdline[0]:
                    # Parse hostname from ssh command
                    host = _parse_ssh_host(cmdline)
                    if host:
                        return True, host
            return True, "remote"

        # Check foreground process for ssh
        procs = active_window.child.foreground_processes
        for proc in procs:
            cmdline = proc.get("cmdline", [])
            if cmdline and "ssh" in cmdline[0]:
                host = _parse_ssh_host(cmdline)
                return True, host if host else "remote"
    except Exception:
        pass
    return False, ""


def _parse_ssh_host(cmdline: list) -> str:
    """Parse hostname from ssh command line."""
    # Skip flags and find the hostname argument
    skip_next = False
    for arg in cmdline[1:]:  # Skip 'ssh' itself
        if skip_next:
            skip_next = False
            continue
        if arg.startswith("-"):
            # Flags that take an argument
            if arg in ("-p", "-l", "-i", "-o", "-F", "-J", "-L", "-R", "-D"):
                skip_next = True
            continue
        # Found hostname (possibly user@host)
        if "@" in arg:
            return arg.split("@")[-1]
        return arg
    return ""


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw a single tab."""
    # Determine colors
    is_ssh_tab, ssh_host = _get_ssh_info(tab)
    if tab.is_active:
        fg = BLACK
        bg = CYAN if is_ssh_tab else ORANGE
    else:
        fg = FG
        bg = DIM_CYAN if is_ssh_tab else DIM_ORANGE

    # Get process name and build title
    proc = _get_proc_name(tab)
    zoom = " [Z]" if tab.layout_name == "stack" else ""

    # Build location indicator
    if is_ssh_tab:
        location = ssh_host if ssh_host else "remote"
    else:
        location = "local"

    if proc:
        title = f" {index}: {proc} ({location}){zoom} "
    else:
        title = f" {index}: {tab.title} ({location}){zoom} "

    # Pad to minimum width or truncate if needed
    max_len = max_tab_length - 2  # account for separators
    if len(title) > max_len:
        title = title[:max_len - 1] + "… "
    elif len(title) < MIN_TAB_WIDTH:
        title = title.ljust(MIN_TAB_WIDTH)

    # Draw separator from previous
    if before > 0:
        screen.cursor.fg = BG if index == 1 else DIM
        screen.cursor.bg = bg
        screen.draw(SEP)

    # Draw tab content
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.draw(title)

    # Draw separator after
    screen.cursor.fg = bg
    screen.cursor.bg = BG
    screen.draw(SEP)

    return screen.cursor.x
