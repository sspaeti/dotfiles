return {
  --not used. Copilot is used instead
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("chatgpt").setup({
  --       async_api_key_cmd = "echo 'OPENAI_API_KEY'",
  --       -- predefined_chat_gpt_prompts = "https://gist.githubusercontent.com/sspaeti/ede00414a3862bbd46d944106f83a1d9/raw/77fea556976ca1692d95c17ad0e425851303376c/prompt-roles-chatgpt.csv"
  --     })
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  -- },
  --
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    opts = {},
    build = "make",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      {
        "grapp-dev/nui-components.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim"
        }
      },
      "nvim-lua/plenary.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    config = function()
      require("avante").setup({
        ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        provider = "openai", --"claude",
        hints = { enabled = false },
      })
    end,
    -- keys = {
    --   { "<leader>ai", "<cmd>AvanteAsk<cr>", desc = "Open AI/Claude on this file" },
    -- }
  },
  {
    "github/copilot.vim",
    event = "VeryLazy",
    init = function()
      --Copilot: disables by default
      vim.g.copilot_enabled = false
    end,
    -- config = function()
    --  require("copilot").setup {
    --     vim.keymap.set("n", "<leader>cn", "<Plug>(copilot-next)", { noremap = true, silent = true }),
    --     vim.keymap.set("n", "<leader>cp", "<Plug>(copilot-previous)", { noremap = true, silent = true }),
    --     vim.keymap.set("n", "<leader>cd", "<Plug>(copilot-dismiss)", { noremap = true, silent = true })
    --   }
    -- end
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    },
    keys = {
      { "<leader>ai", "<cmd>ChatGPT<cr>", desc = "Open ChatGPT" },
    }
  }
  -- local defaults = {
  --   api_key_cmd = nil,
  --   yank_register = "+",
  --   edit_with_instructions = {
  --     diff = false,
  --     keymaps = {
  --       close = "<C-c>",
  --       accept = "<C-y>",
  --       toggle_diff = "<C-d>",
  --       toggle_settings = "<C-o>",
  --       toggle_help = "<C-h>",
  --       cycle_windows = "<Tab>",
  --     }
  --   }
}
