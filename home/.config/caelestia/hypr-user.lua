local home = os.getenv("HOME")

-- Put the nixGL wrapper in ~/.local/bin ahead of the plain Nix binary.
-- Checked first because every `hyprctl reload` runs this file again.
local path = os.getenv("PATH")
if not (":" .. path .. ":"):find(":" .. home .. "/.local/bin:", 1, true) then
    hl.env("PATH", home .. "/.local/bin:" .. path)
end

-- Vietnamese input with fcitx5-bamboo; GTK_IM_MODULE stays unset so GTK uses Wayland text-input.
-- The same values live in ~/.config/environment.d/90-fcitx5.conf for the GNOME session.
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

-- The Nix-built shell can't load the qtengine Qt plugin, so give Quickshell the icon theme directly
hl.env("QS_ICON_THEME", "Papirus-Dark")

-- BIOS dGPU (G-Sync) mode: every connected screen is on NVIDIA, so point apps at its VA-API and GLX.
-- Hybrid mode keeps the AMD defaults. ~/.local/bin/caelestia does the same check for nixGL.
local probe = io.popen([[for s in /sys/class/drm/card*-*/status; do
    [ "$(cat "$s")" = connected ] || continue
    n=$(basename "$(dirname "$s")"); cat "/sys/class/drm/${n%%-*}/device/vendor"
done]])
local vendors = probe and probe:read("*a") or ""
if probe then probe:close() end
if vendors:find("0x10de", 1, true) and not vendors:find("0x1002", 1, true) then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end

-- GNOME/Mac-style capture: drag for a region, click for the whole screen
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(home .. "/.local/bin/capture shot"))
-- SUPER + SHIFT + R again stops recording
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(home .. "/.local/bin/capture record"))

-- Mac-style touchpad: two-finger click is right click
hl.config({ input = { touchpad = { clickfinger_behavior = true } } })

-- Num Lock on after login
hl.config({ input = { numlock_by_default = true } })

-- Speed for every mouse, wired or wireless, whatever its device name
hl.config({ input = {
    sensitivity   = 0.0,    -- pointer speed: -1 (slowest) to 1 (fastest)
    accel_profile = "flat", -- no acceleration
} })

-- Drag the gap between windows to resize them, like GNOME
hl.config({ general = { resize_on_border = true, extend_border_grab_area = 15 } })

-- New windows always split to the right/bottom instead of following the mouse
hl.config({ dwindle = { force_split = 2 } })

-- Workspaces follow the monitor layout: the leftmost screen gets workspace 1, the next one 2, and so on
local function order_workspaces()
    local mons = hl.get_monitors()
    table.sort(mons, function(a, b)
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    local focused = hl.get_active_monitor()
    local moved = false
    for i, m in ipairs(mons) do
        hl.workspace_rule({ workspace = tostring(i), monitor = m.name, default = true })
        local ws = hl.get_workspace(i)
        if ws and ws.monitor and ws.monitor.name ~= m.name then
            hl.dispatch(hl.dsp.workspace.move({ workspace = i, monitor = m.name }))
            hl.dispatch(hl.dsp.focus({ workspace = i })) -- a moved workspace is not shown on its new screen by itself
            moved = true
        end
    end
    if moved and focused then hl.dispatch(hl.dsp.focus({ monitor = focused.name })) end
end
order_workspaces()
hl.on("hyprland.start", order_workspaces)
hl.on("monitor.layout_changed", order_workspaces)

-- Fullscreen HDR video made Hyprland switch the monitor to HDR, which is slow and fails without a 10-bit link
hl.config({ render = { cm_auto_hdr = 0 } })

-- Next wallpaper in ~/Pictures/Wallpapers, in order (SUPER + W no longer opens the browser, see hypr-vars.lua)
hl.bind("SUPER + W", hl.dsp.exec_cmd(home .. "/.local/bin/wallpaper-next"))

-- English / Vietnamese with an EN/VI notification (fcitx5 never sees SUPER + Space, Hyprland takes it first)
hl.bind("SUPER + Space", hl.dsp.exec_cmd(home .. "/.local/bin/fcitx5-switch"))

-- Clipboard picker on SUPER + V, SUPER + ALT + V deletes an entry
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || " .. home .. "/.local/bin/clipboard"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || " .. home .. "/.local/bin/clipboard -d"))

-- SUPER + M quits to the login screen (Caelestia's music workspace key is turned off in hypr-vars.lua)
hl.bind("SUPER + M", hl.dsp.exit())

-- SUPER + SHIFT + arrow moves the window; with no window on that side it re-splits the pair
-- so the window lands on that side (left/right pair + down = top/bottom, window at the bottom)
local function window_pos(axis)
    return hl.get_active_window().at[axis]
end

local function move_or_split(dir)
    local w = hl.get_active_window()
    if not w or w.floating or not w.workspace then return end
    local axis = (dir == "up" or dir == "down") and "y" or "x"
    local want_bigger = dir == "down" or dir == "right"
    -- Far edge of a window on the side we move to (bottom for down, left for left, ...)
    local function edge(win)
        if want_bigger then return win.at[axis] + win.size[axis] end
        return win.at[axis]
    end
    local function beyond(win)
        if want_bigger then return win.at[axis] >= edge(w) - 2 end
        return win.at[axis] + win.size[axis] <= w.at[axis] + 2
    end

    local has_beyond, shares_edge = false, false
    for _, o in ipairs(hl.get_windows()) do
        if o.address ~= w.address and not o.floating and not o.hidden and o.mapped
            and o.workspace and o.workspace.id == w.workspace.id then
            if beyond(o) then has_beyond = true end
            if math.abs(edge(o) - edge(w)) <= 2 then shares_edge = true end
        end
    end

    if has_beyond then
        hl.dispatch(hl.dsp.window.move({ direction = dir }))
        return
    end
    -- Already alone on that edge (or alone on the workspace): Hyprland's move would scramble the layout
    if not shares_edge then return end

    -- Side by side: try toggle split, then toggle + swap, keep whichever puts the window furthest that way
    local function better(a, b) if want_bigger then return a > b else return a < b end end
    local p0 = window_pos(axis)
    hl.dispatch(hl.dsp.layout("togglesplit"))
    local p1 = window_pos(axis)
    hl.dispatch(hl.dsp.layout("swapsplit"))
    local p2 = window_pos(axis)
    if better(p2, p1) and better(p2, p0) then return end
    hl.dispatch(hl.dsp.layout("swapsplit"))
    if better(p1, p0) then return end
    hl.dispatch(hl.dsp.layout("togglesplit"))
end

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.unbind("SUPER + SHIFT + " .. dir)
    hl.bind("SUPER + SHIFT + " .. dir, function() move_or_split(dir) end)
end

-- Emergency exit back to the login screen, works even if Caelestia is broken
hl.bind("CTRL + SUPER + SHIFT + Escape", hl.dsp.exit())

-- SUPER + J / SUPER + K switch workspaces (see hypr-vars.lua)

-- Mac-style keys (SUPER = Cmd)
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + CTRL + Q", hl.dsp.global("caelestia:lock"))

-- 4-finger pinch in opens the launcher, like Launchpad
hl.gesture({
    fingers   = 4,
    direction = "pinchin",
    action    = function() hl.dispatch(hl.dsp.global("caelestia:launcher")) end,
})

hl.on("hyprland.start", function()
    -- polkit-gnome is not packaged on Ubuntu 26.04
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("fcitx5 -d --replace")
    -- Hyprland doesn't run ~/.config/autostart, so start the NetBird tray here
    hl.exec_cmd("netbird-ui")
end)

-- Saved monitor layout (~/.config/hypr/monitors.lua, hl.monitor lines). wdisplays only changes it until logout
pcall(require, "monitors")

