-- from https://github.com/vimichael/my-nvim-config/blob/c495324cf7435707f5a84a2bb127a764632872c4/lua/cool_stuff/todo_float.lua and this YT: https://www.youtube.com/watch?v=LaIa1tQFOSY
local utils = {}

function utils.expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

function utils.center_in(outer, inner)
	return (outer - inner) / 2
end

return utils
