return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      -- component_separators = { left = "◆", right = "◆" },
      -- section_separators = { left = "", right = "" },

      component_separators = { left = "◆", right = "◆" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "alpha", "dashboard", "NvimTree", "neo-tree", "snacks_dashboard", "snacks_picker_input" },
        winbar = {},
      },
      globalstatus = true,
      refresh = { statusline = 100 },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = { modified = "", readonly = "" },
        },
      },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "nvim-tree" },
  },
}
