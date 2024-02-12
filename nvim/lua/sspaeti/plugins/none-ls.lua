return {
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim", --before: "jose-elias-alvarez/null-ls.nvim",
		},
		-- config = function()
		--   require("~/.config/nvim/after/plugin/null-ls.lua") -- require your null-ls config here (example below)
    --   move the whole thing to specific location and include configs here. See ThePrimagen new dotfiles when up: https://github.com/ThePrimeagen/.dotfiles
		-- end,
	},
  {
		"nvimtools/none-ls.nvim", --before: jose-elias-alvarez/null-ls.nvim"
    config = function()
      require("mason").setup()

      require("mason-null-ls").setup({
        ensure_installed = { "stylua", "jq" },
        automatic_setup = true,
      })


      local null_ls_status_ok, null_ls = pcall(require, "null-ls")
      if not null_ls_status_ok then
          return
      end

      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local completion = null_ls.builtins.completion

      require("null-ls").setup({
          sources = {
              formatting.black.with({extra_args = {"--fast"}}),
              formatting.isort,
              formatting.stylua.with({extra_args = {"indent_type=space"}}),
              --see also ~/.pylintrc or .my_example.toml
              -- R - refactoring related checks => snake_case
              -- C - convention related checks
              -- W0511 disable TODO warning
              -- W1201, W1202 disable log format warning. False positives (I think)
              -- W0231 disable super-init-not-called - pylint doesn't understand six.with_metaclass(ABCMeta)
              -- W0707 disable raise-missing-from which we cant use because py2 back compat
              -- C0301 Line too long => disabled as black-formatter handles long lines automatically
              diagnostics.flake8.with({extra_args = {"--max-line-length=88", "--disable=R,duplicate-code,W0231,W0511,W1201,W1202,W0707,C0301,no-init"}}),
              diagnostics.mypy.with({extra_args = {"--ignore-missing-imports"}}),
              diagnostics.write_good
          },
      })
  end
  }
}
