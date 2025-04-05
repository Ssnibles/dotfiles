return {
  "nvim-neorg/neorg",
  ft = { "norg", "neorg" },
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "danymat/neogen", -- For enhanced documentation
  },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},

        -- Workspace Management
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/Notes",
              work = "~/Work/Notes",
              projects = "~/Projects",
            },
            default_workspace = "notes",
            index = "index.norg",
          },
        },

        -- Enhanced Completion (Blink.nvim compatible)
        ["core.completion"] = {
          config = {
            engine = function()
              return {
                name = "blink",
                -- Custom completion sources for Blink
                sources = {
                  { name = "neorg" }, -- Neorg-native completion
                  { name = "luasnip" }, -- Snippet completions
                  { name = "path" }, -- File paths
                  { name = "emoji" }, -- Markdown-style emojis
                },
                formatting = {
                  format = function(entry, vim_item)
                    if entry.source.name == "neorg" then
                      vim_item.menu = "[Neorg]"
                    end
                    return vim_item
                  end,
                },
              }
            end,
          },
        },

        -- UI Enhancements
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
            folds = true,
            dim_code_blocks = {
              enabled = true,
              content_only = true,
            },
          },
        },

        -- Task Management
        ["core.todo"] = {
          config = {
            keywords = {
              TODO = { icon = " ", color = "warning" },
              FIX = { icon = " ", color = "error" },
              HACK = { icon = " ", color = "warning" },
              NOTE = { icon = " ", color = "hint" },
            },
          },
        },

        -- Snippet Integration
        ["core.integrations.luasnip"] = {},

        -- Keybindings
        ["core.keybinds"] = {
          config = {
            hook = function(keybinds)
              keybinds.map_event("norg", "n", "<C-Space>", "core.completion.complete")
              keybinds.map_event("norg", "i", "<C-l>", "core.integrations.luasnip.expand")
            end,
          },
        },

        -- Documentation Generator
        ["core.integrations.neogen"] = {
          config = {
            enabled = true,
            template = {
              norg = {
                annotation_convention = "norg", -- Custom convention
              },
            },
          },
        },

        -- Remaining Modules (unchanged from previous config)
        ["core.export"] = {},
        ["core.export.markdown"] = {},
        ["core.journal"] = {
          config = {
            workspace = "notes",
            journal_folder = "journal",
          },
        },
        ["core.presenter"] = {
          config = {
            zen_mode = true,
          },
        },
        ["core.integrations.telescope"] = {},
        ["core.summary"] = {},
      },
    })

    -- Blink.nvim specific mappings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "norg",
      callback = function()
        vim.keymap.set("i", "<Tab>", function()
          if require("blink").visible() then
            return "<C-n>"
          else
            return "<Tab>"
          end
        end, { expr = true })

        vim.keymap.set("i", "<S-Tab>", function()
          if require("blink").visible() then
            return "<C-p>"
          else
            return "<S-Tab>"
          end
        end, { expr = true })
      end,
    })
  end,
}
