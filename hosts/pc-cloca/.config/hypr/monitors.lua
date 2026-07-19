-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@165",
    position = "0x0",
    scale = 1,
    vrr = 0,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080@165",
    position = "1920x-700",
    scale = 1,
    transform = 3,
    vrr = 0,
})

-- tv por hdmi
hl.monitor({  
     output = "HDMI-A-1",
     mode = "1366x768@60",
     position = "-1366x0",
     vrr = 0,
     scale = 1,  
})
