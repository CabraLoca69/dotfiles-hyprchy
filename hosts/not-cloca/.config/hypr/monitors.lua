-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

hl.monitor({
    output = "eDP-1",
    mode = "1366x768@59.999",
    position = "0x0",
    scale = 1,
    vrr = 0,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "1366x0", --"-1366x0" --va izq o der
    scale = 1,
    vrr = 0,
    --transform = -- lo rota
})
