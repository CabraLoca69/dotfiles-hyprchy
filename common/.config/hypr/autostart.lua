o.launch_on_start("hypridle")
o.launch_on_start("mako")
o.exec_on_start("! omarchy-toggle-enabled waybar-off && " .. o.launch("waybar"))
o.exec_on_start("setsid systemd-inhibit --what=handle-power-key --why='Omarchy power menu' sleep infinity &")
--o.launch_on_start("swaybg -i ~/.config/omarchy/current/background -m fill") -- fondos normales, reactivar en caso de ser necesario
o.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
o.launch_on_start("omarchy-hyprland-monitor-watch")


-- Slow app launch fix -- set systemd vars.
--o.exec_on_start("systemctl --user import-environment $(env | cut -d'=' -f 1)")
--o.exec_on_start("dbus-update-activation-environment --systemd --all")

-- Run post-boot hooks after startup config has loaded.
o.exec_on_start("sleep 2 && omarchy-hook post-boot")

-- wallpaper
 hl.on("hyprland.start", function()
     hl.exec_cmd("wallpaper-on-start")
 end)


