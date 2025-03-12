return {
  "folke/zen-mode.nvim",
  keys = { { "<leader>zz", "<cmd>ZenMode<CR>" }, },
  config = function()
    require("zen-mode").setup({
      window = {
        width = 1.00,
      },
    })
  end,
}
