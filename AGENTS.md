# Agent runbook: GNOME to Hyprland + Caelestia

You are an AI coding agent (Claude Code, Codex or similar) helping a person move a GNOME desktop to Hyprland with the Caelestia shell, using the configs in this repo. Read this whole file before running anything. [README.md](README.md) explains the setup for humans, and [SHORTCUTS.md](SHORTCUTS.md) lists every key.

The reference machine where all of this was built and tested:

| | |
|---|---|
| Distro | Ubuntu 26.04.1 LTS, kernel 7.0, GDM, GNOME 50 |
| Hardware | Lenovo Legion laptop, AMD Radeon 680M iGPU + NVIDIA RTX 3050 Ti (MUX switch), NVIDIA driver 595.99.02 (open kernel module) |
| Hyprland | 0.57.0 from `ppa:cppiber/hyprland`, Lua config |
| Caelestia | shell + CLI from Nix, built from this repo's flake (`home/.config/caelestia/nix`: `caelestia-dots/cli` pinned at `fdb3e47` plus six shell patches), dots `hypr/` folder from `caelestia-dots/caelestia` at `7845d28` (2026-10-31) |
| Nix | Determinate Nix 3.24.1 (Nix 2.35.3), plus `nixGLIntel` and `nixGLNvidia` from `github:nix-community/nixGL` |

Only Ubuntu 26.04 is tested. Every other distro below is researched but untested, so check package names with the package manager before you run an install line.

## Hard rules

1. Keep GNOME. Never remove `gdm`/`gdm3`, `gnome-shell` or `ubuntu-desktop`. GNOME is the fallback session if Hyprland breaks.
2. Make the safety net (Phase 1) before installing anything, and confirm the snapshot finished.
3. Do not run `sudo` commands without the person's go-ahead. If your sandbox blocks `sudo`, give the exact command in its own code block and wait for the output.
4. Before any install that could remove packages, have the person read the "will be REMOVED" list. If it contains `gdm`, `gnome-shell`, `nvidia-*`, `mesa` or a kernel package, stop and investigate.
5. Never edit files inside `~/.config/hypr/`. Caelestia updates overwrite them. Personal changes go in `~/.config/caelestia/hypr-user.lua` and `hypr-vars.lua`.
6. Do not copy machine-specific values blindly (see "Adapt these values"). Device names, GPU logic, apps and the weather location come from the reference machine.
7. Go one phase at a time, run its check, and stop on the first failure. Do not stack fixes on top of an unverified step.
8. Never type, store or echo the person's password. The lock screen and `sudo` prompts are for them.

## Phase 0: survey the machine

Run these and summarize the results for the person before you choose a route.

```bash
cat /etc/os-release; uname -r
echo "$XDG_CURRENT_DESKTOP $XDG_SESSION_TYPE"
lspci -nnk | grep -A3 -E 'VGA|3D|Display'
cat /sys/module/nvidia/version 2>/dev/null; cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null
for s in /sys/class/drm/card*-*/status; do echo "$s $(cat $s)"; done
df -h / /home; findmnt -no FSTYPE /
systemctl status display-manager --no-pager | head -3
grep -i autologin /etc/gdm3/custom.conf /etc/gdm/custom.conf 2>/dev/null
ls ~/.config/hypr ~/.config/caelestia 2>&1
pgrep -a 'ibus|fcitx'
command -v nix git jq curl timeshift
```

What to note:

- Distro and version decide the route (table below).
- GPU: Intel or AMD only, NVIDIA only (most desktop PCs), or hybrid. On hybrid laptops, check which GPU drives the built-in panel by looking at which `cardN` has `eDP-*` connected.
- NVIDIA needs `nvidia_drm modeset` = `Y` and driver 555 or newer for Hyprland. Read the [Hyprland NVIDIA page](https://wiki.hypr.land/nvidia/) if anything there is off.
- At least 15 GB free on `/` for the snapshot and Nix store.
- A Btrfs root on Fedora: Timeshift's Btrfs mode only supports Ubuntu-style `@`/`@home` subvolumes, so use Timeshift in rsync mode or Snapper.
- An existing `~/.config/hypr` gets moved aside, not deleted.

## Choose a route

| Distro | Hyprland from | Version (Nov 2026) | Caelestia from | Status |
|---|---|---|---|---|
| Ubuntu 26.04 | `ppa:cppiber/hyprland` | 0.57.0 | Nix + nixGL (route A) | Tested |
| Ubuntu 24.04 | `ppa:cppiber/hyprland` | 0.57.0 | Nix + nixGL (route A) | Untested. `swappy` and `ptyxis` are not in the 24.04 archive |
| Ubuntu 22.04 | `ppa:cppiber/hyprland`, frozen | 0.54.3 (old hyprlang config, no more updates) | Nix + nixGL, with the last hyprlang version of the dots (route C) | Possible but untested, and this repo's Lua files do not apply. Upgrading to 24.04 first is simpler. See "Ubuntu 22.04 (route C)" |
| Fedora 43 to 45 | COPR `sdegler/hyprland` | 0.56.2 | Nix + nixGL (route A) | Untested. Fedora's own `hyprland` package stopped at 0.45 on Fedora 42 |
| Arch | official `extra` repo | 0.57.0 | AUR `caelestia-cli`, then `caelestia install` (route B, upstream's official way) | Untested here, but it is the path Caelestia is built for |

Caelestia's dots switched to a Lua Hyprland config, which needs Hyprland 0.55 or newer. They were tested here on 0.57. On Fedora's 0.56.2, check `hyprctl configerrors` after Phase 5. If the latest dots error out, check out an older commit of `caelestia-dots/caelestia` from around the release date of the installed Hyprland.

Route A (Nix) builds the shell in `/nix`, so it never touches the distro's Qt or libraries. The catch is that Nix programs cannot find the host's GPU drivers on their own. nixGL fixes that, and several of the fixes in "Known problems" exist because of it.

### Ubuntu 22.04 (route C)

Researched in Nov 2026, not tested. Offer the person an upgrade to 24.04 first (`sudo do-release-upgrade`, after the Phase 1 snapshot), because 24.04 runs route A unchanged.

Before they decide, tell them what staying on 22.04 costs (the same list is in README.md, "Ubuntu 22.04: what you give up"):

1. Hyprland stays at 0.54.3 with no more updates, including security fixes.
2. The PPA replaces system libraries that GNOME also uses (`libdrm`, `libinput`, `libxkbcommon`, `pipewire`, `qt6-wayland`).
3. Caelestia's Hyprland config is frozen at the last old-style version and never gets upstream changes.
4. This repo's `hypr-user.lua` and `hypr-vars.lua` don't apply. They must be rewritten in hyprlang, and the `move_or_split` arrows and the dGPU auto-detection are dropped or turned into scripts.
5. Vietnamese Bamboo input has no package and only untested workarounds.
6. `cliphist`, `swappy` and `ptyxis` come from Nix or get replaced.
7. Setup takes longer than the one hour quoted for 24.04 and 26.04.

Continue on 22.04 only if they accept that list. Then it can work this way:

- Hyprland: The cppiber PPA still publishes 0.54.3 for jammy but no longer lists jammy as supported, so there will be no further updates. On jammy the PPA also replaces several system libraries with newer builds (`libdrm`, `libinput`, `libxkbcommon`, `pipewire`, `qt6-wayland`). GNOME uses those too, so read the apt list carefully. `ppa-purge` rolls them back. Building a newer Hyprland from source is not realistic on jammy's GCC 11/12 toolchain.
- Shell and CLI: Install them from Nix exactly as in route A. Since June 2026 (shell commit `7f358235`, CLI `b9a442d`) both detect whether Hyprland runs a Lua or a hyprlang config and send the matching dispatch syntax, so the current versions work with 0.54.
- Hyprland config: The current dots are Lua only and need 0.55 or newer. Use the last hyprlang version instead, commit `15d7054` of `caelestia-dots/caelestia` (the parent of the Lua switch `593c8b0`, 2026-06-19). It uses the 0.53+ `windowrule ... match:` syntax and the scrolling layout that became built in with 0.54, so it should match 0.54.3. In Phase 5, run `git checkout 15d7054` before copying `hypr/`. This frozen copy never gets updates, so editing it directly is acceptable.
- Extra packages for those old dots: `fish` (its helper scripts are fish), `policykit-1-gnome`, `geoclue-2.0`, `bluez` (for `mpris-proxy`), `gnome-keyring`. The dots start polkit from `/usr/lib/polkit-gnome/`, but Ubuntu installs it under `/usr/lib/policykit-1-gnome/`, so add the right `exec-once` line to `hypr-user.conf` (or use the PPA's `hyprpolkitagent`).
- This repo's overrides: Old dots read `~/.config/caelestia/hypr-user.conf` and `hypr-vars.conf` in hyprlang, not the `.lua` files. Translate them by hand: env variables, binds, touchpad `device` blocks, `windowrule = maximize true, match:float false`, gestures, `exec-once` lines. Skip what has no simple hyprlang form, such as the `move_or_split` function and the dGPU detection, or turn them into shell scripts. Note that 0.54 removed the `togglesplit` dispatcher; use `layoutmsg, togglesplit` instead. `shell.json`, `cli.json`, the fcitx5 files and the `~/.local/bin` scripts apply unchanged.
- Missing apt packages: The PPA ships `fuzzel` for jammy. Get `cliphist`, `swappy` and `ptyxis` from Nix (`nix profile add nixpkgs#cliphist nixpkgs#swappy`) or use GNOME Terminal.
- Vietnamese input: Jammy has fcitx5 5.0.14 and no `fcitx5-bamboo`. Current fcitx5-bamboo needs fcitx5 5.1.13. Options, all untested: (1) fcitx5 with Bamboo from Nix, e.g. `nix profile add --impure --expr 'let p = (builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux; in p.qt6Packages.fcitx5-with-addons.override { addons = [ p.fcitx5-bamboo ]; }'`, removing the apt `fcitx5` so only one runs; (2) build fcitx5-bamboo tag `1.0.3` or older from source against jammy's fcitx5 (those tags declare no minimum version; needs Go and `fcitx5-modules-dev`); (3) `ppa:bamboo-engine/ibus-bamboo`, which still builds for jammy, but ibus-bamboo crashed under Hyprland on the reference machine.

## Phase 1: safety net

Back up `~/.config`. It is usually a few GB and takes a couple of minutes.

```bash
rsync -a ~/.config/ ~/config-backup-$(date +%F)/
```

Take a system snapshot. Ask the person to run it. The first rsync snapshot took 18.5 minutes on the reference machine. By default Timeshift does not include `/home`, which is why the `~/.config` backup above exists.

```bash
sudo apt install -y timeshift        # dnf install timeshift / pacman -S timeshift
sudo timeshift --create --rsync --comments "before hyprland"
sudo timeshift --list
```

Look for `Snapshot saved successfully`. A trailing `status: No such file or directory` line after that is harmless; it comes from a post-snapshot hook script.

Turn off GDM autologin. With autologin on, GDM never shows the session picker (the gear icon), so the person has no way to choose GNOME if Hyprland fails.

```bash
sudo sed -i 's/^AutomaticLoginEnable=true/AutomaticLoginEnable=false/' /etc/gdm3/custom.conf   # /etc/gdm/custom.conf on Fedora and Arch
```

Tell the person the escape hatches before their first Hyprland login:

| Situation | What to do |
|---|---|
| Hyprland runs but the shell is broken | `Ctrl + Super + Shift + Escape` (after Phase 6) or `Super + M` (bare Hyprland) quits to the login screen |
| Black screen or frozen | `Ctrl + Alt + F3`, log in, `sudo systemctl restart gdm3` (`gdm` on Fedora and Arch), pick GNOME |
| Login screen has no gear | Click the user name first; the gear shows in the bottom right corner. Autologin must be off |
| System will not boot | Boot a live USB, install Timeshift there, restore the "before hyprland" snapshot |

## Phase 2: install Hyprland

### Ubuntu 24.04 and 26.04

```bash
sudo apt install -y ppa-purge
sudo add-apt-repository -y ppa:cppiber/hyprland
sudo apt update
apt-cache policy hyprland            # Candidate must come from the PPA, version 0.57 or newer
sudo apt install hyprland xdg-desktop-portal-hyprland hyprlock hypridle hyprpicker hyprpolkitagent kitty
```

Leave `-y` off the last line so the person reads the REMOVED list. `apt update` errors about unrelated old repos (for example a removed CUDA local repo) do not block this; clean them up separately.

### Fedora

```bash
sudo dnf copr enable sdegler/hyprland
sudo dnf install hyprland xdg-desktop-portal-hyprland hyprlock hypridle hyprpicker hyprpolkitagent kitty
```

Check which of those the COPR actually ships (`dnf repoquery --repo='copr:*sdegler*'`). Community COPRs change owners often. See [the Fedora discussion thread](https://discussion.fedoraproject.org/t/sdegler-hyprland/173920) for the current state.

### Arch

```bash
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprlock hypridle hyprpicker hyprpolkitagent kitty
```

Check: `/usr/share/wayland-sessions/` now has a `hyprland.desktop`, and `gdm`/`gnome-shell` are still installed.

## Phase 3: try bare Hyprland

Do this before Caelestia, so a later problem can be blamed on the right layer. The default config uses kitty as the terminal, which is why kitty was installed.

1. The person saves their work and logs out.
2. At the login screen: click the user, click the gear, pick **Hyprland** (not the uwsm variant), log in.
3. Expect a wallpaper and a yellow warning bar about an autogenerated config.
4. `Super + Q` opens kitty, `Super + 1/2/3` switches workspaces, `Super + M` exits.

If that works, go back to GNOME for the next phases. Everything up to Phase 5 can be done from GNOME.

## Phase 4: install Caelestia

### Route A (Ubuntu, Fedora): Nix

Install the apps Caelestia calls, plus everything this repo's configs use.

Ubuntu 26.04 (the exact list used on the reference machine):

```bash
sudo apt install -y foot thunar fuzzel cliphist gammastep trash-cli fonts-jetbrains-mono brightnessctl \
  grim slurp swappy wl-clipboard libnotify-bin python3-gi jq btop git nautilus ptyxis \
  xdg-desktop-portal-gtk gnome-keyring papirus-icon-theme wdisplays
```

The configs also call three apps that come from their vendors' own apt repos, not Ubuntu's: `brave-browser` (brave.com/linux), `code` (VS Code, packages.microsoft.com) and `netbird-ui` (netbird.io). Install the ones the person uses and adapt the rest (see "Adapt these values").

Ubuntu 24.04: drop `swappy` and `ptyxis` from that line. Install swappy with `nix profile add nixpkgs#swappy` after Nix is in, and keep `gnome-terminal` (or install Ptyxis from Flathub as `app.devsuite.Ptyxis`), then change `terminal` in `hypr-vars.lua` and `general.apps.terminal` in `shell.json` to match.

Fedora (names researched, not tested):

```bash
sudo dnf install foot thunar fuzzel cliphist gammastep trash-cli jetbrains-mono-fonts brightnessctl \
  grim slurp swappy wl-clipboard libnotify python3-gobject jq btop git nautilus ptyxis \
  xdg-desktop-portal-gtk gnome-keyring papirus-icon-theme wdisplays
```

Install Nix with the Determinate installer. It asks for confirmation and the `sudo` password, keeps everything under `/nix`, supports SELinux on Fedora, and can be removed later with `/nix/nix-installer uninstall`.

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal so `nix` is on PATH. Before the shell runs for the first time, write `cli.json`. Without it, Caelestia rewrites GNOME's GTK theme, icon theme, cursor and `gtk.css` files, and GNOME starts complaining about missing themes.

```bash
mkdir -p ~/.config/caelestia
cp <this-repo>/home/.config/caelestia/cli.json ~/.config/caelestia/
```

Then install the shell, the CLI and the Mesa wrapper. The shell comes from the flake in `home/.config/caelestia/nix`: upstream `caelestia-dots/cli#with-shell` pinned by `flake.lock`, plus six patches. `workspace-attention.patch` makes the bar flash a workspace when a launched app only focused a window that was already open there. `bar-clock.patch` turns the bar clock into a small analog face under the date and, when it is clicked, opens a small popout beside the bar with a big analog clock and this month's calendar (reusing the dashboard's calendar). `bar-app-name.patch` shows the focused app's name under the clock instead of the full window title. `notif-icon.patch` makes notifications whose icon is a `file://` URL or a name missing from the icon theme (Claude desktop, for one) show the app's icon instead of a pink and black square. `hover-click.patch` stops panels from opening on a passing pointer: the volume and brightness OSD on the right only opens from the keys, the dashboard (top), utilities (bottom right) and session menu (right edge: log out, shut down, hibernate, reboot) open after the pointer rests on their edge for half a second, and the bar's status icon and focused app popouts open on click instead of hover (tray menus still open on hover). `bt-pairing.patch` lets the "Pair new device" page of the Bluetooth panel actually keep a pairing: BlueZ leaves the adapter non-pairable when no pairing agent is running (GNOME runs one, Hyprland does not), so a device paired without bonding and was forgotten again. The page now turns Pairable on while it is open and marks a newly paired device as trusted so it can reconnect on its own. Devices that need a PIN or a passkey confirmation still need an agent, for example `bluetoothctl` in a terminal. Nix remembers the path, so keep the clone where it is. The first build downloads Qt and Quickshell and took about 10 minutes on the reference machine.

```bash
nix profile add path:<this-repo>/home/.config/caelestia/nix
nix profile add github:nix-community/nixGL#nixGLIntel
```

`which caelestia` only finds `caelestia`, not `caelestia-shell`. That is expected; the CLI calls the shell internally. `nixGLIntel` is the generic Mesa wrapper and works for AMD and Intel GPUs.

Install the wrapper that makes every `caelestia` call go through nixGL, and create the `unix_chkpwd` path that Nix's PAM expects (without it, the lock screen rejects the correct password):

```bash
mkdir -p ~/.local/bin
install -m 755 <this-repo>/home/.local/bin/caelestia <this-repo>/home/.local/bin/install-nixgl-nvidia ~/.local/bin/
command -v unix_chkpwd || ls /usr/sbin/unix_chkpwd /usr/bin/unix_chkpwd
```

Edit the target path in `system/etc/tmpfiles.d/nix-unix-chkpwd.conf` if `unix_chkpwd` is not at `/usr/sbin/unix_chkpwd`, then have the person run:

```bash
sudo cp <this-repo>/system/etc/tmpfiles.d/nix-unix-chkpwd.conf /etc/tmpfiles.d/
sudo systemd-tmpfiles --create /etc/tmpfiles.d/nix-unix-chkpwd.conf
ls -l /run/wrappers/bin/unix_chkpwd
```

NVIDIA-only machines (and hybrid laptops booted in dGPU mode) need `nixGLNvidia` built for the exact running driver version. nixGL cannot parse the version string of NVIDIA's open kernel module, so the script passes it explicitly. Run it again after every NVIDIA driver update:

```bash
~/.local/bin/install-nixgl-nvidia
```

The `~/.local/bin/caelestia` wrapper picks `nixGLNvidia-<version>` when every connected screen sits on an NVIDIA GPU, and `nixGLIntel` otherwise. If the matching build is missing, it shows a notification asking for `install-nixgl-nvidia`.

### Route B (Arch): AUR

```bash
paru -S caelestia-cli      # or yay
caelestia install
```

`caelestia install` pulls the shell, the packages from the dots' `manifest.toml` and copies the configs, including `~/.config/hypr`. Skip Phase 5. Do not install `~/.local/bin/caelestia`, `install-nixgl-nvidia` or the `unix_chkpwd` tmpfiles entry: they exist only for the Nix route and would break the native install. Do write `cli.json` before `caelestia install` if the person wants GNOME's theme left alone.

### Check

Log into Hyprland, open kitty with `Super + Q`, and run `caelestia shell`. A vertical bar on the left means it works. `WARN` lines are harmless. An error mentioning `OpenGL`, `EGL` or `GLX` means the nixGL wrapper is not being used. Stop with `Ctrl + C`, leave with `Super + M`.

## Phase 5: Caelestia's Hyprland config (route A only)

```bash
git clone https://github.com/caelestia-dots/caelestia.git /tmp/caelestia-dots
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr.bak-$(date +%F)
mkdir -p ~/.config/hypr
cp -r /tmp/caelestia-dots/hypr/. ~/.config/hypr/
[ -f ~/.config/hypr/scheme/current.lua ] || caelestia scheme set -n caelestia
```

For the exact tested version, run `git -C /tmp/caelestia-dots checkout 7845d28` before copying.

The reference machine uses the dynamic scheme, which takes its colours from the wallpaper, so they change with every `Super + W`. It is stored in `~/.local/state/caelestia`, not in a config file, so set it by hand: `caelestia scheme set -n dynamic -m dark -v tonalspot`. `caelestia scheme list` shows the fixed schemes (nord, everforest, gruvbox and others).

From now on, the next Hyprland login starts the shell automatically and the keys change to Caelestia's: `Super + Q` closes windows, `Super + T` is the terminal, a tap on `Super` opens the launcher.

## Phase 6: apply this repo's configs

Copy everything, then adapt the values in the next table.

```bash
cp -r <this-repo>/home/.config/. ~/.config/
install -m 755 <this-repo>/home/.local/bin/* ~/.local/bin/     # route B: skip caelestia and install-nixgl-nvidia
cp -r <this-repo>/home/.local/share/. ~/.local/share/
mkdir -p ~/Pictures/Wallpapers ~/Pictures/Screenshots
hyprctl reload; hyprctl configerrors
```

The reference machine links the files instead of copying them, so edits land in the repo and can be committed. To do the same, use an absolute repo path (fcitx5 rewrites its `profile` on exit, which turns that one link back into a plain file; that is harmless):

```bash
cp -rs --remove-destination /abs/path/to/repo/home/.config/. ~/.config/
cp -rs --remove-destination /abs/path/to/repo/home/.local/bin/. ~/.local/bin/
cp -rs --remove-destination /abs/path/to/repo/home/.local/share/. ~/.local/share/
```

Two things are per machine and stay out of the repo: `~/.config/hypr/monitors.lua` (saved monitor layout, see the wdisplays row below) and the images in `~/Pictures/Wallpapers`. On a reinstall of the same machine, copy them over from the backup.

Route A only: let screen recording start without a password prompt. The rule allows one exact `gsr-kms-server` store path, which comes from the pinned flake, so it matches as long as `flake.lock` is unchanged:

```bash
sudo install -m 644 <this-repo>/system/etc/polkit-1/rules.d/50-gsr-kms-server.rules /etc/polkit-1/rules.d/
```

| What it does | Lives in |
|---|---|
| PATH gets `~/.local/bin` first, so the nixGL wrapper wins | `hypr-user.lua` |
| fcitx5 environment for Hyprland | `hypr-user.lua`, `environment.d/90-fcitx5.conf` |
| Picks NVIDIA VA-API and GLX when booted in dGPU mode | `hypr-user.lua` |
| New windows open maximized; `Super + F` maximizes, `Super + Alt + F` is fullscreen | `hypr-user.lua`, `hypr-vars.lua` |
| GNOME/Mac-style screenshot and recording keys | `hypr-user.lua`, `bin/capture`, `bin/notify-action` |
| Touchpad: 2-finger right click, speed, gestures | `hypr-user.lua`, `hypr-vars.lua` |
| Drag the gap between windows to resize | `hypr-user.lua` |
| `Super + Shift + arrows` re-splits two windows so the focused one lands on that side | `hypr-user.lua` |
| No automatic HDR switch for fullscreen windows | `hypr-user.lua` |
| Emergency exit, `Super + M` exit, Mac-style extras | `hypr-user.lua`, `hypr-vars.lua` |
| `Super + Alt + ←→` moves the window to the previous / next workspace | `hypr-vars.lua` |
| `Super + V` clipboard picker | `hypr-user.lua`, `hypr-vars.lua`, `bin/clipboard` |
| `Super + J` / `Super + K` switch to the previous / next workspace | `hypr-vars.lua` |
| Next wallpaper on `Super + W` | `hypr-user.lua`, `bin/wallpaper-next` |
| Starts polkit agent, fcitx5, NetBird tray at login | `hypr-user.lua` |
| Monitor resolution, refresh rate and position with wdisplays (shows up as "wdisplays" in the launcher). It only changes the layout until logout; to keep one, write `hl.monitor({ output = "desc:...", mode = "1920x1080@165", position = "0x0", scale = 1 })` lines into `~/.config/hypr/monitors.lua` (values from `hyprctl monitors`), which `hypr-user.lua` loads | `hypr-user.lua`, `share/applications/network.cycles.wdisplays.desktop` |
| Zotero opens from the launcher. Its own `zotero.desktop` finds the install folder through `%k`, which Quickshell leaves empty, so this copy calls `/opt/zotero/zotero` directly. Change the path if Zotero lives somewhere else | `share/applications/zotero.desktop` |
| Default apps, cursor, disabled default binds | `hypr-vars.lua` |
| Notification click runs its action, launcher size, weather, no session gif, terminal | `shell.json` |
| Thinner bar | `shell-tokens.json` |
| Bar flashes a workspace when a launched app only focused a window already open there | `caelestia/nix/workspace-attention.patch` |
| Clock in the middle of the bar with weekday, day and month, focused app's name right under it; analog face instead of digits; click it for a big analog clock and calendar popout | `shell.json` (`bar.entries`, `bar.clock.showDate`, `bar.clock.showIcon`), `caelestia/nix/bar-clock.patch`, `caelestia/nix/bar-app-name.patch` |
| Notifications show the app's icon when the app sends a `file://` URL or an icon name the theme lacks | `caelestia/nix/notif-icon.patch` |
| Volume/brightness OSD only shows on key presses; dashboard, utilities and the session menu (right edge) open after a 0.5 s rest on their edge (`hoverDelay`); status icon and focused app popouts open on click, tray menus still on hover | `caelestia/nix/hover-click.patch` |
| Bluetooth "Pair new device" page keeps the pairing and trusts the device, with no pairing agent running | `caelestia/nix/bt-pairing.patch` |
| GNOME theme left alone; open terminals keep their own palette (Ptyxis: Monokai Dark) when the scheme changes; btop toggle uses foot | `cli.json` |

### Adapt these values

| Value | File | How to adapt |
|---|---|---|
| `elan06fa:00-04f3:31ad-touchpad`, `cx-wireless-mouse--1k-dongle-mouse` | `hypr-user.lua` | Get real names from `hyprctl devices`. Delete the block on a PC without a touchpad |
| `hl.exec_cmd("netbird-ui")` | `hypr-user.lua` | Delete unless NetBird is installed. Hyprland does not read `~/.config/autostart`, so other tray apps the person uses in GNOME go here |
| dGPU detection block | `hypr-user.lua` | Harmless on Intel/AMD-only machines. On NVIDIA-only machines it sets the NVIDIA VA-API/GLX variables, which is correct |
| `brave-browser`, `code`, `nautilus`, `ptyxis --new-window` | `hypr-vars.lua` | Use the person's apps. Check each with `command -v` |
| `cursorTheme = "Yaru"` | `hypr-vars.lua` | Caelestia writes the cursor into GNOME's settings too, so use GNOME's current one: `gsettings get org.gnome.desktop.interface cursor-theme` (`Adwaita` on Fedora and Arch) |
| `general.apps.terminal` | `shell.json` | Same terminal as `hypr-vars.lua` |
| `services.weatherLocation` (`"10.9289,108.1021"`, Phan Thiết) | `shell.json` | The person's city as `"lat,lon"`, or delete the key to use IP location |
| `kbBrowser = {}` | `hypr-vars.lua` | Turns off `Super + W` for the browser because the wallpaper script uses it. Remove both if the person prefers the browser key |
| `hl.window_rule` for "AITS ROBOT - label inspection" | `hypr-user.lua` | Personal app pinned to the MSI monitor. Delete it on other machines |
| `monitors/` per-screen overrides | not copied | Create `~/.config/caelestia/monitors/<name>/shell.json` only if needed (`hyprctl monitors -j \| jq -r '.[].name'`) |

## Phase 7: Vietnamese input with fcitx5

Use fcitx5 + Bamboo in both sessions. ibus-bamboo crashed under Hyprland on the reference machine, and the ibus switcher kept falling back to English.

```bash
sudo apt install fcitx5 fcitx5-bamboo fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt6 fcitx5-config-qt
# Arch:   sudo pacman -S fcitx5 fcitx5-bamboo fcitx5-gtk fcitx5-qt fcitx5-configtool
# Fedora: fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool are in the repos; fcitx5-bamboo is not.
#         Community COPRs exist (search "fcitx5-bamboo" on copr.fedorainfracloud.org) or build from
#         https://github.com/fcitx/fcitx5-bamboo
```

The repo files already set this up:

| File | Purpose |
|---|---|
| `~/.config/fcitx5/profile` | Keyboard `us` + `bamboo`, Bamboo as default |
| `~/.config/fcitx5/config` | `Super + Space` toggles, popup hidden |
| `~/.config/fcitx5/conf/bamboo.conf` | Bamboo settings: Telex, spell check off, macros on, free marking. fcitx5 rewrites this file and `profile` when settings change, so after changing them in `fcitx5-configtool`, copy both back into the repo |
| `hypr-user.lua`, `bin/fcitx5-switch` | Hyprland takes `Super + Space` first and runs the script, which switches and shows an EN/VI notification |
| `~/.config/environment.d/90-fcitx5.conf` | `XMODIFIERS`, `QT_IM_MODULE`, `SDL_IM_MODULE` = fcitx for every session |
| `~/.config/autostart/org.fcitx.Fcitx5.desktop` | Starts fcitx5 in GNOME only (`OnlyShowIn=GNOME`). GNOME talks to it through fcitx5's IBus frontend |
| `hypr-user.lua` | Starts `fcitx5 -d --replace` in Hyprland and sets the same variables |

Leave `GTK_IM_MODULE` unset. GTK then uses Wayland text-input, which fcitx5 handles in both GNOME and Hyprland.

Remove ibus only if the package manager does not want to remove GNOME with it. On Ubuntu 26.04 this was safe:

```bash
sudo apt remove --purge ibus ibus-bamboo ibus-gtk ibus-gtk3 ibus-gtk4 ibus-data
```

On distros where `gnome-shell` depends on `ibus`, keep it installed. `fcitx5 --replace` takes over the IBus bus at login anyway.

The changes to `environment.d` and autostart apply from the next login. Check in both sessions: open a text field, press `Super + Space`, type `tieesng vieejt`, expect `tiếng việt`.

## Phase 8: smaller fixes

| Fix | Command or file |
|---|---|
| Num Lock on at the GDM login screen (Hyprland handles its own with `numlock_by_default`) | `sudo -u gdm dbus-run-session gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true` |
| VS Code says "OS keyring couldn't be identified" in Hyprland | Add `"password-store": "gnome-libsecret"` to `~/.vscode/argv.json` |
| Wallpapers | Put images in `~/Pictures/Wallpapers`. On Ubuntu, `cp /usr/share/backgrounds/*.{jpg,png} ~/Pictures/Wallpapers/` gives a starting set |

## Phase 9: verify

Go through this with the person after a fresh login to Hyprland.

- [ ] `hyprctl configerrors` prints nothing, and there is no red bar at the top
- [ ] The bar is on the left, a tap on `Super` opens the launcher
- [ ] `Super + T`, `Super + E` open the terminal and file manager, maximized
- [ ] `Super + Space` then `tieesng vieejt` gives `tiếng việt`
- [ ] `Super + Shift + S`, drag a region, the notification appears top right, clicking it opens Swappy
- [ ] `Super + Shift + R` records with sound, pressing it again stops and saves to `~/Videos/Recordings`
- [ ] `Super + L` locks, and the real password unlocks
- [ ] `Ctrl + Shift + Escape` opens btop
- [ ] The GNOME session still logs in, keeps its theme, and types Vietnamese
- [ ] Laptops with NVIDIA: `cat /sys/bus/pci/devices/<nvidia-pci-id>/power/runtime_status` says `suspended` when idle (do not use `nvidia-smi` for this check; it wakes the card)

## Known problems and fixes

Every row here happened on the reference machine.

| Symptom | Cause | Fix |
|---|---|---|
| `caelestia shell`: `Failed to initialize graphics backend for OpenGL` | Nix programs cannot load the host GPU drivers | Run through nixGL (`~/.local/bin/caelestia` wrapper, PATH entry in `hypr-user.lua`) |
| After the first `caelestia shell`, GNOME shows a different theme and "Some required themes are missing" | Caelestia applies its GTK theme, icons and cursor to the settings GNOME shares | `cli.json` with `enableGtk: false` and `enableChromium: false`, then restore: `gsettings set org.gnome.desktop.interface gtk-theme <old>`, same for `icon-theme`, `gsettings reset ... cursor-theme`, delete `~/.config/gtk-3.0/gtk.css` and `~/.config/gtk-4.0/gtk.css` if Caelestia wrote them. The `~/.config` backup has the old values |
| Lock screen says the password is wrong | Nix's PAM looks for `/run/wrappers/bin/unix_chkpwd` | The tmpfiles entry in Phase 4 |
| `Super + Space` shows "English" only, Vietnamese never activates | ibus-bamboo crashes under Hyprland | Switch to fcitx5 (Phase 7) |
| Clicking the screenshot notification does nothing | Ubuntu's `notify-send` 0.8.8 wrongly reports that Caelestia has no action support | `bin/notify-action` talks to D-Bus directly |
| A bind runs a command with `;`, `&&` or `$(...)` and nothing happens | `hl.dsp.exec_cmd` does not run a shell | Put the logic in a script under `~/.local/bin` |
| btop toggle (`Ctrl + Shift + Escape`) does nothing after changing the terminal | Caelestia's default toggle starts `fish`, which is a Nix binary not on Hyprland's PATH | `toggles.sysmon.btop.command` in `cli.json` runs `foot ... btop` |
| `nixGLNvidia`: `cannot coerce null to a string` | nixGL cannot read the version of NVIDIA's open kernel module | `bin/install-nixgl-nvidia` passes `nvidiaVersion` explicitly |
| `~/.local/bin` appears dozens of times in PATH | Every `hyprctl reload` re-ran the PATH line | Fixed in `hypr-user.lua`: it only prepends when missing |
| No gear on the login screen | GDM autologin is on | Phase 1 |
| A password prompt never shows up in Hyprland | No polkit agent (`polkit-gnome` is not packaged on Ubuntu 26.04) | `hyprpolkitagent`, started from `hypr-user.lua` |
| A notification shows a pink and black square instead of the app's icon | The shell only looked the icon up by name in the theme, so `file://` URLs and names like `com.anthropic.Claude` failed | `notif-icon.patch` |
| A tray app that starts in GNOME is missing in Hyprland | Hyprland does not read `~/.config/autostart` | Add `hl.exec_cmd("app")` to the `hyprland.start` block in `hypr-user.lua` |
| `hyprctl dispatch exit` errors | Hyprland 0.57 with a Lua config expects Lua in `dispatch` | `hyprctl dispatch 'hl.dsp.exit()'` |
| Tray and tray-menu icons show as pink and black squares | The Nix-built shell cannot load the `qtengine` Qt plugin, so the `Papirus-Dark` icon theme in `~/.config/qtengine/config.json` is ignored | `papirus-icon-theme` from Phase 4 and `QS_ICON_THEME` in `hypr-user.lua` |
| After an hour idle the laptop does not go to sleep | The idle action was `systemctl suspend-then-hibernate`, but hibernation needs swap at least the size of RAM plus a `resume=` kernel parameter. The reference machine has a 4 GB swap file and no `resume=`, so `busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanSuspendThenHibernate` says `no` and nothing happens | `shell.json` now runs `systemctl suspend` |
| Pairing a headset from the Bluetooth panel seems to fail, or it is forgotten after disconnecting | No pairing agent runs in Hyprland, and BlueZ (`AlwaysPairable = false`) keeps the adapter non-pairable without one, so the device pairs without bonding | `bt-pairing.patch` |
| Going fullscreen in the browser takes seconds, with a message that 10-bit colour is not supported | `render:cm_auto_hdr` switches an HDR-capable monitor to HDR when a fullscreen window shows HDR video. That forces a modeset and needs a 10-bit link, which 1080p 144 Hz over HDMI did not give | `cm_auto_hdr = 0` in `hypr-user.lua` |
| NVIDIA looks awake at 8 W in `nvidia-smi` | `nvidia-smi` wakes the card to read it | Read `power/runtime_status` in sysfs instead |

## Updating and rolling back

Before every big update, take a snapshot: `sudo timeshift --create --comments "before upgrade"`. Then:

- `sudo apt update && sudo apt upgrade` (not `full-upgrade`). Watch for `hyprland`, `nvidia-*`, `linux-image-*` and `mesa` in the list. Reboot after kernel or NVIDIA updates.
- After an NVIDIA driver version change, run `install-nixgl-nvidia` before booting in dGPU mode.
- Update Caelestia's shell and CLI separately: change the `cli` commit in `home/.config/caelestia/nix/flake.nix`, run `nix flake update --flake path:<this-repo>/home/.config/caelestia/nix`, then `nix profile upgrade nix`. If a patch in that folder no longer applies, fix or drop it. The recorder's store path changes too, so put the new one in the polkit rule (Phase 6). Update the dots by copying a fresh `hypr/` folder (Phase 5). Personal files in `~/.config/caelestia` are never touched.
- Roll Hyprland back to Ubuntu's own packages: `sudo ppa-purge ppa:cppiber/hyprland`.
- Remove everything: pick GNOME at login, `sudo apt remove hyprland xdg-desktop-portal-hyprland hyprlock hypridle`, `/nix/nix-installer uninstall`, and restore `~/.config` from the backup if needed.
