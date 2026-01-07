# Background Jobs

Simple utilities for running commands that survive terminal disconnection.

Unlike terminal multiplexers (tmux, screen, abduco), these don't hijack your terminal buffer - kitty scrollback, Cmd+L, and all native features keep working.

## Commands

| Command | Description |
|---------|-------------|
| `run <cmd> [args]` | Run command in background with logging |
| `run -n <cmd>` | Run with ntfy notification on completion |
| `run -n <topic> <cmd>` | Run with notification to specific topic |
| `runs` | List background jobs with status |
| `runlog` | View/tail logs (fzf picker if multiple) |
| `runrm` | Clean up finished job logs |

## Usage

```bash
# Start a background job
run ./build.sh
run python train.py --epochs 100
run make -j8

# With push notification on completion
run -n my-topic python train.py --epochs 100
run -n ./long-build.sh              # uses $NTFY_TOPIC

# Check what's running
runs
# ● build_20251205_163539 (PID: 12345) - running
# ○ train_20251205_160000 (PID: 12300) - done

# Watch the output (Ctrl+C to stop watching, job keeps running)
runlog

# Clean up finished jobs
runrm
```

## Notifications

Set a default topic to avoid typing it each time:

```bash
export NTFY_TOPIC="my-notifications"  # add to .zshrc

# Then just use -n flag
run -n python train.py
```

Notifications include:
- Success/failure status with emoji
- Command name (truncated if long)
- Duration (e.g., "2h 15m" or "45s")

## How it works

- Jobs run with `nohup` so they survive disconnection
- Logs stored in `~/.local/share/run/`
- Each job creates two files: `name_timestamp.log` and `name_timestamp.pid`
- Log includes the command, start time, and all output
- With `-n`: spawns a watcher process that sends ntfy notification on completion

## When to use

Use `run` for fire-and-forget tasks:
- Long builds
- Training ML models
- Batch processing
- Anything you want to survive SSH disconnection

For interactive sessions that need reattachment, consider tmux instead.
