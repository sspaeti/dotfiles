return {
  {
    "iamcco/markdown-preview.nvim",
    event = "VeryLazy",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      --VimWiki
      vim.cmd([[
      set nocompatible
      let g:vimwiki_list = [{'path': '~/Simon/Sync/SecondBrain', 'syntax': 'markdown', 'ext': '.md'}]
      let g:vimwiki_global_ext = 0 " o
      ]])

      -- Outline Shortcut
      vim.cmd("autocmd FileType markdown,vimwiki nmap <leader>o :SymbolsOutline<CR>")

      -- create WikiLink and paste clipboard as link when in visual mode
      vim.cmd('autocmd FileType markdown vnoremap <leader>K <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>')

      -- create empty wikilink when in normal mode
      vim.cmd("autocmd FileType markdown nmap <leader>K i[]()<Esc>hhi")

      -- Open file in Obsidian vault
      vim.cmd(
      "command! IO execute \"silent !open 'obsidian://open?vault=SecondBrain&file=\" . expand('%:r') . \"'\""
      )
      vim.keymap.set("n", "<leader>io", ":IO<CR>", { noremap = true, silent = true })

      -- Turn off autocomplete for Markdown
      vim.cmd("au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown")

      -- Highlights for headers in markdown -> doesn't really work
      vim.cmd([[
      highlight htmlH1 guifg=#50fa7b gui=bold
      highlight htmlH2 guifg=#ff79c6 gui=bold
      highlight htmlH3 guifg=#ffb86c gui=bold
      highlight htmlH4 guifg=#8be9fd gui=bold
      highlight htmlH5 guifg=#f1fa8c gui=bold
      ]])
    end,
  },
  --{
  --  --connect with Obsidian Second Brain
  --  --vim.opt.nocompatible = true --Recommende for VimWiki
  --  "vimwiki/vimwiki",
  --  config = function()
  --    vim.g.vimwiki_list = {
  --      {
  --        path = "~/Simon/Sync/SecondBrain",
  --        syntax = "markdown",
  --        ext = ".md",
  --      },
  --    }
  --    vim.g.vimwiki_global_ext = 0 --only mark files in the second brain as vim viki, rest are standard markdown
  --  end,
  --},
  {
    --Markdown (or any Outline)
    "simrat39/symbols-outline.nvim",
    event = "VeryLazy",
    config = function()
      local opts = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = { -- These keymaps can be a string or a table for multiple keys
          close = {"<Esc>", "q"},
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
          File = {icon = "", hl = "TSURI"},
          Module = {icon = "", hl = "TSNamespace"},
          Namespace = {icon = "", hl = "TSNamespace"},
          Package = {icon = "", hl = "TSNamespace"},
          Class = {icon = "𝓒", hl = "TSType"},
          Method = {icon = "ƒ", hl = "TSMethod"},
          Property = {icon = "", hl = "TSMethod"},
          Field = {icon = "", hl = "TSField"},
          Constructor = {icon = "", hl = "TSConstructor"},
          Enum = {icon = "ℰ", hl = "TSType"},
          Interface = {icon = "ﰮ", hl = "TSType"},
          Function = {icon = "", hl = "TSFunction"},
          Variable = {icon = "", hl = "TSConstant"},
          Constant = {icon = "", hl = "TSConstant"},
          String = {icon = "𝓐", hl = "TSString"},
          Number = {icon = "#", hl = "TSNumber"},
          Boolean = {icon = "⊨", hl = "TSBoolean"},
          Array = {icon = "", hl = "TSConstant"},
          Object = {icon = "⦿", hl = "TSType"},
          Key = {icon = "🔐", hl = "TSType"},
          Null = {icon = "NULL", hl = "TSType"},
          EnumMember = {icon = "", hl = "TSField"},
          Struct = {icon = "𝓢", hl = "TSType"},
          Event = {icon = "🗲", hl = "TSType"},
          Operator = {icon = "+", hl = "TSOperator"},
          TypeParameter = {icon = "𝙏", hl = "TSParameter"}
        }
      }

      require("symbols-outline").setup({
          sources = opts,
      })
    end
  },
  { -- needed by 'preservim/vim-markdown'
  "godlygeek/tabular",
  event = "VeryLazy",
},
{
  -- use({ "iamcco/markdown-preview.nvim", build = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
  -- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
  "preservim/vim-markdown",
  event = "VeryLazy",
},
}
