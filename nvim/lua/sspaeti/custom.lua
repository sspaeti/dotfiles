--custom function to set colortheme based on session session_name
--please make sure that the theme isn't loaded lazy when set as initial theme
function SetThemeBasedOnTmuxSession(sessionThemes)
    local handle = io.popen("tmux display-message -p '#S'")
    local session_name = handle:read("*a")
    handle:close()

    session_name = session_name:gsub("%s+", "")

    local theme = sessionThemes[session_name]
    if theme then
        -- Set the specified theme
        vim.cmd("colorscheme " .. theme)
    else
        -- Default theme from dictionary
        vim.cmd("colorscheme " .. sessionThemes["default"])
    end
end

