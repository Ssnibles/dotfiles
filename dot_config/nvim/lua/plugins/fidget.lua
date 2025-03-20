return {
  "j-hui/fidget.nvim",
  -- enabled = false,
  event = "LspAttach",
  opts = {
    notification = {
      window = {
        winblend = 1,
      },
    },
    progress = {
      ignore = { "^null-ls" },
    },
  },
}
