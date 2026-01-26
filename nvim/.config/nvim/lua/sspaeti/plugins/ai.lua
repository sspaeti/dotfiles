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
  --     "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim",
  --   },
  -- },
  --
  {
    "yetone/avante.nvim",
    lazy = false,
    priority = 1005,
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
        provider = "gemini",
        selection = {
          enabled = false, -- This disables the visual mode inline hints!
        },
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
  },
  {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")

      -- SSP: Workaround: Ensure tmp directory exists (plugin bug - should create automatically)
      local tmp_dir = vim.uv.cwd() .. "/tmp"
      if vim.fn.isdirectory(tmp_dir) == 0 then
        vim.fn.mkdir(tmp_dir, "p")
      end

      -- For logging that is to a file if you wish to trace through requests
      -- for reporting bugs, i would not rely on this, but instead the provided
      -- logging mechanisms within 99.  This is for more debugging purposes
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup({
        logger = {
          level = _99.DEBUG,
          path = "/tmp/" .. basename .. ".99.debug",
          print_on_error = true,
        },

        --- A new feature that is centered around tags
        completion = {
          --- Defaults to .cursor/rules
          cursor_rules = "<custom path to cursor rules>",

          --- A list of folders where you have your own agents
          custom_rules = {
            "scratch/custom_rules/",
          },

          --- What autocomplete do you use.  We currently only
          --- support cmp right now
          source = "cmp",

        },

        --- WARNING: if you change cwd then this is likely broken
        --- ill likely fix this in a later change
        ---
        --- md_files is a list of files to look for and auto add based on the location
        --- of the originating request.  That means if you are at /foo/bar/baz.lua
        --- the system will automagically look for:
        --- /foo/bar/AGENT.md
        --- /foo/AGENT.md
        --- assuming that /foo is project root (based on cwd)
        md_files = {
          "AGENT.md",
        },
      })

      -- Create your own short cuts for the different types of actions
      vim.keymap.set("n", "<leader>9f", function()
        _99.fill_in_function()
      end)
      -- take extra note that i have visual selection only in v mode
      -- technically whatever your last visual selection is, will be used
      -- so i have this set to visual mode so i dont screw up and use an
      -- old visual selection
      --
      -- likely ill add a mode check and assert on required visual mode
      -- so just prepare for it now
      vim.keymap.set("v", "<leader>9v", function()
        _99.visual()
      end)

      --- if you have a request you dont want to make any changes, just cancel it
      vim.keymap.set("v", "<leader>9s", function()
        _99.stop_all_requests()
      end)

      --- Example: Using rules + actions for custom behaviors
      --- Create a rule file like ~/.rules/debug.md that defines custom behavior.
      --- For instance, a "debug" rule could automatically add printf statements
      --- throughout a function to help debug its execution flow.

      vim.keymap.set("n", "<leader>9fd", function()
        _99.fill_in_function()
      end)
    end,
  }
}
