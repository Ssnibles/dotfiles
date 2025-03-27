return {
  "shortcuts/no-neck-pain.nvim",
  version = "*",
  cmd = "NoNeckPain",
  keys = {
    {
      "<leader>np",
      "<Cmd>NoNeckPain<CR>",
      mode = { "n" },
      desc = "Toggle NoNeckPain"
    },
  },
  opts = {
    buffers = {
      right = {
        enabled = true,
      },
      left = {
        enabled = true,
      }
    },
  }
}
