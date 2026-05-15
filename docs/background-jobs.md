# Background Jobs

Simple utilities for running commands that survive terminal disconnection.

Unlike terminal multiplexers (tmux, screen, abduco), these don't hijack your terminal buffer - kitty scrollback, Cmd+L, and all native features keep working.

## Commands

| Command | Description |
|---------|-------------|
| `run <cmd> [args]` | Run command in background with logging |
| `runs` | List background jobs with status |
| `runlog` | View/tail logs (fzf picker if multiple) |
| `runrm` | Clean up finished job logs |

## Usage

```bash
# Start a background job
run ./build.sh
run python train.py --epochs 100
run make -j8

# Check what's running
runs
# ● build_20251205_163539 (PID: 12345) - running
# ○ train_20251205_160000 (PID: 12300) - done

# Watch the output (Ctrl+C to stop watching, job keeps running)
runlog

# Clean up finished jobs
runrm
```

## How it works

- Jobs run with `nohup` so they survive disconnection
- Logs stored in `~/.local/share/run/`
- Each job creates two files: `name_timestamp.log` and `name_timestamp.pid`
- Log includes the command, start time, and all output

## When to use

Use `run` for fire-and-forget tasks:
- Long builds
- Training ML models
- Batch processing
- Anything you want to survive SSH disconnection

For interactive sessions that need reattachment, consider tmux instead.
