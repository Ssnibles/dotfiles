return {
  "saghen/blink.cmp",
  event = "LspAttach",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "*",
  opts = {
    keymap = {
      preset = "super-tab",
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        border = "single", -- none, single, double, rounded, solid
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "single" }, -- none, single, double, rounded, solid
      },
      ghost_text = {
        enabled = true,
      },
    },
    cmdline = {
      enabled = true,
      completion = {
        menu = {
          auto_show = true,
        },
      },
      keymap = {
        preset = "super-tab",
      },
    },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
    signature = {
      window = { border = "single" }, -- none, single, double, rounded, solid
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },

      -- per_filetype = { sql = { 'dadbod' } }
      -- providers = {
      --   dadbod = {
      --     name = "Dadbod",
      --     module = "vim_dadbod_completion.blink",
      --   },
      -- }
    },
  },
}
