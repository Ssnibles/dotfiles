return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
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
          check_outdated_packages_on_open = false,
        },
        max_concurrent_installers = 4,
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
      local util = require("lspconfig/util")

      -- Diagnostic signs setup
      local signs = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Enhanced capabilities for blink.cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem = {
        snippetSupport = true,
        preselectSupport = true,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
          },
        },
      }
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- Unified on_attach function
      local on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, {
            buffer = bufnr,
            desc = "LSP: " .. desc,
            silent = true,
            noremap = true,
          })
        end

        -- Navigation using snacks.picker
        map("n", "gd", function()
          require("snacks.lsp").definitions()
        end, "Goto Definition")

        map("n", "gD", function()
          require("snacks.lsp").declarations()
        end, "Goto Declaration")

        map("n", "gr", function()
          require("snacks.lsp").references()
        end, "Goto References")

        map("n", "gi", function()
          require("snacks.lsp").implementations()
        end, "Goto Implementation")

        map("n", "<leader>D", function()
          require("snacks.lsp").type_definitions()
        end, "Type Definition")

        -- Symbols and documentation
        map("n", "K", function()
          require("snacks.lsp").hover()
        end, "Hover Documentation")

        map("n", "<leader>ds", function()
          require("snacks.lsp").document_symbols()
        end, "Document Symbols")

        map("n", "<leader>ws", function()
          require("snacks.lsp").workspace_symbols()
        end, "Workspace Symbols")

        -- Code actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      end

      -- Common configuration with performance optimizations
      local common_setup = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
        -- handlers = {
        --   ["textDocument/signatureHelp"] = function() end, -- Disable signature help
        -- },
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
                  diagnostics = { globals = { "vim" } },
                },
              },
            }))
          end,

          ["ts_ls"] = function()
            lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", common_setup, {
              root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
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
                    shadow = true,
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

          ["eslint"] = function()
            lspconfig.eslint.setup(vim.tbl_deep_extend("force", common_setup, {
              root_dir = util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json"),
            }))
          end,
        },
      })

      -- Single remaining handler optimization
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true })
    end,
  },
}
