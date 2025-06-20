-- from https://github.com/vimichael/my-nvim-config/blob/c495324cf7435707f5a84a2bb127a764632872c4/lua/cool_stuff/todo_float.lua and this YT: https://www.youtube.com/watch?v=LaIa1tQFOSY
local utils = require("sspaeti.plugins_custom.utils")

local M = {}

-- Track the current todo window
local todo_win = nil

local function float_win_config()
	local width = math.min(math.floor(vim.o.columns * 0.9), 128)
	local height = math.floor(vim.o.lines * 0.8)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = utils.center_in(vim.o.columns, width),
		row = utils.center_in(vim.o.lines, height),
		border = "single",
	}
end

local function toggle_floating_file(filepath)
	-- If window exists and is valid, close it
	if todo_win and vim.api.nvim_win_is_valid(todo_win) then
		vim.api.nvim_win_close(todo_win, true)
		todo_win = nil
		return
	end

	local path = utils.expand_path(filepath)

	-- Check if the file exists
	if vim.fn.filereadable(path) == 0 then
		vim.notify("File does not exist: " .. path, vim.log.levels.ERROR)
		return
	end

	-- Look for an existing buffer with this file
	local buf = vim.fn.bufnr(path, true)

	-- If the buffer doesn't exist, create one and edit the file
	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, path)
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		end)
	end

	todo_win = vim.api.nvim_open_win(buf, true, float_win_config())
	vim.cmd("setlocal nospell")

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			-- Check if the buffer has unsaved changes
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				vim.notify("Please save changes first", vim.log.levels.WARN)
			else
				vim.api.nvim_win_close(0, true)
				todo_win = nil
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			if todo_win and vim.api.nvim_win_is_valid(todo_win) then
				vim.api.nvim_win_set_config(todo_win, float_win_config())
			end
		end,
		once = false,
	})

	-- Clear todo_win when window is closed
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(todo_win),
		callback = function()
			todo_win = nil
		end,
		once = true,
	})
end

local function setup_user_commands(opts)
	local target_file = opts.target_file or "todo.md"
	local resolved_target_file = vim.fn.resolve(target_file)

	if vim.fn.filereadable(resolved_target_file) == true then
		opts.target_file = resolved_target_file
	else
		opts.target_file = opts.global_file
	end
	vim.api.nvim_create_user_command("Td", function()
		toggle_floating_file(opts.target_file)
	end, {})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>tt", ":Td<CR>", { desc = "open my todo file", silent = true })
	vim.keymap.set("n", "<leader><leader>", ":Td<CR>", { desc = "open my todo file", silent = true })
end

M.setup = function(opts)
	setup_user_commands(opts)
	setup_keymaps()
end

return M
