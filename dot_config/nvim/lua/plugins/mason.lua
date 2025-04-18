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
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = "williamboman/mason.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP Servers
          "lua-language-server",
          "gopls",
          "typescript-language-server",
          "clangd",
          "bash-language-server",
          "taplo",
          "marksman",
          "texlab",
          "eslint-lsp",

          -- Formatters/Linters
          "stylua",
          "prettier",
          "eslint_d",
          "shellcheck",
          "shfmt",
        },
        auto_update = true,
        run_on_start = true,
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
      -- 1. Diagnostic configuration (with numhl support)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          format = function(diagnostic)
            return string.format(
              "%s [%s] (%s)",
              diagnostic.message,
              diagnostic.code or diagnostic.user_data.lsp.code,
              diagnostic.source
            )
          end,
        },
      })

      -- 2. Define gutter signs with numhl (for colored line numbers)
      local signs = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, {
          text = icon,
          texthl = hl,
          numhl = hl, -- This enables the colored line numbers
        })
      end

      -- 3. LSP Capabilities (blink.cmp compatible)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem = {
        snippetSupport = true,
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits" },
        },
      }

      -- 4. Mason LSP Installer Setup
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls",
          "ts_ls", -- Using the correct server name now
          "clangd",
          "bashls",
          "taplo",
          "marksman",
          "texlab",
          "eslint",
          "hyprls",
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local util = require("lspconfig/util")

      -- 5. on_attach function with your keymaps
      local on_attach = function(client, bufnr)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = "LSP: " .. desc,
            silent = true,
            noremap = true,
          })
        end

        -- Navigation
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "gr", vim.lsp.buf.references, "Goto References")
        map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")

        -- Code actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

        -- Formatting
        map("n", "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "Format Document")
      end

      -- 6. Common server configuration
      local common_setup = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
      }

      -- 7. Server-specific configurations
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup(common_setup)
        end,

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common_setup, {
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                  checkThirdParty = false,
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = { enable = false },
              },
            },
          }))
        end,

        ["ts_ls"] = function() -- Using the correct server name now
          lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", common_setup, {
            root_dir = util.root_pattern("package.json", "tsconfig.json"),
            settings = {
              completions = { completeFunctionCalls = true },
              typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
            },
          }))
        end,
      })

      -- 8. Hover diagnostics enhancement
      vim.api.nvim_create_autocmd("CursorHold", {
        pattern = "*",
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "CursorMoved", "InsertEnter" },
            border = "rounded",
            source = "always",
            prefix = function(diagnostic)
              return string.format("(%s) ", diagnostic.source)
            end,
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })
    end,
  },
}
