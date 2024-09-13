return {
  --use with treesitter `autotag` to auto close and auto rename html tag
  event = {
    "BufReadPre",
    "BufNewFile"
  },
  "windwp/nvim-ts-autotag"
}
