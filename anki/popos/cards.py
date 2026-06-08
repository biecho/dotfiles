"""Pop!_OS (COSMIC desktop) keybinding flashcards.

Grounded in the authoritative COSMIC config on this machine:
  - defaults: /usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/defaults
  - overrides: ~/.config/cosmic/.../v1/custom  (tracked in this repo under cosmic/)

`source = "cosmic"` are COSMIC defaults that are ACTIVE on this setup.
`source = "custom"` are this repo's overrides — keys disabled (freed for kitty's
Super/Cmd bindings) or remapped. Those teach what changed vs. stock Pop!_OS.

`mode` is reused as a scope badge: "COSMIC" (default) or "Custom" (override).
"""

# fmt: off
CARDS = [
    # ---- Tiling & Layout ----
    ("Tiling & Layout", "Toggle auto-tiling on/off (the core 'tile windows' switch)", "Super+Y", "COSMIC", "When on, windows auto-arrange instead of floating", "cosmic"),
    ("Tiling & Layout", "Toggle floating for the focused window", "Super+G", "COSMIC", "Pop one window out of the tiling grid", "cosmic"),
    ("Tiling & Layout", "Swap the focused window with another", "Super+X", "COSMIC", "Then pick the target window", "cosmic"),
    ("Tiling & Layout", "Maximize the focused window", "Super+M", "COSMIC", "", "cosmic"),
    ("Tiling & Layout", "Fullscreen the focused window", "Super+F11", "COSMIC", "", "cosmic"),
    ("Tiling & Layout", "Enter resize mode (shrink)", "Super+Shift+R", "COSMIC", "Grow (Super+R) is disabled in your config — freed for kitty", "cosmic"),
    ("Tiling & Layout", "Toggle split orientation (horizontal/vertical)", "Super+O", "Custom", "DISABLED in your config (freed for kitty file picker) — no active key", "custom"),
    ("Tiling & Layout", "Toggle window stacking", "Super+S", "Custom", "DISABLED in your config (freed for kitty save) — no active key", "custom"),

    # ---- Focus & Move Windows ----
    ("Focus & Move Windows", "Focus the window to the left", "Super+Left", "COSMIC", "Super+H also works", "cosmic"),
    ("Focus & Move Windows", "Focus the window to the right", "Super+Right", "COSMIC", "Super+L is disabled in your config — use the arrow", "cosmic"),
    ("Focus & Move Windows", "Focus the window above", "Super+Up", "COSMIC", "Super+K also works", "cosmic"),
    ("Focus & Move Windows", "Focus the window below", "Super+Down", "COSMIC", "Super+J also works", "cosmic"),
    ("Focus & Move Windows", "Move the focused window left", "Super+Shift+Left", "COSMIC", "Super+Shift+H is disabled in your config — use the arrow", "cosmic"),
    ("Focus & Move Windows", "Move the focused window right", "Super+Shift+Right", "COSMIC", "Super+Shift+L also works", "cosmic"),
    ("Focus & Move Windows", "Move the focused window up", "Super+Shift+Up", "COSMIC", "Super+Shift+K also works", "cosmic"),
    ("Focus & Move Windows", "Move the focused window down", "Super+Shift+Down", "COSMIC", "Super+Shift+J also works", "cosmic"),
    ("Focus & Move Windows", "Window switcher (Alt-Tab style)", "Alt+Tab", "COSMIC", "Super+Tab also works; reverse with Alt+Shift+Tab", "cosmic"),

    # ---- Workspaces & Monitors ----
    ("Workspaces & Monitors", "Switch to next workspace", "Super+Ctrl+Down", "COSMIC", "Super+Ctrl+Right / J also work", "cosmic"),
    ("Workspaces & Monitors", "Switch to previous workspace", "Super+Ctrl+Up", "COSMIC", "Super+Ctrl+Left / K also work", "cosmic"),
    ("Workspaces & Monitors", "Move window to next workspace", "Super+Ctrl+Shift+Down", "COSMIC", "", "cosmic"),
    ("Workspaces & Monitors", "Move window to previous workspace", "Super+Ctrl+Shift+Up", "COSMIC", "", "cosmic"),
    ("Workspaces & Monitors", "Jump to last-used workspace", "Super+0", "COSMIC", "", "cosmic"),
    ("Workspaces & Monitors", "Jump directly to workspace 1–9", "Super+1", "Custom", "DISABLED in your config (Super+1..9 freed for kitty tabs)", "custom"),
    ("Workspaces & Monitors", "Focus the next monitor (direction)", "Super+Alt+Right", "COSMIC", "Any Super+Alt+Arrow / hjkl", "cosmic"),
    ("Workspaces & Monitors", "Move window to the next monitor (direction)", "Super+Shift+Alt+Right", "COSMIC", "Any Super+Shift+Alt+Arrow / hjkl", "cosmic"),

    # ---- Apps & System ----
    ("Apps & System", "Open the Launcher (run / search)", "Super+/", "COSMIC", "Also Super+Space in your config", "cosmic"),
    ("Apps & System", "Open the Launcher (your macOS-style binding)", "Super+Space", "Custom", "Your override; COSMIC default here was input-source switch", "custom"),
    ("Apps & System", "Open the App Library", "Super+A", "COSMIC", "", "cosmic"),
    ("Apps & System", "Close the focused window", "Super+Q", "COSMIC", "Alt+F4 also works", "cosmic"),
    ("Apps & System", "Lock the screen", "Super+Escape", "COSMIC", "", "cosmic"),
    ("Apps & System", "Log out", "Super+Shift+Escape", "COSMIC", "", "cosmic"),
    ("Apps & System", "Force-quit the focused app", "Super+Alt+Escape", "COSMIC", "", "cosmic"),
    ("Apps & System", "Take a screenshot", "Print", "COSMIC", "", "cosmic"),
    ("Apps & System", "Open the home folder (file manager)", "Super+F", "COSMIC", "", "cosmic"),
    ("Apps & System", "Open the web browser", "Super+B", "COSMIC", "", "cosmic"),
    ("Apps & System", "Zoom out", "Super+,", "COSMIC", "Super+- (ZoomOut) is disabled — freed for kitty hsplit", "cosmic"),
    ("Apps & System", "Zoom in", "Super+=", "COSMIC", "Super+. also works", "cosmic"),

    # ---- My Customizations (what differs from stock Pop!_OS) ----
    ("My Customizations", "Bare Super tap (released alone)", "Super", "Custom", "Disabled so the Launcher bar doesn't pop on every Super release", "custom"),
    ("My Customizations", "Open a terminal (COSMIC default)", "Super+T", "Custom", "DISABLED — you launch kitty; Super+T is freed for kitty new-tab", "custom"),
    ("My Customizations", "Workspace overview (COSMIC default)", "Super+W", "Custom", "DISABLED — Super+W is freed for kitty close-window", "custom"),
    ("My Customizations", "Copy / paste at desktop level", "Super+C", "Custom", "Super+C/Super+V freed so kitty gets macOS-style Cmd+C/Cmd+V", "custom"),
]
# fmt: on
