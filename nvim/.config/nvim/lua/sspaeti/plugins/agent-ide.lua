return {
  {
    dir = '~/git/neovim/agents-ide.nvim',
    name = 'agent-ide.nvim',
    build = 'make helper',
    cmd = 'Agents',
    keys = { { '<leader>aa', '<cmd>Agents<cr>', desc = 'Agent-IDE: toggle drawer' } },
    opts = {
      -- the mise shim, not plain `claude`: PATH in nvim and tmux panes finds the omarchy
      -- wrapper (~/.local/bin/claude) first, which exec-loops through `mise use -g`
      claude = { cmd = { vim.fn.expand('~/.local/share/mise/shims/claude') } },
      live = { cmd = { vim.fn.expand('~/.local/share/mise/shims/claude'), 'agents', '--json' } },
      prompts = { library_dir = '~/git/skills/my-skills/prompts' },
      quota = { file = '~/.local/state/omarchy/agents/usage/claude.json' },
      scope = 'project',
      sound = { waiting = true, chime = 'soft', cmd = nil },
    },
  },
}
