-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
    kb_layout = "es",

    -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
    -- kb_variant = "intl",

    -- kb_options = "compose:caps, grp:alts_toggle",

    -- Change speed of keyboard repeat.
    repeat_rate = 20,
    repeat_delay = 220,

    -- Start with numlock on by default.
    -- numlock_by_default = true,

    -- Increase sensitivity for mouse/trackpad (default: 0).
    sensitivity = -0.20,

    -- Turn off mouse acceleration (default: adaptive).
    accel_profile = "flat",
  
  },
})

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

misc = {
   key_press_enables_dpms = true,
   mouse_move_enables_dpms = true,
}
