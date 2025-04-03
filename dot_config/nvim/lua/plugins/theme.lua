-- make sure the plugin is loaded before all others VERY IMPORTANT for correct colours
return {
  {
    "rose-pine/neovim",
    -- enabled = false,
    priority = 1000,
    name = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end,
  },
  {
    "vague2k/vague.nvim",
    enabled = false,
    priority = 1000,
    name = "vague",
    config = function()
      require("vague").setup({
        vim.cmd("colorscheme vague"),
      })
    end,
  },
}
