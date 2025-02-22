return {
  "folke/noice.nvim",
  -- enabled = false,
  config = function()
    require("noice").setup({
      cmdline = {
        view = "cmdline_popup",
        position = {
          row = "50%",
          col = "50%",
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = "25%",
            col = "50%",
          },
          size = {
            width = "auto",
            height = "auto",
          },
        },
      },
    })
  end,
}

