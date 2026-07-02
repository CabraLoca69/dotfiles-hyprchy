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

--directorio de capturas
hl.env("OMARCHY_SCREENSHOT_DIR", "/home/cloca/Imágenes/Screenshots")
