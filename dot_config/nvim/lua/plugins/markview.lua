return {
  "OXY2DEV/markview.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>mtc", "<Cmd>Checkbox<CR>", desc = "Toggle Checkboxes" },
    { "<leader>mhi", "<Cmd>Heading increase<CR>", desc = "Increase Heading" },
    { "<leader>mhd", "<Cmd>Heading decrease<CR>", desc = "Decrease Heading" },
  },
  config = function()
    local presets = require("markview.presets")
    require("markview").setup({
      markdown = {
        headings = presets.headings.glow,
        horizontal_rules = presets.horizontal_rules.dashed,
        tables = presets.tables.rounded,
        code_blocks = {
          enable = true,
          style = "simple",
          label_direction = "right",
        },
      },
      latex = { enable = false },
      preview = { icon_provider = "devicons" },
      checkboxes = {
        default = "X",
        states = {
          { " ", "/", "X" },
          { "<", ">" },
          { "?", "!", "*" },
          { '"' },
          { "l", "b", "i" },
          { "S", "I" },
          { "p", "c" },
          { "f", "k", "w" },
          { "u", "d" },
        },
      },
      extraHeadings = {},
    })
  end,
}
