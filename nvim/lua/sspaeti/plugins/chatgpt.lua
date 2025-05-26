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
    lazy = false,
    priority = 1005,
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
        ---Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        provider = "claude",
        hints = { enabled = false },
        -- for MCPhub
        -- system_prompt as function ensures LLM always has latest MCP server state
        -- This is evaluated for every message, even in existing chats
        system_prompt = function()
          local hub = require("mcphub").get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ""
        end,
        -- Using function prevents requiring mcphub before it's loaded
        custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end,
      })
    end,
    -- keys = {
    --   { "<leader>ai", "<cmd>AvanteAsk<cr>", desc = "Open AI/Claude on this file" },
    -- }
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end
  },


  --
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
  },
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
  { --requires brew install chatblade (https://github.com/npiv/chatblade)
    "cmpadden/chatblade.nvim",
    keys = {
      { "<leader>ac", ":Chatblade",                 mode = "v" },
      -- Keymap to start a chat session
      { "<leader>cs", ":ChatbladeSessionStart<CR>", mode = "n", desc = "Start Chatblade session" },
      -- Keymap to stop a chat session
      { "<leader>ce", ":ChatbladeSessionStop<CR>",  mode = "n", desc = "Stop Chatblade session" },
    },
    cmd = {
      "Chatblade",
      "ChatbladeSessionStart",
      "ChatbladeSessionStop",
      "ChatbladeSessionDelete",
    },
    opts = {
      prompt            = "programmer",
      raw               = true,
      extract           = true,
      only              = true,
      temperature       = 0.8,
      include_filetype  = true,
      insert_as_comment = true,
    }
  }
}
