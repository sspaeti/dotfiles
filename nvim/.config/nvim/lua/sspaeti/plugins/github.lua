return {
  --work on a PR from GitHub within Neovim: Octo works better now than gh.nvim
  --{
  --"ldelossa/gh.nvim",
  --event = "VeryLazy",
  --dependencies = {
  --  {
  --    "ldelossa/litee.nvim",
  --    config = function()
  --      require("litee.lib").setup()
  --    end,
  --  },
  --},
  --config = function()
  --  require("litee.gh").setup()
  --end,
  --},
  {
    'pwntester/octo.nvim',
    cmd = { 'Octo' }, -- only run when Octo is called (also to avoid seeing warning: `Cannot request projects v2, missing scope 'read:project'` all the time)

    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      -- OR 'ibhagwan/fzf-lua',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require "octo".setup({
        {
          --TODO: does not work...
          suppress_missing_scope = {
            projects_v2 = true,
          }
        }

      })
    end
  }
}
