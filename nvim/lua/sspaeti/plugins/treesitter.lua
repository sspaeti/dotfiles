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
        ensure_installed = { "vimdoc", "python", "markdown", "markdown_inline", "css", "html", "javascript", "yaml", "bash", "json", "lua", "regex", "sql", "toml", "vim", "rust", "glimmer" }, -- one of "all" or a list of languages
        sync_install = false,
        auto_install = true,
        -- highlight = {
        --   enable = true, -- false will disable the whole extension
        --   disable = { "css" }, -- list of language that will be disabled
        -- },
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
  },
  {
    -- this will show the the context of current cursor position, e.g. in a long fuctiion the defintion will be shown at the top
    "nvim-treesitter/nvim-treesitter-context",
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'treesitter-context'.setup {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 1,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        multiline_threshold = 5, -- Maximum number of lines to show for a single context
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
      }
    end
  }
}
