return {
  "OXY2DEV/markview.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local presets = require("markview.presets")
    require("markview").setup({
      markdown = {
        headings = presets.headings.marker,
        horizontal_rules = presets.horizontal_rules.dashed,
        tables = presets.tables.rounded,
      },
      latex = {
        enable = false,
      },
    })
  end,
}
