return {
  "OXY2DEV/markview.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  keys = {
    { "<leader>mm", "<cmd>Markview Toggle<CR>",    desc = "Toggle Markview" },
    { "<leader>ms", "<cmd>Markview Splitview<CR>", desc = "Markview Splitview" },
  },
  opts = {
    preview = {
      enable = true,
      filetypes = { "markdown", "rmd", "quarto", "typst" },
      modes = { "n", "v" },
    },
    markdown = {
      code_block = {
        enable = true,
        theme = "rose-pine-moon",
      },
      math = {
        enable = true,
      },
      tables = {
        enable = true,
        default = {
          border = "rounded",
        },
      },
    },
    highlight_groups = {
      markview_heading = { bold = true, fg = "#61afef" },
      markview_bold = { bold = true, fg = "#e5c07b" },
      markview_italic = { italic = true, fg = "#98c379" },
      markview_link = { underline = true, fg = "#56b6c2" },
    },
    experimental = {
      link_open_alerts = true,
    },
  },
}
