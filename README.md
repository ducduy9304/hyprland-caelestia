# Hyprland + Caelestia, moved over from GNOME

My desktop setup: [Hyprland](https://hypr.land) (a tiling Wayland compositor) with the [Caelestia](https://github.com/caelestia-dots/shell) shell on top, installed next to GNOME on Ubuntu 26.04. GNOME stays installed as the fallback session.

This repo holds my personal config, the scripts that fill the gaps, and a runbook an AI agent can follow to rebuild the same setup on another machine.

| File | For | What's in it |
|---|---|---|
| [README.md](README.md) | People | What this is, how long it takes, how to stay safe, how to use it |
| [AGENTS.md](AGENTS.md) | Claude Code, Codex, other agents | Step-by-step install for Ubuntu, Fedora and Arch, with checks and every known problem |
| [CLAUDE.md](CLAUDE.md) | Claude Code | Points to AGENTS.md |
| [SHORTCUTS.md](SHORTCUTS.md) | People | Every key and gesture |
| `home/` | Both | Files that go into `~/` |
| `system/` | Both | Files that go into `/etc` |

## Set up another machine

1. Clone this repo on the target machine.
2. Open Claude Code or Codex inside the folder.
3. Paste this prompt:

   > Read AGENTS.md and help me move this machine from GNOME to Hyprland + Caelestia. Start with Phase 0: survey the machine and tell me which route fits before installing anything. Give me every sudo command to run myself.

The agent then inspects the machine (distro, GPU, display manager, disk), picks a route and walks through the phases, checking each one before moving on. Plan for about an hour and a few logouts.

## Will it work on my distro?

| Distro | Status |
|---|---|
| Ubuntu 26.04 | Tested. This is my machine |
| Ubuntu 24.04 | Should work: same Hyprland PPA, same Nix route. Swappy and Ptyxis need another source |
| Ubuntu 22.04 | Possible, with real trade-offs (next section). Upgrading to 24.04 first is the easier path |
| Fedora 43 to 45 | Should work with a community COPR for Hyprland (0.56) and Nix for Caelestia. Vietnamese Bamboo input needs a COPR or a source build |
| Arch | Caelestia's home distro. Use the official `caelestia install` from the AUR, then copy my overrides |

"Should work" means researched, not tested. AGENTS.md lists the exact packages and sources for each.

### Ubuntu 22.04: what you give up

Hyprland and Caelestia both run on 22.04, but nobody has tested this combination, and it costs more than on 24.04 or 26.04.

| Area | On 22.04 | On 24.04 / 26.04 |
|---|---|---|
| Hyprland version | 0.54.3, frozen. The PPA no longer supports 22.04, so no bug fixes or security updates | 0.57 and kept up to date |
| System libraries | The PPA replaces `libdrm`, `libinput`, `libxkbcommon`, `pipewire` and `qt6-wayland` with newer builds. GNOME uses them too, so a bad build can affect both sessions | The PPA only adds Hyprland's own packages |
| Caelestia's Hyprland config | Stuck on the last old-style version (commit `15d7054`, June 2026). It never gets Caelestia's later changes | Current version, updated with Caelestia |
| Caelestia shell and CLI | Current version from Nix, same as here | Same |
| My tweaks in this repo | The two `.lua` files don't load. They have to be rewritten in the old config language, and two features have no simple equivalent: `Super + Shift + arrows` re-splitting two windows, and switching GPU settings automatically in dGPU mode | Copy and use |
| Vietnamese typing | No `fcitx5-bamboo` package, and 22.04's fcitx5 (5.0.14) is too old for current Bamboo. The workarounds are fcitx5 + Bamboo from Nix, building an old Bamboo release from source, or ibus-bamboo (which crashed under Hyprland on my machine). None of them is tested | `sudo apt install fcitx5-bamboo` |
| Other apps | `cliphist`, `swappy` and `ptyxis` aren't in 22.04's archive; get them from Nix or use GNOME Terminal | In the archive (24.04 lacks `swappy` and `ptyxis`) |
| Setup time | Longer: rewriting the config and sorting out Vietnamese input are manual work | About an hour |

An upgrade to 24.04 (`sudo do-release-upgrade`, after a Timeshift snapshot) takes care of every row above, and then the tested steps apply unchanged.

## How mine was built

Ubuntu doesn't package Caelestia, and it is written for Arch. Caelestia ships a Nix flake, though, so the shell is built with Nix inside `/nix`, where it can't touch Ubuntu's own libraries. Hyprland itself comes from the [cppiber PPA](https://launchpad.net/~cppiber/+archive/ubuntu/hyprland), so it uses Ubuntu's normal GPU drivers.

The one awkward part: programs built by Nix can't find the system's graphics drivers. [nixGL](https://github.com/nix-community/nixGL) bridges that, and a small wrapper at `~/.local/bin/caelestia` makes sure every start of the shell goes through it. The wrapper picks the Mesa build (AMD/Intel) or the NVIDIA build depending on which GPU drives the screens.

| Piece | Version | Source |
|---|---|---|
| Ubuntu | 26.04.1 LTS, kernel 7.0 | |
| Hyprland | 0.57.0 | `ppa:cppiber/hyprland` |
| Caelestia shell + CLI | flake commit `fdb3e47` | `nix profile add github:caelestia-dots/cli#with-shell` |
| Caelestia Hyprland config | commit `7845d28` (2026-10-31) | `hypr/` folder of `caelestia-dots/caelestia` |
| Nix | Determinate Nix 3.24.1 | install.determinate.systems |
| GPU | AMD Radeon 680M + RTX 3050 Ti, driver 595.99.02 | |
| Vietnamese input | fcitx5 5.1.19 + Bamboo 1.0.9 | Ubuntu archive |

### Time it took

Measured on 2026-10-31.

| Step | Time |
|---|---|
| Research and plan | 20 min |
| Back up `~/.config` (8 GB) | 2 min |
| First Timeshift snapshot | 18.5 min |
| Add the PPA, install Hyprland | 5 min |
| Try bare Hyprland | 10 min |
| Install the helper apps and Nix, build Caelestia | 15 min |
| Fix OpenGL with nixGL, undo Caelestia's changes to the GNOME theme, install Caelestia's Hyprland config | 50 min |
| **Working desktop** | **about 2 hours** |
| Personal tweaks: Vietnamese input, shortcuts, screenshots, gestures, lock screen fix, dGPU mode, wallpapers | about 4 hours of active work, spread over two days |

With this repo, the problems are already solved, so a new machine should take about an hour. Most of that is waiting for the snapshot and the Nix download.

## Staying safe

Nothing in this setup replaces GNOME. Hyprland is one more entry in the login screen's session menu. Five habits keep it reversible:

1. Take a Timeshift snapshot and copy `~/.config` before installing anything. Timeshift skips `/home` by default, which is why the config copy is separate.
2. Turn GDM autologin off. With it on, the login screen never shows the gear menu, so you can't pick GNOME when Hyprland breaks.
3. Read the list before you press Y. If apt or dnf wants to remove `gdm`, `gnome-shell` or anything `nvidia`, answer no.
4. Add one layer at a time: bare Hyprland first, then the Caelestia shell started by hand, and only then the config that starts it at login.
5. Write `cli.json` before the shell's first run. It turns off Caelestia's GTK and Chromium theming, which otherwise changes GNOME's theme, icons and cursor.

If something goes wrong:

| Problem | Way out |
|---|---|
| Shell frozen, Hyprland still running | `Ctrl + Alt + Delete` for the session menu, or `Ctrl + Super + Alt + R` to restart the shell |
| Nothing responds | `Ctrl + Super + Shift + Escape` quits Hyprland to the login screen (unsaved work is lost) |
| Black screen | `Ctrl + Alt + F3`, log in, `sudo systemctl restart gdm3`, choose GNOME |
| Back to GNOME for a while | Log out, click your name, click the gear in the bottom right, choose **Ubuntu** |
| Broken system | Restore the Timeshift snapshot (from a live USB if it won't boot) |

### Updating without breaking things

- Take a snapshot before a big `apt upgrade`: `sudo timeshift --create --comments "before upgrade"`.
- Use `apt upgrade`, not `full-upgrade`, and look at the list. The packages that matter here are `hyprland`, `nvidia-*`, `linux-image-*` and `mesa`.
- Reboot after a kernel or NVIDIA update. If the NVIDIA driver version changed, run `install-nixgl-nvidia` before booting in dGPU mode.
- The shell updates separately with `nix profile upgrade with-shell`.

## Using Caelestia

If you come from GNOME, three things feel different:

- **Windows tile.** A new window splits the screen with the current one instead of floating on top. Here, new windows open maximized, and `Super + F` puts them back into the split.
- **No minimize.** Instead of hiding windows, you spread them over workspaces (`Super + 1` to `0`). Each workspace is a clean desk. The bar shows which ones have windows.
- **Keyboard first.** Almost everything has a key. You can still drag windows with `Super` held, and drag the gap between two windows to resize them.

### The parts of the shell

| Part | How to open | What it's for |
|---|---|---|
| Bar (left edge) | Always visible | Workspaces, clock, tray, network, Bluetooth, battery, power button |
| Launcher | Tap `Super`, or pinch in with 4 fingers | Search apps by name. Typing `>` lists commands: `>wallpaper`, `>scheme`, `>light`, `>dark`, `>calc`, `>settings`, `>shutdown` |
| Dashboard | Move the mouse to the middle of the top edge | Calendar, weather, media player, system usage, profile picture (`~/.face`) |
| Sidebar | `Super + N` | Notifications and quick settings |
| All panels | `Super + K` | Opens everything at once |
| Session menu | `Ctrl + Alt + Delete` | Lock, log out, reboot, shut down |
| Special workspaces | `Super + S` (scratch), `Super + D` (chat), `Super + R` (to-do), `Ctrl + Shift + Escape` (btop) | Pop-up areas that slide over what you are doing and hide with the same key |

The full key list is in [SHORTCUTS.md](SHORTCUTS.md). Learn the first table there; the rest can wait.

### GNOME habits, translated

| In GNOME you… | Here you… |
|---|---|
| Press `Super` for Activities | Tap `Super` for the launcher |
| Minimize a window | Move it to another workspace: `Super + Alt + 2` |
| Use Alt + Tab | Use `Super + Tab`, or `Super + arrows` to jump to the window on that side |
| Snap a window to half the screen | Open two windows: they split automatically. `Super + Shift + ↓` stacks them top/bottom |
| Use Settings for the touchpad | Edit the `hl.device` block in `~/.config/caelestia/hypr-user.lua`, then `hyprctl reload` |
| Take a screenshot with `Print` | `Super + Shift + S`: drag a region or click for the whole screen. Click the notification to draw on it |
| Switch input with `Super + Space` | Same key, now through fcitx5 |

### Changing settings

| What | File |
|---|---|
| Keys, default apps, gestures, borders, gaps | `~/.config/caelestia/hypr-vars.lua` (variable names in `~/.config/hypr/variables.lua`) |
| New keys, window rules, touchpad, monitors, autostart apps | `~/.config/caelestia/hypr-user.lua` |
| Bar, launcher, notifications, weather, transparency | `~/.config/caelestia/shell.json` (or `>settings` in the launcher) |
| Theme integration, special workspace commands | `~/.config/caelestia/cli.json` |
| Wallpapers | Drop images into `~/Pictures/Wallpapers`, then `Super + W` or `>wallpaper` |
| Weather city | `services.weatherLocation` in `shell.json`, as `"lat,lon"` |

After editing a Hyprland file, run `hyprctl reload`. A red bar at the top means a typo; it tells you the file and line. Never edit `~/.config/hypr/` directly: Caelestia updates replace that folder.

## What's in `home/`

| File | Purpose |
|---|---|
| `.config/caelestia/hypr-user.lua` | My Hyprland additions: env, keys, touchpad, gestures, window rules, autostart |
| `.config/caelestia/hypr-vars.lua` | Overrides for Caelestia's variables: apps, cursor, swapped keys, gesture fingers |
| `.config/caelestia/shell.json`, `shell-tokens.json` | Shell settings and a thinner bar |
| `.config/caelestia/cli.json` | Keeps Caelestia out of GNOME's theme, fixes the btop toggle |
| `.config/fcitx5/` | English + Vietnamese (Bamboo), `Super + Space` to switch |
| `.config/environment.d/90-fcitx5.conf` | Input method variables for every session |
| `.config/autostart/org.fcitx.Fcitx5.desktop` | Starts fcitx5 in the GNOME session |
| `.local/bin/caelestia` | Runs the Nix-built shell through nixGL (Mesa or NVIDIA) |
| `.local/bin/install-nixgl-nvidia` | Builds nixGLNvidia for the running driver. Run after each NVIDIA driver update |
| `.local/bin/capture` | Screenshot and screen recording for `Super + Shift + S` and `Super + Shift + R` |
| `.local/bin/notify-action` | Notification with a clickable action (Ubuntu's `notify-send` can't do it with Caelestia) |
| `.local/bin/wallpaper-next` | Next wallpaper in name order |
| `.local/bin/fcitx5-switch` | `Super + Space`: English / Vietnamese with an EN/VI notification |
| `system/etc/tmpfiles.d/nix-unix-chkpwd.conf` | Lets the Nix-built lock screen check passwords |
| `system/etc/polkit-1/rules.d/50-gsr-kms-server.rules` | Screen recording starts without a password prompt (pinned to one recorder build) |

## Reference links

Everything I looked up while building this, so you don't have to search.

### Caelestia

- Dots (Hyprland config, install notes, default keys): https://github.com/caelestia-dots/caelestia
- Shell (all `shell.json` options, wallpapers, per-monitor config): https://github.com/caelestia-dots/shell
- CLI (`cli.json`, `caelestia` commands, Nix packages): https://github.com/caelestia-dots/cli
- AUR packages: https://aur.archlinux.org/packages/caelestia-cli and https://aur.archlinux.org/packages/caelestia-shell
- Quickshell, the toolkit the shell is built on: https://quickshell.org

### Hyprland

- Wiki: https://wiki.hypr.land
- Lua config (0.55 and newer): https://wiki.hypr.land/configuring/ and the announcement https://hypr.land/news/26_lua/
- NVIDIA notes: https://wiki.hypr.land/nvidia/
- Ubuntu PPA: https://launchpad.net/~cppiber/+archive/ubuntu/hyprland (packaging source: https://github.com/cpiber/hyprland-ppa)
- Fedora COPR: https://copr.fedorainfracloud.org/coprs/sdegler/hyprland/ (status thread: https://discussion.fedoraproject.org/t/sdegler-hyprland/173920)
- Arch package: https://archlinux.org/packages/extra/x86_64/hyprland/

### Nix

- Determinate Nix installer: https://github.com/DeterminateSystems/nix-installer
- nixGL: https://github.com/nix-community/nixGL

### Vietnamese input

- fcitx5 on Wayland (GNOME, KDE, wlroots): https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
- fcitx5-bamboo: https://github.com/fcitx/fcitx5-bamboo

### Tools

- Timeshift: https://github.com/linuxmint/timeshift
- grim and slurp (screenshot and region picker): https://gitlab.freedesktop.org/emersion/grim and https://github.com/emersion/slurp
- Swappy (screenshot editor): https://github.com/jtheoof/swappy
