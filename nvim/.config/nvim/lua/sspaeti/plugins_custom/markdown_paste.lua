-- Paste clipboard as markdown via Defuddle.
-- Requires:
--   defuddle CLI (https://github.com/kepano/defuddle)  →  npm install -g defuddle
--   curl, wl-paste
--
-- <leader>md  decides automatically:
--   1. Clipboard offers text/html (browser copy) → wl-paste HTML, preprocess, pipe to defuddle.
--   2. Clipboard is a single-line URL                → curl URL, preprocess, pipe to defuddle.
--   3. Otherwise                                     → abort (use regular `p`).
--
-- Preprocess steps (applied to fetched HTML before defuddle parses it):
--   - Wrap fragment in <html><body><article> if no <html> root — browser clipboard HTML is a
--     selection fragment, and defuddle aborts with "No content could be extracted" without it.
--   - Replace each <picture>…</picture> with a bare <img src="…"> using the first <img src>
--     (or first <source srcSet>) URL — defuddle's readability pass strips <img> children of
--     <picture>, losing the image otherwise.

local function decide()
	-- 1. HTML on clipboard?
	local types = vim.fn.systemlist("wl-paste --list-types 2>/dev/null")
	for _, t in ipairs(types) do
		if t == "text/html" then
			return { kind = "html" }
		end
	end

	-- 2. URL on clipboard?
	local text = vim.fn.system("wl-paste --no-newline 2>/dev/null")
	if vim.v.shell_error == 0 and text and text ~= "" then
		local trimmed = vim.trim(text)
		if not trimmed:find("[\n\r]") and trimmed:match("^https?://%S+$") then
			return { kind = "url", url = trimmed }
		end
	end

	return nil
end

local function preprocess(html)
	if not html:lower():find("<html") then
		html = "<html><body><article>" .. html .. "</article></body></html>"
	end
	html = html:gsub("<picture[^>]*>(.-)</picture>", function(inner)
		local url = inner:match([[<img[^>]+src="([^"]+)"]])
		if not url then
			local ss = inner:match([=[[Ss]rc[Ss]et="([^"]+)"]=])
			if ss then
				url = ss:match("([^%s,]+)")
			end
		end
		if not url then
			return ""
		end
		return string.format([[<img src="%s">]], url)
	end)
	return html
end

local function fetch_html(src)
	if src.kind == "url" then
		local ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
		return vim.fn.system({ "curl", "-sL", "--compressed", "-A", ua, "--max-time", "30", src.url })
	else
		return vim.fn.system({ "wl-paste", "--type", "text/html" })
	end
end

local function paste()
	for _, bin in ipairs({ "defuddle", "curl", "wl-paste" }) do
		if vim.fn.executable(bin) == 0 then
			vim.notify(
				string.format(
					"%s not found. (defuddle: npm install -g defuddle — https://github.com/kepano/defuddle)",
					bin
				),
				vim.log.levels.ERROR
			)
			return
		end
	end

	local src = decide()
	if not src then
		vim.notify("No HTML or URL on clipboard — use regular paste", vim.log.levels.WARN)
		return
	end

	local html = fetch_html(src)
	if vim.v.shell_error ~= 0 or not html or html == "" then
		vim.notify("Failed to fetch HTML (" .. src.kind .. ")", vim.log.levels.ERROR)
		return
	end

	local md = vim.fn.system({ "defuddle", "parse", "/dev/stdin", "--md" }, preprocess(html))
	if vim.v.shell_error ~= 0 or md == "" then
		vim.notify("Defuddle failed:\n" .. md, vim.log.levels.ERROR)
		return
	end

	md = md:gsub("\n+$", "")
	local lines = vim.split(md, "\n", { plain = true })
	vim.api.nvim_put(lines, "l", true, true)

	vim.notify(string.format("Inserted %d lines from %s", #lines, src.kind == "url" and src.url or "clipboard HTML"))
end

vim.keymap.set("n", "<leader>md", paste, { desc = "Paste markdown via Defuddle (HTML/URL → md)" })
