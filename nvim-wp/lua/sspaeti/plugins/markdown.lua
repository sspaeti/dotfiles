return {
  {
    --add handy markdown commands, and set default masOS cmd-keybindings
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      on_attach = function(bufnr)
        local function toggle(key)
          return "<Esc>gv<Cmd>lua require'markdown.inline'"
              .. ".toggle_emphasis_visual'" .. key .. "'<CR>"
        end
      end,
      -- Any other options you want to set can go here
    },
  },
  { --nice markdown inline rendering
    'MeanderingProgrammer/render-markdown.nvim',
    event = "VeryLazy",
    priority = 1000,
    ft = { "markdown" },
    opts = {},
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    keys = {
      { "<leader>mr", ":RenderMarkdown toggle<CR>", desc = "Markdown Render Toggle" }
    },
    config = function()
      require("render-markdown").setup({
        heading = {
          sign = false,
          position = "inline",
          icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
          width = 'block',
          left_pad = 2,
          right_pad = 4,
        },
        code = {
          sign = false,
          left_pad = 2,
          right_pad = 4,
          border = "thick",
        },
        bullet = { right_pad = 2 },
      })
    end,
  },
  -- {
    --"iamcco/markdown-preview.nvim", -- preview with a Browser
    --event = "VeryLazy",
    --build = function()
    --  vim.fn["mkdp#util#install"]()
    --end,
    --config = function()
    --  --VimWiki
    --  vim.cmd([[
    --  set nocompatible
    --  let g:vimwiki_list = [{'path': '~/Simon/SecondBrain', 'syntax': 'markdown', 'ext': '.md'}]
    --  let g:vimwiki_global_ext = 0 " o
    --  ]])

    --  -- Outline Shortcut
    --  vim.cmd("autocmd FileType markdown,vimwiki nmap <leader>o :SymbolsOutline<CR>")

    --  -- create WikiLink and paste clipboard as link when in visual mode
    --  vim.cmd('autocmd FileType markdown vnoremap <leader>K <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>')

    --  -- create empty wikilink when in normal mode
    --  vim.cmd("autocmd FileType markdown nmap <leader>K i[]()<Esc>hhi")

    --  -- Open file in Obsidian vault
    --  vim.cmd(
    --    "command! IO execute \"silent !open 'obsidian://open?vault=SecondBrain&file=\" . expand('%:r') . \"'\""
    --  )
    --  vim.keymap.set("n", "<leader>io", ":IO<CR>", { noremap = true, silent = true })

    --  -- Turn off autocomplete for Markdown
    --  vim.cmd("au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown")

    --  -- Highlights for headers in markdown -> doesn't really work
    --  vim.cmd([[
    --  highlight htmlH1 guifg=#50fa7b gui=bold
    --  highlight htmlH2 guifg=#ff79c6 gui=bold
    --  highlight htmlH3 guifg=#ffb86c gui=bold
    --  highlight htmlH4 guifg=#8be9fd gui=bold
    --  highlight htmlH5 guifg=#f1fa8c gui=bold
    --  ]])
    --end,
  -- },
  --{
  --  --connect with vimwiki with Obsidian Second Brain (see obsidian.lua for native plugin)
  --  --vim.opt.nocompatible = true --Recommende for VimWiki
  --  "vimwiki/vimwiki",
  --  config = function()
  --    vim.g.vimwiki_list = {
  --      {
  --        path = "~/Simon/SecondBrain",
  --        syntax = "markdown",
  --        ext = ".md",
  --      },
  --    }
  --    vim.g.vimwiki_global_ext = 0 --only mark files in the second brain as vim viki, rest are standard markdown
  --  end,
  --},
  -- , Replaced by markdown.nvim??
  -- { -- needed by 'preservim/vim-markdown'
  --   "godlygeek/tabular",
  --   event = "VeryLazy",
  -- },
  -- {
  --   -- use({ "iamcco/markdown-preview.nvim", build = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
  --   -- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
  --   "preservim/vim-markdown",
  --   event = "VeryLazy",
  -- },
}
