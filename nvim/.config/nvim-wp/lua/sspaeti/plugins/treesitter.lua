return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'TSInstallInfo', 'TSInstall' },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')

      if not status_ok then
        return
      end
      treesitter.setup {
        -- ensure_installed = { "vimdoc", "python", "markdown", "markdown_inline", "css", "html", "javascript", "yaml", "bash", "json", "lua", "regex", "sql", "toml", "vim", "rust", "glimmer" }, -- one of "all" or a list of languages
        ensure_installed = { "markdown", "markdown_inline" }, 
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true, -- false will disable the whole extension
            additional_vim_regex_highlighting = false,
            --   disable = { "css" }, -- list of language that will be disabled
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
        },
        autotag = {
          enable = true,
        },
        ignore_install = {},
        modules = {}
      }
    end
  }
}
