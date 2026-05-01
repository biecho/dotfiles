# Rectangle Cheatsheet

Custom vim-style (HJKL) bindings. All shortcuts use Option as the base modifier.

## Halves (Option)

| Shortcut      | Action      |
| ------------- | ----------- |
| `Opt + H`     | Left half   |
| `Opt + L`     | Right half  |
| `Opt + K`     | Top half    |
| `Opt + J`     | Bottom half |

## Sizing (Option)

| Shortcut       | Action   |
| -------------- | -------- |
| `Opt + Return` | Maximize |
| `Opt + C`      | Center   |

## Resize (Shift + Option)

| Shortcut          | Action            |
| ----------------- | ----------------- |
| `Shift+Opt + =`   | Make larger       |
| `Shift+Opt + -`   | Make smaller      |
| `Shift+Opt + \`   | Restore prev size |

## Displays (Shift + Option)

| Shortcut        | Action          |
| --------------- | --------------- |
| `Shift+Opt + L` | Next display    |
| `Shift+Opt + H` | Previous display|

## Todo mode (Ctrl + Option)

| Shortcut       | Action       |
| -------------- | ------------ |
| `Ctrl+Opt + B` | Toggle todo  |
| `Ctrl+Opt + N` | Reflow todo  |

## Notes

- Config lives in `com.knollsoft.Rectangle` prefs (not tracked in dotfiles).
- Export/dump: `defaults read com.knollsoft.Rectangle`
- Import back: `defaults import com.knollsoft.Rectangle <file>`
