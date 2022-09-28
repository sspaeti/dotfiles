require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
        { key = "s", action = "" },
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    actions = {
      expand_all = {
        max_folder_discovery = 300,
      },
    },
  },
  git = {
    ignore = false
  }
})

