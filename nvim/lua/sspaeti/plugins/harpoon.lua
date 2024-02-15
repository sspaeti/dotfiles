return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  keys = {
    { "si", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon: Toggle Quick Menu" },
    { "sm", function() require("harpoon.mark").add_file() end, desc = "Harpoon: Add File Mark" },
    { "<leader>j", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon: Navigate File 1" },
    { "<leader>k", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon: Navigate File 2" },
    -- { "<leader>l", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon: Navigate File 3" }, --used for lsp (mason, lazy)
    { "<leader>;", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon: Navigate File 3" },
    { "<leader>hj", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon: Navigate File 4" },
    { "<leader>hk", function() require("harpoon.ui").nav_file(5) end, desc = "Harpoon: Navigate File 5" },
    { "<leader>hl", function() require("harpoon.ui").nav_file(6) end, desc = "Harpoon: Navigate File 6" }
  }
  --config = function()
  --  local ui = require("harpoon.ui")
  --  --set here, so I can use <leader>li for Mason and <leader>l for Harpoon. Does not work with lazy.nvim `keys` above
  --  -- vim.keymap.set("n", "<leader>l", function() ui.nav_file(3) end)
  --end

}
