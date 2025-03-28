return {
  "saghen/blink.cmp",
  version = "*",                                     -- set to latest version at all times
  -- event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" }, -- declare snippet providers
  -- set options
  opts = {
    keymap = {
      preset = "super-tab", -- VS code like, eg arrow keys to move up and down, and tab to select
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        auto_show = true,
        border = "rounded",
        draw = {
          align_to = "label", -- none, lable, or cursor
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "rounded" },
        treesitter_highlighting = true,
      },
      ghost_text = {
        enabled = true,
      },
      accept = {
        create_undo_point = true,
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
      enabled = true,
      window = {
        border = "rounded",
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        path = {
          module = "blink.cmp.sources.path",
          score_offset = 3,
          fallbacks = { "buffer" },
          opts = {
            trailing_slash = true,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
            end,
            show_hidden_files_by_default = true,
          },
        },
      },
    },
  },
}
