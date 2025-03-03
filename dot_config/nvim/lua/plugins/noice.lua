return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = { -- Overriding default options
    -- Customizing presets
    presets = {
      bottom_search = false,        -- Use a classic bottom cmdline for search
      command_palette = false,      -- Position the cmdline and popupmenu together
      long_message_to_split = true, -- Send long messages to a split
      inc_rename = true,            -- Enables an input dialog for inc-rename.nvim
      lsp_doc_border = false,       -- Add a border to hover docs and signature help
    },
    -- Customizing routes
    routes = {
      {
        -- Hide written messages
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
    -- Customizing views
    views = {
      -- Customize the cmdline_popup view
      cmdline_popup = {
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
        border = {
          style = "single",
          padding = { 0, 1 },
        },
      },
      -- Customize the popupmenu view
      popupmenu = {
        relative = "editor",
        position = {
          row = 8,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "single",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
  },
}
