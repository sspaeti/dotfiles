return {
		"stevearc/aerial.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
    config = function()
      require('aerial').setup({
        on_attach = function(bufnr)
          -- Toggle the aerial window with <leader>a
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>o', '<cmd>AerialToggle!<CR>', {})
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
