return {
  {
    dir = '~/git/neovim/agents-ide.nvim',
    name = 'agent-ide.nvim',
    build = 'make helper',
    cmd = 'Agents',
    keys = { { '<leader>aa', '<cmd>Agents<cr>', desc = 'Agent-IDE: toggle drawer' } },
    opts = {
      prompts = { library_dir = '~/git/skills/my-skills/prompts' },
      quota = { file = '~/.local/state/omarchy/agents/usage/claude.json' },
      scope = 'project',
    },
  },
}
