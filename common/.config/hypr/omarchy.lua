-- Omarchy Hyprland setup: helpers, defaults, and current theme overrides.

require("hypr.helpers")

-- Use Omarchy defaults, but don't edit these directly.
require("hypr.autostart")
require("hypr.bindings.media")
require("hypr.bindings.clipboard")
require("hypr.bindings.tiling-v2")
require("hypr.bindings.utilities")
require("hypr.envs")
require("hypr.looknfeel")
require("hypr.input")
require("hypr.windows")

-- Current theme overrides.
do
  local paths = require("hypr.paths")
  local theme = io.open(paths.config_home .. "/omarchy/current/theme/hyprland.lua", "r")
  if theme then
    theme:close()
    require("omarchy.current.theme.hyprland")
  end
end
