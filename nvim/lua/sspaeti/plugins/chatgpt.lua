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
  {
    "github/copilot.vim",
    event = "VeryLazy",
    -- config = function()
      --   require("copilot").setup {
        --     vim.keymap.set("n", "<leader>cn", "<Plug>(copilot-next)", { noremap = true, silent = true }),
        --     vim.keymap.set("n", "<leader>cp", "<Plug>(copilot-previous)", { noremap = true, silent = true }),
        --     vim.keymap.set("n", "<leader>cd", "<Plug>(copilot-dismiss)", { noremap = true, silent = true })
        --   }
        -- end
      },
    }
