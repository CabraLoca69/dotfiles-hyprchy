-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. "/.config/hypr/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy"))
  .. "/?.lua;"
  .. package.path

-- All Omarchy default setups
require("hypr.omarchy")

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input") 
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.apps.system")

-- Toggle config flags dynamically.
require("hypr.toggles")

--cursor
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")

-- juegos de steam abren a la izquierda
hl.window_rule(
  {match = {class = "^steam_app_.*"}, 
  monitor = "DP-1" 
})

-- ds 
hl.window_rule({
  match = {class = "discord"}, 
  opacity = "1 0.99",
  monitor = "DP-3"
})

--firefox
hl.window_rule({
  match = {class = "firefox"}, 
  opacity = "1 0.98"
})

--spotify
hl.window_rule({
  match = {class = "Spotify"}, 
  opacity = "1 0.99",
  monitor = "DP-3" 
})

-- nautilus 
hl.window_rule({
  match = {class = "org.gnome.Nautilus"},
  opacity = "1 0.98",
  size = {1000, 600}, 
  float = true,
  pin = true
})

-- terminal flotante (apps/system.lua)
hl.window_rule({
  match = {tag = "floating-window"}, 
  size = {900, 600},
  pin = true
})

hl.window_rule({
  match = {initial_title = "Terminal"}, 
  opacity = "0.85 override"
})


--code
hl.window_rule({
  match = {initial_class =  "code-oss"},
  float = true,
  pin = true,
  size = {1500, 900}
})


