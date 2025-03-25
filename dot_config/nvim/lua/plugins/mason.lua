return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason (Package Manager)" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
          border = "rounded",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Base capabilities (adjusted for blink.cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- Enhanced on_attach with better keymap descriptions
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, {
            buffer = bufnr,
            desc = "LSP: " .. desc,
            silent = true,
            noremap = true,
          })
        end

        -- Navigation
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "gr", vim.lsp.buf.references, "Goto References")
        map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")

        -- Code actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

        -- Formatting
        map("n", "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "Format Document")

        -- Signature help
        if client.supports_method("textDocument/signatureHelp") then
          map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature Help")
        end
      end

      -- Common configuration with performance flags
      local common_setup = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          "gopls",
          "ts_ls",
          "clangd",
          "bashls",
          "taplo",
          "marksman",
          "texlab",
          "eslint",
          "html",
        },
        handlers = {
          -- Default handler
          function(server_name)
            lspconfig[server_name].setup(common_setup)
          end,

          -- Server-specific overrides
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common_setup, {
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  telemetry = { enable = false },
                },
              },
            }))
          end,

          ["ts_ls"] = function()
            lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", common_setup, {
              root_dir = util.root_pattern("package.json", "tsconfig.json"),
              single_file_support = false,
            }))
          end,

          ["rust_analyzer"] = function()
            lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", common_setup, {
              settings = {
                ["rust-analyzer"] = {
                  cargo = { allFeatures = true },
                  checkOnSave = {
                    command = "clippy",
                    extraArgs = { "--no-deps" },
                  },
                },
              },
            }))
          end,

          ["texlab"] = function()
            lspconfig.texlab.setup(vim.tbl_deep_extend("force", common_setup, {
              filetypes = { "tex", "bib", "markdown" },
              root_dir = util.root_pattern(".git", "main.tex", "Makefile"),
              settings = {
                texlab = {
                  build = {
                    args = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
                    executable = "latexmk",
                    forwardSearchAfter = true,
                    onSave = true,
                  },
                },
              },
            }))
          end,

          ["gopls"] = function()
            lspconfig.gopls.setup(vim.tbl_deep_extend("force", common_setup, {
              settings = {
                gopls = {
                  analyses = {
                    unusedparams = true,
                  },
                  staticcheck = true,
                  gofumpt = true,
                },
              },
            }))
          end,

          ["clangd"] = function()
            lspconfig.clangd.setup(vim.tbl_deep_extend("force", common_setup, {
              cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
              },
            }))
          end,
        },
      })
    end,
  },
}
