return {
  "saghen/blink.cmp",
  version = "*",
  -- event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      preset = "super-tab",
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        border = "none",
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "none" },
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
      window = { border = "none" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
