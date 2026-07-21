local M = {}

local PRESETS = {
	blog = { ext = "webp", args = "-resize '1600x1600>' -quality 75 -define webp:method=6" },
	webp = { ext = "webp", args = "-quality 80 -define webp:method=6" },
	jpeg = { ext = "jpg", args = "-strip -interlace Plane -sampling-factor 4:2:0 -quality 82" },
	lossless = { ext = "webp", args = "-quality 100 -define webp:lossless=true -define webp:method=6" },
}

-- Returns { kind = "path", path = "/abs/path" } or { kind = "bytes", mime = "image/png" } or nil.
local function detect_source()
	-- 1. Path on clipboard? wl-paste text, strip, expand ~, check it's an image file.
	local text = vim.fn.system("wl-paste --no-newline 2>/dev/null")
	if vim.v.shell_error == 0 and text and text ~= "" and not text:find("\n") then
		local path = vim.fn.expand(vim.trim(text))
		if vim.fn.filereadable(path) == 1 then
			local mime = vim.trim(vim.fn.system({ "file", "--mime-type", "-b", path }))
			if mime:match("^image/") then
				return { kind = "path", path = path }
			end
		end
	end
	-- 2. Image bytes on clipboard?
	local types = vim.fn.systemlist("wl-paste --list-types 2>/dev/null")
	for _, t in ipairs(types) do
		if t:match("^image/") then
			return { kind = "bytes", mime = t }
		end
	end
	return nil
end

local function paste(preset_name)
	local preset = PRESETS[preset_name]
	local src = detect_source()
	if not src then
		vim.notify("No image on clipboard (neither bytes nor a path)", vim.log.levels.ERROR)
		return
	end

	vim.ui.input({ prompt = "Image name (no extension): " }, function(name)
		if not name or name == "" then
			return
		end
		local filename = name .. "." .. preset.ext
		local dir = vim.fn.expand("%:p:h")
		local out = dir .. "/" .. filename

		local cmd
		if src.kind == "path" then
			cmd = string.format(
				"magick %s %s %s",
				vim.fn.shellescape(src.path),
				preset.args,
				vim.fn.shellescape(out)
			)
		else
			cmd = string.format(
				"wl-paste --type %s | magick - %s %s",
				src.mime,
				preset.args,
				vim.fn.shellescape(out)
			)
		end
		vim.fn.system(cmd)
		if vim.v.shell_error ~= 0 then
			vim.notify("Conversion failed: " .. cmd, vim.log.levels.ERROR)
			return
		end

		local link = string.format("![image](%s)", filename)
		vim.api.nvim_put({ link }, "c", true, true)
		vim.fn.system({ "wl-copy" }, link)

		local kb = math.floor(vim.fn.getfsize(out) / 1024)
		vim.notify(string.format("Saved %s (%d KB) — link inserted + clipboard", filename, kb))
	end)
end

vim.keymap.set("n", "<leader>iab", function()
	paste("blog")
end, { desc = "Paste image: WebP blog-optimized (≤1600px, q75)" })
vim.keymap.set("n", "<leader>iac", function()
	paste("webp")
end, { desc = "Paste image: WebP same size (q80)" })
vim.keymap.set("n", "<leader>iaj", function()
	paste("jpeg")
end, { desc = "Paste image: JPEG compressed (q82 progressive)" })
vim.keymap.set("n", "<leader>ial", function()
	paste("lossless")
end, { desc = "Paste image: WebP lossless 100% (no compression, no resize)" })

return M
