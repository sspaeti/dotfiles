return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- ]c / [c: native diff jump in diff mode (diffview, :Gdiff), git hunk jump otherwise
        local function nav(dir, key)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({ key, bang = true })
            else
              gs.nav_hunk(dir)
            end
          end
        end
        map("n", "]c", nav("next", "]c"), "Next git hunk / diff change")
        map("n", "[c", nav("prev", "[c"), "Previous git hunk / diff change")
        map("n", "]h", nav("next", "]c"), "Next git hunk")
        map("n", "[h", nav("prev", "[c"), "Previous git hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Git blame line (popup)")
      end,
    },
  },
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require('blame').setup {}
    end,
    opts = {
      blame_options = { '-w' },
    },
  },
}
