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
        border = "single",
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "single" },
      },
    },
    signature = {
      window = { border = "single" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
