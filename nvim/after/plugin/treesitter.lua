require("nvim-treesitter.configs").setup {
	ensure_installed = {"help", "python", "markdown", "markdown_inline", "css", "html", "javascript", "yaml", "bash", "json", "lua", "regex", "sql", "toml", "vim", "rust"}, -- one of "all" or a list of languages
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "css" }, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	-- indent = { enable = true, disable = { "yaml", "python" } },
	-- rainbow is no longer maintained
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
		}
}
