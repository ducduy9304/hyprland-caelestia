return {
    browser     = "brave-browser",
    editor      = "code",
    fileExplorer = "nautilus",
    terminal    = "gnome-terminal --window",
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

    -- SUPER + J / SUPER + K: previous / next workspace
    kbNextWs = { "SUPER + mouse_down", "CTRL + SUPER + Right", "SUPER + Page_Down", "SUPER + K" },
    kbPrevWs = { "SUPER + mouse_up", "CTRL + SUPER + Left", "SUPER + Page_Up", "SUPER + J" },
    kbShowPanels = {},

    -- SUPER + ALT + Left / Right move the window to the previous / next workspace instead of resizing it
    kbMoveWinToWsNext     = { "SUPER + ALT + mouse_down", "SUPER + ALT + Page_Down", "CTRL + SUPER + SHIFT + Right", "SUPER + ALT + Right" },
    kbMoveWinToWsPrev     = { "SUPER + ALT + mouse_up", "SUPER + ALT + Page_Up", "CTRL + SUPER + SHIFT + Left", "SUPER + ALT + Left" },
    kbWindowDecreaseWidth = "SUPER + Minus",
    kbWindowIncreaseWidth = "SUPER + Equal",

    -- SUPER + M exits Hyprland, SUPER + Space switches input method, SUPER + V opens the clipboard picker: all in hypr-user.lua
    kbMusicWs      = {},
    kbClipboard    = {},
    kbClipboardDel = {},
}
