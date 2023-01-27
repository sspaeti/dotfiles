require("neo-tree").setup({
  window = {
    mappings = {
      ["S"] = "open_vsplit",
      ["s"] = "",
      ["E"] = "open_split",
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

