return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {

    -- Customising routes
    routes = {
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },

    -- Customising views
    views = {
      cmdline_popup = { -- The nice cmdline UI
        size = {
          width = 60,
          height = "auto",
        },
        border = {
          style = "rounded", -- single, rounded, double, none
          padding = { 0, 1 },
        },
        position = {
          row = 0.3,
          col = "50%",
        },
      },
    },

    cmdline = {
      enabled = true,
      format = { -- Set icons for each component
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
        -- lua = false, -- to disable a format, set to `false`
      },
    },

    messages = { -- Message view
      enabled = true,
    },

    command = { -- Options for noice.nvim command
      history = {
        view = "split",
      },
    },

    lsp = {
      hover = { enabled = false },
      signature = { enabled = false },
    }
  },
}
