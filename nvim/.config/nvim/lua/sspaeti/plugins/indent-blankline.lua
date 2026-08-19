return {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main = "ibl",
  config = function()
    -- derive stripe colors from the active theme's Normal bg: stripe 1 is the
    -- plain background, stripe 2 slightly lighter (dark) / darker (light)
    local function set_ibl_hl()
      local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      if not bg then return end -- transparent background: keep plugin defaults
      local r = math.floor(bg / 65536) % 256
      local g = math.floor(bg / 256) % 256
      local b = bg % 256
      local function shift(amount)
        local function s(v) return math.min(255, math.max(0, v + amount)) end
        return string.format("#%02x%02x%02x", s(r), s(g), s(b))
      end
      -- direction from actual bg luminance: some light themes (e.g. omarchy's
      -- aether-based ones) never set vim.o.background=light
      local luminance = 0.299 * r + 0.587 * g + 0.114 * b
      local amount = luminance > 127 and -12 or 10
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { bg = shift(0) })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { bg = shift(amount) })
    end
    set_ibl_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("IblCustomHighlights", { clear = true }),
      callback = set_ibl_hl,
    })
    require("ibl").setup({
      indent = { char = " " },
      whitespace = {
        highlight = { "IndentBlanklineIndent1", "IndentBlanklineIndent2" },
        remove_blankline_trail = true,
      },
      scope = { enabled = false },
    })
  end,
}
