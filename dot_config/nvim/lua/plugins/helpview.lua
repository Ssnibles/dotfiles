return {
  {
    enabled = false,
    "oxy2dev/helpview.nvim",
    config = function()
      require("helpview").setup({
        preview = {
          enable = true,
          enable_hybrid_mode = true,

          modes = { "n", "c", "no" },
          hybrid_modes = {},
          linewise_hybrid_mode = false,

          filetypes = { "help" },
          ignore_previews = {},
          ignore_buftypes = {},
          condition = nil,

          max_buf_lines = 500,
          draw_range = { 2 * vim.o.lines, 2 * vim.o.lines },
          edit_range = { 0, 0 },

          debounce = 150,
          callbacks = {},

          icon_provider = "devicons",

          splitview_winopts = { split = "right" },
          preview_winopts = { width = math.floor(80) },
          overlay_winopts = { width = math.floor(80) },
        },
        vimdoc = {
          arguments = {
            enable = true,

            default = {
              hl = "Argument",
              padding_left = " ",
              padding_right = " ",
            },
          },
          -- set opts for code blocks
          code_blocks = {
            enable = true,

            border_hl = "Code",

            default = { block_hl = "HelpviewCode" },

            ["diff"] = {
              block_hl = function(_, line)
                if line:match("^%s*%+") then
                  return "HelpviewPalette4"
                elseif line:match("^%s*%-") then
                  return "HelpviewPalette1"
                else
                  return "HelpviewCode"
                end
              end,
            },
          },
          -- set opts for headings
          headings = {
            enable = true,

            heading_1 = {
              sign = " ⣾⣿⠛⣿⣷ ",
              sign_hl = "Palette1Inv",

              marker_hl = "Palette1Bg",

              hl = "Palette1Fg",
            },

            heading_2 = {
              sign = " ⣠⠞⠛⠳⣄ ",
              sign_hl = "Palette2Inv",

              marker_hl = "Palette2",
              hl = "Palette2Fg",
            },

            heading_3 = {
              sign = " ⣯⣤⠛⣤⣽ ",
              sign_hl = "Palette3Inv",

              marker_hl = "Palette3",
              hl = "Palette3",
            },

            heading_4 = {
              sign = " ⠓⣠⣿⣄⠚ ",
              sign_hl = "Palette4Inv",

              marker_hl = "Palette4",
              hl = "Palette4",
            },
          },
        },
      })
      -- Quality of life mappings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "help",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "q", "<CMD>q<CR>", opts)
          vim.keymap.set("n", "<Esc>", "<CMD>q<CR>", opts)
          vim.keymap.set("n", "<CR>", "<C-]>", opts) -- Better link navigation
        end,
      })
    end,
  },
}
