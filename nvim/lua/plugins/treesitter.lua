local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = {"python", "markdown", "markdown_inline", "css", "html", "javascript", "yaml", "bash", "json", "lua", "regex", "sql", "toml", "vim", "rust"}, -- one of "all" or a list of languages
	auto_install = true,
	ignore_install = { "" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "css" }, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = { "yaml", "python" } },
	rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
})
