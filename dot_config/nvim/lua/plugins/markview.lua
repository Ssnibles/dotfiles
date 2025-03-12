return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local presets = require("markview.presets")
    require("markview").setup({
      markdown = {
        headings = presets.headings.arrowed,
        horizontal_rules = presets.horizontal_rules.dashed,
        tables = presets.checkboxes.nerd,
      },
      latex = {
        enable = false,
      },
    })
  end,
}
