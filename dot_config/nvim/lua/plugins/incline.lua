return {
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    enabled = false,
    config = function()
      local devicons = require "nvim-web-devicons"
      require("incline").setup {
        window = {
          padding = 0,
          margin = { horizontal = 1 },
          placement = { horizontal = "right", vertical = "top" },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified

          return {
            ft_icon and { " ", ft_icon, " " } or "",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#44406e",
            guifg = "#ffffff",
          }
        end,
      }
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
