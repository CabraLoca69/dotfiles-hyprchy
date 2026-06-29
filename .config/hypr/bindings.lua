local paths = require("hypr.paths")
local require_all = require("hypr.require_all")

require_all.files(paths.config_home .. "/hypr/bindings", "hypr.bindings")

require("hypr.bindings.media")
require("hypr.bindings.clipboard")
require("hypr.bindings.tiling-v2")
require("hypr.bindings.utilities")
 
o.bind("SUPER + RETURN", "Terminal", "omarchy-launch-floating-terminal -d exec bash")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

-- wallpaper bind
o.bind("SUPER + ALT + X", "Wallpaper selector", "omarchy-launch-or-focus -f -t 'Wallpaper-selector' 'Wallpaper-selector' wallpaper-picker")

-- sicroniza y actualiza
o.bind("SUPER + ALT + CTRL + U", "Update system", "omarchy-launch-or-focus -f -d -t 'Update' 'Update' 'paru -Syu'")

-- obs keybindings
o.bind("CTRL + SHIFT + F1",
        "Obs Clip",
        hl.dsp.pass({
                window = "class:^(com\\.obsproject\\.Studio)$" })
)


--nautilus
o.bind("SHIFT + ALT + E", "Open filexplorer", "nautilus")
--ds
o.bind("SHIFT + ALT + D", "Open discord", "discord")
--steam
o.bind("SHIFT + ALT + S", "Open steam", "steam")
--spotify
o.bind("SHIFT + CTRL + S", "Open spotify", "spotify")