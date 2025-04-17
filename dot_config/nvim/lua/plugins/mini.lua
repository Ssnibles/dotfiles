return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Text objects with extended navigation
      require("mini.ai").setup({
        mappings = {
          around = "a",
          inside = "i",
          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",
          goto_left = "g[",
          goto_right = "g]",
        },
      })

      -- Advanced text alignment
      require("mini.align").setup({
        mappings = {
          start = "ga",
          start_with_preview = "gA",
        },
        options = {
          split_pattern = "",
          justify_side = "left",
          merge_delimiter = "",
        },
      })

      -- Surround operations (new addition)
      require("mini.surround").setup({
        mappings = {
          add = "sa",       -- Add surrounding
          delete = "sd",    -- Delete surrounding
          find = "sf",      -- Find right
          find_left = "sF", -- Find left
          highlight = "sh", -- Highlight
          replace = "sr",   -- Replace
          update_n_lines = "sn",
          suffix_last = "l",
          suffix_next = "n",
        },
      })

      -- Intuitive text movement
      require("mini.move").setup({
        mappings = {
          left = "<M-h>",
          right = "<M-l>",
          down = "<M-j>",
          up = "<M-k>",
          line_left = "<M-h>",
          line_right = "<M-l>",
          line_down = "<M-j>",
          line_up = "<M-k>",
        },
        options = {
          reindent_linewise = true,
        },
      })

      -- Essential quality-of-life modules
      require("mini.comment").setup()
      require("mini.cursorword").setup()
      require("mini.pairs").setup()
      require("mini.operators").setup()
    end,
  },
}
