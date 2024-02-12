return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  event = "VeryLazy",
  config = function()
    vim.g.neo_tree_remove_legacy_commands = 1

    require("neo-tree").setup({
      enable_git_status = true,
      enable_diagnostics = false,
      window = {
        mappings = {
          ["S"] = "open_vsplit",
          ["s"] = "",
          ["E"] = "open_split",
          ["-"] = "navigate_up",
          ["h"] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' and node:is_expanded() then
              require'neo-tree.sources.filesystem'.toggle_directory(state, node)
            else
              require'neo-tree.ui.renderer'.focus_node(state, node:get_parent_id())
            end
          end,
          ["l"] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              if not node:is_expanded() then
                require'neo-tree.sources.filesystem'.toggle_directory(state, node)
              elseif node:has_children() then
                require'neo-tree.ui.renderer'.focus_node(state, node:get_child_ids()[1])
              end
            end
          end,
        }
      }
    })
  end
}
