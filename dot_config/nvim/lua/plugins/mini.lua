return {
  -- TODO:
  {
    "echasnovski/mini.nvim",
    version = false,
    -- event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Basic setup for some commonly used mini modules

      require("mini.ai").setup({
        custom_textobjects = nil,
        mappings = {
          around = "a",
          inside = "i",
          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",
          -- Move cursor to corresponding edge of `a` textobject
          goto_left = "g[",
          goto_right = "g]",
        },
      })

      require("mini.align").setup({
        mappings = {
          start = "ga",
          start_with_preview = "gA",
        },
        -- Default options controlling alignment process
        options = {
          split_pattern = "",
          justify_side = "left",
          merge_delimiter = "",
        },
        -- Default steps performing alignment (if `nil`, default is used)
        steps = {
          pre_split = {},
          split = nil,
          pre_justify = {},
          justify = nil,
          pre_merge = {},
          merge = nil,
        },
      })

      require("mini.comment").setup()
      require("mini.cursorword").setup()
      require("mini.pairs").setup()
      require("mini.statusline").setup()
      require("mini.operators").setup()

      require("mini.surround").setup({
        mappings = {
          add = "sa",            -- Add surrounding in Normal and Visual modes
          delete = "sd",         -- Delete surrounding
          find = "sf",           -- Find surrounding (to the right)
          find_left = "sF",      -- Find surrounding (to the left)
          highlight = "sh",      -- Highlight surrounding
          replace = "sr",        -- Replace surrounding
          update_n_lines = "sn", -- Update `n_lines`

          suffix_last = "l",     -- Suffix to search with "prev" method
          suffix_next = "n",     -- Suffix to search with "next" method
        },
      })

      -- require("mini.jump").setup({
      --   -- Module mappings. Use `''` (empty string) to disable one.
      --   mappings = {
      --     forward = "f",
      --     backward = "F",
      --     forward_till = "t",
      --     backward_till = "T",
      --     repeat_jump = ";",
      --   },
      -- })

      -- require("mini.jump2d").setup({
      --   -- Characters used for labels of jump spots (in supplied order)
      --   labels = "abcdefghijklmnopqrstuvwxyz",
      --   -- Options for visual effects
      --   view = {
      --     -- Whether to dim lines with at least one jump spot
      --     dim = false,
      --     -- How many steps ahead to show. Set to big number to show all steps.
      --     n_steps_ahead = 0,
      --   },
      --   -- Which lines are used for computing spots
      --   allowed_lines = {
      --     blank = true,         -- Blank line (not sent to spotter even if `true`)
      --     cursor_before = true, -- Lines before cursor line
      --     cursor_at = true,     -- Cursor line
      --     cursor_after = true,  -- Lines after cursor line
      --     fold = true,          -- Start of fold (not sent to spotter even if `true`)
      --   },
      --   -- Which windows from current tabpage are used for visible lines
      --   allowed_windows = {
      --     current = true,
      --     not_current = true,
      --   },
      --   -- Functions to be executed at certain events
      --   hooks = {
      --     before_start = nil, -- Before jump start
      --     after_jump = nil,   -- After jump was actually done
      --   },
      --   -- Module mappings. Use `''` (empty string) to disable one.
      --   mappings = {
      --     start_jumping = "<CR>",
      --   },
      -- })

      require("mini.move").setup({
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = "<M-h>",
          right = "<M-l>",
          down = "<M-j>",
          up = "<M-k>",
          -- Move current line in Normal mode
          line_left = "<M-h>",
          line_right = "<M-l>",
          line_down = "<M-j>",
          line_up = "<M-k>",
        },
        -- Options which control moving behavior
        options = {
          -- Automatically reindent selection during linewise vertical move
          reindent_linewise = true,
        },
      })
    end,
  },
}
