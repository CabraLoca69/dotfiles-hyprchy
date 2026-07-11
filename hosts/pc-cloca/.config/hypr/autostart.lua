o.launch_on_start("hypridle")
o.launch_on_start("mako")
o.exec_on_start("! omarchy-toggle-enabled waybar-off && " .. o.launch("waybar"))
o.exec_on_start("setsid systemd-inhibit --what=handle-power-key --why='Omarchy power menu' sleep infinity &")
o.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
o.launch_on_start("omarchy-hyprland-monitor-watch")


-- Run post-boot hooks after startup config has loaded.
o.exec_on_start("sleep 2 && omarchy-hook post-boot")

-- wallpaper
 hl.on("hyprland.start", function()
     hl.exec_cmd("wallpaper-on-start")
 end)


--obs autostart
--o.launch_on_start("sh -c 'sleep 2 && obs --minimize-to-tray --startreplaybuffer'")

-- abrir ds, spotify y steam 
o.exec_on_start("steam -silent")
o.exec_on_start("sleep 4 && discord")
o.exec_on_start("spotify")


