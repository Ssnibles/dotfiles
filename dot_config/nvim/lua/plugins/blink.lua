return {
  -- TODO:
  "saghen/blink.cmp",
  version = "^1.0.0", -- Pin to major version (adjust based on latest release)
  dependencies = {
    "rafamadriz/friendly-snippets",
    "L3MON4D3/LuaSnip",
  },
  opts = {
    keymap = {
      preset = "super-tab",
    },
    appearance = {
      nerd_font_variant = "mono", -- Ensure your terminal uses a Nerd Font
    },
    completion = {
      menu = {
        auto_show = true,
        border = "single",
        draw = {
          align_to = "label",
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "single" },
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
      implementation = "rust", -- Updated to stable Rust implementation
    },
    signature = {
      enabled = true,
      trigger = {
        enabled = true, -- Auto show
      },
      window = {
        border = "single",
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        path = {
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
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    -- Load snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
