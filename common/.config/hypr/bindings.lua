-- Switch workspaces (1-5)
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, "workspace", tostring(i))
    hl.bind(mainMod .. " + SHIFT + " .. i, "movetoworkspace", tostring(i))
end

-- Mouse binds (Move/Resize windows)
hl.mousebind(mainMod .. " + mouse:272", "movewindow")
hl.mousebind(mainMod .. " + mouse:273", "resizewindow")
