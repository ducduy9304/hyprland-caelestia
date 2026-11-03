# Shortcuts

Every key and gesture on this setup, checked against `hyprctl binds` on the reference machine (Hyprland 0.57.0, Caelestia dots `7845d28`).

`Super` is the Windows key. A row marked **custom** comes from this repo's `hypr-user.lua` or `hypr-vars.lua`. Every other row is a Caelestia default.

## The ten keys to learn first

| Key | What it does |
|---|---|
| Tap `Super` | Open the app launcher (type to search) |
| `Super + T` | Terminal (Ptyxis) |
| `Super + E` | Files (Nautilus) |
| `Super + Q` | Close the window |
| `Super + F` | Maximize or restore the window, bar stays visible |
| `Super + 1` … `Super + 0` | Go to workspace 1 to 10 |
| `Super + Alt + 1` … `0` | Move the window to workspace 1 to 10 and follow it |
| `Super + Shift + S` | Screenshot: drag for a region, click for the whole screen |
| `Super + Space` | Switch English / Vietnamese (fcitx5 + Bamboo) |
| `Ctrl + Alt + Delete` | Session menu: lock, log out, reboot, shut down |

## Apps

| Key | What it does | |
|---|---|---|
| Tap `Super` | App launcher | |
| `Super + T` | Terminal (Ptyxis) | custom app |
| `Super + E` | File manager (Nautilus) | custom app |
| `Super + C` | Editor (VS Code) | custom app |
| `Ctrl + Alt + V` | Audio settings (pwvucontrol) | |
| `Ctrl + Shift + Escape` | System monitor (btop in a floating foot window) | |

`Super + W` no longer opens the browser. It changes the wallpaper (see "Look and feel").

## Windows

| Key | What it does | |
|---|---|---|
| `Super + Q` | Close window | |
| `Super + F` | Maximize / restore (bar visible) | custom, swapped |
| `Super + Alt + F` | True fullscreen (hides the bar) | custom, swapped |
| `Super + Ctrl + F` | True fullscreen (same as above, Mac-style key) | custom |
| `Super + Alt + Space` | Float / unfloat the window | |
| `Super + ←↑→↓` | Move focus to the window in that direction | |
| `Super + Shift + ←↑→↓` | Move the window that way. With two windows side by side, `Shift + ↓` stacks them top/bottom and puts this one at the bottom (same idea for the other arrows) | custom |
| `Super + Tab` | Focus the next window | custom |
| `Super + Minus` / `Super + Equal` | Make the window narrower / wider | |
| `Super + Shift + Minus` / `Super + Shift + Equal` | Make the window shorter / taller | |
| `Super + Alt + ↑↓` | Same resizing, with arrows | |
| `Super + Alt + ←→` | Move the window to the previous / next workspace | custom |
| Drag the gap between two windows | Resize both, like GNOME | custom |
| `Super + left mouse drag` | Move a window | |
| `Super + right mouse drag` | Resize a window | |
| `Ctrl + Super + \` | Center a floating window | |
| `Ctrl + Super + Alt + \` | Resize to 55 × 70 % of the screen and center | |
| `Super + Alt + \` | Picture-in-picture (small, floating, pinned) | |
| `Super + P` | Pin the window so it shows on every workspace | |

New windows open maximized (custom rule). Press `Super + F` to drop back into the tiling layout.

## Workspaces

| Key | What it does |
|---|---|
| `Super + 1` … `Super + 0` | Go to workspace 1 to 10 |
| `Super + Alt + 1` … `0` | Move the window there and follow it |
| `Super + Shift + 1` … `0` | Move the window there and stay here |
| `Ctrl + Super + ←` / `→` | Previous / next workspace |
| `Super + Page Up` / `Page Down` | Previous / next workspace |
| `Super + J` / `Super + K` | Previous / next workspace | custom |
| `Super + mouse wheel` | Scroll through workspaces |
| `Ctrl + Super + Shift + ←` / `→` | Move the window to the previous / next workspace |
| `Super + Alt + Page Up` / `Page Down` | Same, other keys |

### Special workspaces (pop-up scratch areas)

These slide over whatever you are doing and hide again with the same key.

| Key | What it does |
|---|---|
| `Super + S` | General scratch workspace |
| `Super + Alt + S` | Send the window to the scratch workspace |
| `Ctrl + Super + Shift + ↓` | Bring the window back out |
| `Super + D` | Chat workspace (Discord and similar) |
| `Super + R` | To-do workspace |

## Screenshots and recording

| Key | What it does | |
|---|---|---|
| `Super + Shift + S` | Freeze the screen, drag for a region or click for the full screen. Saves to `~/Pictures/Screenshots`, copies to the clipboard, and shows a notification. Click the notification to edit in Swappy | custom |
| `Super + Shift + R` | Start recording with sound: drag for a region or click for the full screen. Press again to stop | custom |
| `Print` | Full screenshot (Caelestia) | |
| `Super + Shift + Alt + S` | Caelestia's own region screenshot tool | |
| `Super + Alt + R` | Record full screen with sound (Caelestia) | |
| `Ctrl + Alt + R` | Record full screen without sound (Caelestia) | |
| `Super + Shift + Alt + R` | Record a region (Caelestia) | |
| `Super + Shift + C` | Color picker, copies the hex code | |

Recordings go to `~/Videos/Recordings`.

## Shell panels and system

| Key | What it does | |
|---|---|---|
| `Super + N` | Sidebar: notifications and quick settings | |
| `Super + K` | Show every panel at once | |
| `Ctrl + Alt + C` | Clear all notifications | |
| `Super + L` | Lock the screen | |
| `Super + Ctrl + Q` | Lock the screen (Mac-style key) | custom |
| `Super + Shift + L` | Sleep | |
| `Ctrl + Alt + Delete` | Session menu | |
| `Super + M` | Quit Hyprland to the login screen. Unsaved work is lost | custom |
| `Ctrl + Super + Shift + Escape` | **Emergency exit**: quits Hyprland straight to the login screen. Works even when Caelestia is frozen. Unsaved work is lost | custom |
| `Ctrl + Super + Alt + R` | Restart the Caelestia shell (fixes a frozen bar) | |
| `Ctrl + Super + Shift + R` | Kill the Caelestia shell | |
| `Super + Alt + L` | Restart the shell and lock (if the lock screen crashed) | |

## Clipboard, emoji, typing

| Key | What it does |
|---|---|
| `Super + V` | Clipboard history |
| `Super + Alt + V` | Delete an item from clipboard history |
| `Super + Period` | Emoji picker |
| `Super + Space` | English / Vietnamese (fcitx5 + Bamboo), shows an EN/VI notification |

## Media and hardware keys

| Key | What it does |
|---|---|
| Volume, mute, mic-mute, brightness keys | Work as labeled, also on the lock screen |
| `Super + Shift + M` | Mute |
| `Ctrl + Super + Space` | Play / pause |
| `Ctrl + Super + Equal` / `Minus` | Next / previous track |
| `Ctrl + Super + Backspace` | Stop |

## Look and feel

| Key or command | What it does | |
|---|---|---|
| `Super + W` | Next wallpaper from `~/Pictures/Wallpapers`, in name order | custom |
| Launcher: `>wallpaper` | Wallpaper picker with previews | |
| Launcher: `>scheme`, `>variant` | Color scheme and style | |
| Launcher: `>light`, `>dark` | Light or dark mode | |
| Launcher: `>random` | Random color scheme | |
| Launcher: `>calc 2+2` | Calculator | |
| Launcher: `>settings` | Caelestia settings | |

## Touchpad gestures

| Gesture | What it does | |
|---|---|---|
| 3 fingers left / right | Switch workspace | custom (was 4) |
| 4 fingers up | Show the scratch workspace | custom (was 3) |
| 4 fingers down | Hide the scratch workspace | custom (was 3) |
| 4 fingers pinch in | Open the app launcher, like Launchpad | custom |
| 5 fingers down | Sleep | custom (was 4, moved so it can't fire by accident) |
| 2-finger click | Right click | custom |
| 2-finger scroll | Scroll (speed set by `scroll_factor`) | |

## Changing a shortcut

Never edit files inside `~/.config/hypr/`. Caelestia updates overwrite them.

- To change a Caelestia key, override its variable in `~/.config/caelestia/hypr-vars.lua`. The full list of variable names is in `~/.config/hypr/variables.lua`. Set a key to `{}` to turn it off.
- To add a new key, put a `hl.bind(...)` line in `~/.config/caelestia/hypr-user.lua`.
- Save, then run `hyprctl reload`. A red bar at the top of the screen means a syntax error.
