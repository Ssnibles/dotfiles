-- make sure the plugin is loaded before all others VERY IMPORTANT for correct colours
return {
  "rose-pine/neovim",
  priority = 1000,
  name = "rose-pine",
  config = function()
    vim.cmd("colorscheme rose-pine-moon")
  end,
}
