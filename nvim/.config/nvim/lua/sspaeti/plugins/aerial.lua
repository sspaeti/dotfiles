return {
		"stevearc/aerial.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
    config = function()
      require('aerial').setup({
        layout = {
          max_width = 30,
          width = 25,
          min_width = 20,
          default_direction = "right",
        },
        float = {
          border = "rounded",
          relative = "win",
          override = function(conf, source_winid)
            conf.anchor = "NE"
            conf.col = vim.fn.winwidth(source_winid)
            conf.row = 0
            return conf
          end,
        },
        -- Skip treesitter for SQL to avoid create_policy query error
        -- See: https://github.com/stevearc/aerial.nvim/issues/506
        backends = {
          ["_"] = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
          sql = { "lsp" },
          mysql = { "lsp" },
          plsql = { "lsp" },
        },
        on_attach = function(bufnr)
          -- <leader>o is mapped in remap.lua (zen-mode aware)
          -- -- Jump forwards/backwards with '{' and '}'
          -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
          -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
          -- -- Jump up the tree with '[[' or ']]'
          -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
          -- vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNextUp<CR>', {})
        end

      })

      -- Set up your LSP clients here, using the aerial on_attach method
      -- require("lspconfig").vimls.setup{
      --   on_attach = require("aerial").on_attach,
      -- }
      -- Repeat this for each language server you have configured
   end
	}
