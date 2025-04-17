return {
  "nvim-lualine/lualine.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = {
          "alpha",
          "dashboard",
          "NvimTree",
          "neo-tree",
          "snacks_dashboard",
          "snacks_picker_input",
        },
        winbar = {},
      },
      globalstatus = true,
      refresh = { statusline = 100 },
    },
    sections = {
      lualine_a = {
        "mode",
        function()
          if vim.fn.reg_recording() ~= "" then
            return "[REC " .. vim.fn.reg_recording() .. "]"
          else
            return "Nil"
          end
        end,
      },
      lualine_b = { "branch" },
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = { modified = "[+]", readonly = "[RO]" },
          padding = { left = 1, right = 0 },
        },
      },
      lualine_x = {
        function()
          return " "
            .. table.concat(
              vim.tbl_map(function(c)
                return c.name
              end, vim.lsp.get_active_clients()),
              "|"
            )
        end,
        "filetype",
      },
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
