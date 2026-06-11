"""tmux keybinding flashcards.

Grounded in this repo's tmux config: tmux/tmux.conf. The prefix is remapped to
the backtick (`), and the answers render the full chord (e.g. "`  h") so you
practice the whole sequence, not just the trailing key.

`source = "config"` are bindings written in tmux/tmux.conf.
`source = "builtin"` are stock tmux defaults this config leaves in place — worth
knowing, but not something you'll find in the dotfiles.

`mode` is reused as a context badge:
  - "Prefix"    — press the prefix (`) first, then the key
  - "Copy mode" — pressed while already inside copy mode (no prefix)
  - "Core"      — the prefix key itself
"""

# fmt: off
CARDS = [
    # ---- Prefix & Sessions ----
    ("Prefix & Sessions", "The tmux prefix — press it before nearly every shortcut", "`", "Core", "Remapped from the default Ctrl+b. Press it, release, then the command key.", "config"),
    ("Prefix & Sessions", "Detach from the session (leaves it running in the background)", "` d", "Prefix", "Reattach later with: tmux attach", "builtin"),
    ("Prefix & Sessions", "List & switch between sessions", "` s", "Prefix", "Interactive session tree; Enter to switch.", "builtin"),
    ("Prefix & Sessions", "Open the tmux command prompt (type a command)", "` :", "Prefix", "e.g. join-pane -s :3, swap-window -t 2, move-window -t 5", "builtin"),
    ("Prefix & Sessions", "Show every key binding (built-in help)", "` ?", "Prefix", "Press q to exit the list.", "builtin"),
    ("Prefix & Sessions", "Reload tmux.conf without restarting tmux", "` r", "Prefix", "source-file ~/.tmux.conf; flashes 'tmux.conf reloaded'. From a shell instead: tmux source-file ~/.tmux.conf", "config"),

    # ---- Splitting Panes ----
    ("Splitting Panes", "Split into two SIDE-BY-SIDE panes (new pane on the right)", "` \\", "Prefix", "split-window -h; mirrors kitty Cmd+\\. New pane keeps the current path.", "config"),
    ("Splitting Panes", "Split into two STACKED panes (new pane below)", "` -", "Prefix", "split-window -v; mirrors kitty Cmd+-. New pane keeps the current path.", "config"),

    # ---- Navigating Panes ----
    ("Navigating Panes", "Move focus to the pane on the LEFT", "` h", "Prefix", "vim-style hjkl, mirrors kitty Ctrl+HJKL", "config"),
    ("Navigating Panes", "Move focus to the pane BELOW", "` j", "Prefix", "", "config"),
    ("Navigating Panes", "Move focus to the pane ABOVE", "` k", "Prefix", "", "config"),
    ("Navigating Panes", "Move focus to the pane on the RIGHT", "` l", "Prefix", "Note: this overrides tmux's default 'last-window' on l.", "config"),

    # ---- Resizing & Zoom ----
    ("Resizing & Zoom", "Resize the current pane LEFTWARD by 5 cells (repeatable)", "` Shift+h", "Prefix", "i.e. prefix then capital H. Repeatable — keep tapping H without re-pressing the prefix.", "config"),
    ("Resizing & Zoom", "Resize the current pane DOWNWARD by 5 cells (repeatable)", "` Shift+j", "Prefix", "Capital J; repeatable.", "config"),
    ("Resizing & Zoom", "Resize the current pane UPWARD by 5 cells (repeatable)", "` Shift+k", "Prefix", "Capital K; repeatable.", "config"),
    ("Resizing & Zoom", "Resize the current pane RIGHTWARD by 5 cells (repeatable)", "` Shift+l", "Prefix", "Capital L; repeatable.", "config"),
    ("Resizing & Zoom", "Toggle ZOOM — make the current pane fill the window, then restore", "` z", "Prefix", "Like kitty Cmd+z. Great for temporarily focusing one pane.", "config"),

    # ---- Moving & Swapping Panes ----
    ("Moving & Swapping Panes", "Swap the current pane with the one to its LEFT (focus follows it)", "` Ctrl+h", "Prefix", "swap-pane -d {left-of}; mirrors nvim smart-splits move. Needs tmux >= 3.1.", "config"),
    ("Moving & Swapping Panes", "Swap the current pane with the one BELOW (focus follows it)", "` Ctrl+j", "Prefix", "swap-pane -d {down-of}", "config"),
    ("Moving & Swapping Panes", "Swap the current pane with the one ABOVE (focus follows it)", "` Ctrl+k", "Prefix", "swap-pane -d {up-of}", "config"),
    ("Moving & Swapping Panes", "Swap the current pane with the one to its RIGHT (focus follows it)", "` Ctrl+l", "Prefix", "swap-pane -d {right-of}", "config"),
    ("Moving & Swapping Panes", "Break the current pane out into its OWN new window", "` !", "Prefix", "break-pane. The reverse is join-pane via the command prompt (` :).", "builtin"),

    # ---- Windows ----
    ("Windows", "Create a new window (keeps the current path)", "` c", "Prefix", "Windows are like kitty tabs; numbering starts at 1.", "config"),
    ("Windows", "Jump to a window by its NUMBER", "` 1", "Prefix", "` 1, ` 2, … Base index is 1, and windows renumber automatically.", "builtin"),
    ("Windows", "Go to the NEXT window", "` n", "Prefix", "", "builtin"),
    ("Windows", "Go to the PREVIOUS window", "` p", "Prefix", "", "builtin"),
    ("Windows", "Rename the current window", "` ,", "Prefix", "Type the new name, then Enter.", "builtin"),

    # ---- Copy Mode ----
    ("Copy Mode", "Enter copy / scrollback mode", "` [", "Prefix", "vi keys are on: hjkl to move, / to search. Mouse scroll also enters it.", "builtin"),
    ("Copy Mode", "Paste the most recent copy buffer", "` ]", "Prefix", "", "builtin"),
    ("Copy Mode", "Start a visual selection (while in copy mode)", "v", "Copy mode", "Bound to begin-selection, vi-style.", "config"),
    ("Copy Mode", "Copy the selection and leave copy mode", "y", "Copy mode", "copy-selection-and-cancel; OSC 52 sends it to your local clipboard.", "config"),
    ("Copy Mode", "Cancel / leave copy mode", "Escape", "Copy mode", "", "config"),
]
# fmt: on
