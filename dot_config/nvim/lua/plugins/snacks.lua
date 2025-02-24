return {
  "folke/snacks.nvim",
  event = "VimEnter",
  opts = {
    dim = {
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
      animate = { enabled = false },
    },
    notifier = {
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
    },
    indent = {
      priority = 1,
      char = "│",
      scope = {
        enabled = false,
        show_start = false,
        show_end = false,
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    require("snacks").dim(opts)
    -- require("snacks").indent(opts)
  end
}
