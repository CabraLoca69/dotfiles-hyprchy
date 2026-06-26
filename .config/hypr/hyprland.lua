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



-- Toggle config flags dynamically.
require("hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })


--directorio de capturas
hl.env("OMARCHY_SCREENSHOT_DIR", "/home/cloca/Imágenes/Screenshots")

--directorio de grabacion de pantalla
hl.env("OMARCHY_SCREENRECORD_DIR", "/home/cloca/ssd/Videos/Screenrecording")

-- ds 
hl.window_rule({ match = {class = "discord"}, opacity = "1 0.93"})
hl.window_rule({match = {class = "discord"}, monitor = "DP-3" })

--spotify
hl.window_rule({match = {class = "Spotify"}, monitor = "DP-3" })

-- juegos de steam abren a la izquierda
hl.window_rule({match = {class = "^steam_app_.*"}, monitor = "DP-1" })

-- nvtop abre flotando
hl.window_rule({match = {class = "org.omarchy.nvtop"}, float = true })

-- nautilus 
hl.window_rule({match = {class = "org.gnome.Nautilus"}, float = true })
