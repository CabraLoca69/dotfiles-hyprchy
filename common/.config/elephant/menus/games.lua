Name = "games"
NamePretty = "Games"
Icon = "applications-games"
Terminal = false
Cache = false
Action = "%VALUE%"

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function GetEntries()
    local entries = {}
    local dirs = {
        os.getenv("HOME") .. "/.local/share/applications",
        "/usr/share/applications",
        "/var/lib/flatpak/exports/share/applications",
        os.getenv("HOME") .. "/.local/share/flatpak/exports/share/applications",
    }

    local seen = {}

    for _, dir in ipairs(dirs) do
        local p = io.popen('grep -l "Categories=.*Game" "' .. dir .. '"/*.desktop 2>/dev/null')
        if p then
            for file in p:lines() do
                if not seen[file] then
                    seen[file] = true
                    local name, exec, icon
                    for raw_line in io.lines(file) do
                        local line = trim(raw_line)
                        if line:match("^Name=") and not name then
                            name = line:gsub("^Name=", "")
                        elseif line:match("^Exec=") and not exec then
                            exec = line:gsub("^Exec=", ""):gsub("%%%a", "")
                        elseif line:match("^Icon=") and not icon then
                            icon = line:gsub("^Icon=", "")
                        end
                    end
                    if name and exec then
                        table.insert(entries, {
                            Text = name,
                            Value = exec,
                            Icon = icon or "applications-games",
                        })
                    end
                end
            end
            p:close()
        end
    end
    return entries
end