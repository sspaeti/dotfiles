-- a little mess and not yet verified. But diagnostics working well when opening a java file
-- see also lspconfig.lua where jdtls is configured
return {
  {
    --removed until https://github.com/neovim/neovim/issues/20795 is fixed
    "mfussenegger/nvim-jdtls",
    -- event = "VeryLazy",
    -- config = function()
    --   local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
    -- --   local lsp_attach = function(client, bufnr)
    -- --     -- mappings here
    -- --   end
    --    local config = {
    --       cmd = { jdtls_bin },
    -- --       root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
    -- --       on_attach = lsp_attach,
    --    }
    -- --   require('jdtls').start_or_attach(config)
  -- --     cmd = {'/opt/homebrew/bin/jdtls'},
  -- --     root_dir = vim.fs.dirname(vim.fs.find({'.gradlew', '.git', 'mvnw'}, { upward = true })[1]),
  -- -- }
    -- end
  }
}
