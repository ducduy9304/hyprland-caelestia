return {
    browser     = "brave-browser",
    editor      = "code",
    fileExplorer = "nautilus",
    terminal    = "ptyxis --new-window",
    -- Caelestia also writes the cursor to GNOME's settings, so keep GNOME's default
    cursorTheme = "Yaru",
    cursorSize  = 24,
    -- SUPER + SHIFT + S is bound to ~/.local/bin/capture in hypr-user.lua
    kbScreenshotFreeze = {},
    -- SUPER + W is the next-wallpaper key in hypr-user.lua
    kbBrowser = {},

    -- Mac-style: 3-finger swipe for workspaces, sleep gesture moved to 5 fingers so it can't fire by accident
    workspaceSwipeFingers = 3,
    gestureFingersMore    = 5,
    -- Special workspace show/hide (swipe up/down) moved from 3 to 4 fingers so it doesn't fire by accident
    gestureFingers        = 4,

    -- SUPER + F maximizes (bar visible), SUPER + ALT + F is true fullscreen
    kbWindowFullscreen         = "SUPER + ALT + F",
    kbWindowBorderedFullscreen = "SUPER + F",
}
