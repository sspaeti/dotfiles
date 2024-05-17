return
{
  "nvim-telescope/telescope.nvim",
  -- event = "VeryLazy",
  lazy = false,
  priority = 1000,
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ft", "<cmd>Telescope resume<cr>", desc = "Resume Telescope" },
    -- {
    --   "<leader>ff",
    --   function() require("telescope.builtin").find_files({}) end,
    --   desc = "Find Plugin File",
    -- },
    {
      "sp", --> fzf: c-p see in remap.lua
      function()
        local is_git = os.execute('git') == 0
        if is_git then
          require("telescope.builtin").git_files()
        else
          require("telescope.builtin").find_files()
        end
      end,
      desc = "Find Open Files",
    },
    {
      "<leader>fg",
      function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end,
      desc = "Grep String",
    },
    {
      "<leader>?",
      function() require("telescope.builtin").keymaps({}) end,
      desc = "Telescope: Grep Keymaps",
    },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope Help Tags" },
    ----lsp
    --{"gr", function() require("telescope.builtin").lsp_references() end, desc = "Telescope LSP References" },
    --{"gC", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Telescope LSP Document Symbols" },
  },
  opts = {},
  config = function()
    require("telescope").setup({
      defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case'
          },
        },
    })

    local builtin = require 'telescope.builtin'

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>f/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })


    -- Shortcut for searching your neovim configuration files
    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
