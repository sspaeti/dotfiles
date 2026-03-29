-- ── neomd: attach file from within the email editor ───────────────────────
-- Usage: <leader>a  in normal mode while writing a neomd-*.md email buffer.
-- Opens yazi in a floating window. Selected file path(s) are inserted as
--   <!-- Attach: /absolute/path/to/file.pdf -->
-- neomd strips these lines before sending and adds them as MIME attachments.
local function neomd_attach()
  local target_buf = vim.api.nvim_get_current_buf()
  local target_win = vim.api.nvim_get_current_win()
  local cursor_row = vim.api.nvim_win_get_cursor(target_win)[1]
  local chooser = vim.fn.tempname()

  -- Floating terminal sized to 85 % of the screen
  local W = math.floor(vim.o.columns * 0.85)
  local H = math.floor(vim.o.lines  * 0.85)
  local float_buf = vim.api.nvim_create_buf(false, true)
  local float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    width  = W, height = H,
    col    = math.floor((vim.o.columns - W) / 2),
    row    = math.floor((vim.o.lines   - H) / 2),
    style  = "minimal",
    border = "rounded",
    title  = " attach file — <Enter> select, q quit ",
    title_pos = "center",
  })

  vim.fn.termopen({ "yazi", "--chooser-file", chooser }, {
    on_exit = function()
      if vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_close(float_win, true)
      end
      vim.schedule(function()
        local ok, lines = pcall(vim.fn.readfile, chooser)
        vim.fn.delete(chooser)
        if not ok or not lines or #lines == 0 then return end

        local inserts = {}
        for _, path in ipairs(lines) do
          path = vim.trim(path)
          if path ~= "" then
            table.insert(inserts, "[attach] " .. path)
          end
        end
        if #inserts == 0 then return end

        -- Insert after the current cursor row, then move cursor past them
        vim.api.nvim_buf_set_lines(target_buf, cursor_row, cursor_row, false, inserts)
        if vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_win_set_cursor(target_win, { cursor_row + #inserts, 0 })
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

-- Only map <leader>a when editing a neomd compose buffer (neomd-*.md)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "neomd-*.md",
  callback = function()
    vim.keymap.set("n", "<leader>a", neomd_attach, {
      buffer = true,
      desc   = "neomd: attach file via yazi",
    })
  end,
})
-- ── end neomd ──────────────────────────────────────────────────────────────

--custom function to set colortheme based on session session_name
--please make sure that the theme isn't loaded lazy when set as initial theme
function SetThemeBasedOnTmuxSession(sessionThemes)
    local handle = io.popen("tmux display-message -p '#S'")
    local session_name = handle:read("*a")
    handle:close()

    session_name = session_name:gsub("%s+", "")

    local theme = sessionThemes[session_name] or sessionThemes["default"]
    vim.cmd("colorscheme " .. theme)
    
    -- Call the transparency function after setting the colorscheme
    -- require("sspaeti.transparency").set_transparency()
end
