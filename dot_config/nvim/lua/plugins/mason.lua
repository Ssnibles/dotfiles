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
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Base capabilities for LSP
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      }

      -- Configure Mason LSP installer
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
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Enhanced on_attach function
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
          map("n", "<leader>ch", vim.lsp.buf.signature_help, "Signature Help")
        end

        -- Diagnostic hover configuration
        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(nil, {
              focusable = false,
              close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
              border = "rounded",
              source = "always",
            })
          end,
        })
      end

      -- Common server configuration
      local common_setup = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
      }

      -- Server-specific configurations with custom root directories
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup(vim.tbl_deep_extend("force", common_setup, {}))
        end,

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common_setup, {
            root_dir = util.root_pattern(".git", ".luarc.json", ".stylua.toml"),
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = {
                  globals = { "vim" },
                  disable = { "missing-fields" },
                },
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
            root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
            settings = {
              completions = {
                completeFunctionCalls = true,
              },
            },
          }))
        end,

        ["rust_analyzer"] = function()
          lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", common_setup, {
            root_dir = util.root_pattern("Cargo.toml", "rust-project.json"),
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
            root_dir = util.root_pattern("go.mod", ".git"),
          }))
        end,

        ["clangd"] = function()
          lspconfig.clangd.setup(vim.tbl_deep_extend("force", common_setup, {
            root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
          }))
        end,

        ["bashls"] = function()
          lspconfig.bashls.setup(vim.tbl_deep_extend("force", common_setup, {
            root_dir = util.root_pattern(".git", ".bashrc", ".zshrc"),
          }))
        end,
      })
    end,
  },
}
