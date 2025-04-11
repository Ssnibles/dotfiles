return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  ft = { "rust" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    -- Execution and building
    { "<leader>rr", "<cmd>RustLsp runnables<CR>", desc = "🚀 Runnables" },
    { "<leader>rb", "<cmd>RustLsp build<CR>", desc = "🔨 Build" },
    { "<leader>rc", "<cmd>RustLsp check<CR>", desc = "🔍 Check" },

    -- Testing
    { "<leader>rt", "<cmd>RustLsp testables<CR>", desc = "🧪 Tests" },
    { "<leader>rT", "<cmd>RustLsp currentTest<CR>", desc = "🧪 Current Test" },

    -- Debugging
    { "<leader>rd", "<cmd>RustLsp debuggables<CR>", desc = "🐛 Debuggables" },
    { "<leader>rD", "<cmd>RustLsp debug<CR>", desc = "🐛 Start Debug" },

    -- Code actions
    { "<leader>ra", "<cmd>RustLsp codeAction<CR>", desc = "💡 Code Actions" },
    { "<leader>rf", "<cmd>RustLsp flyCheck<CR>", desc = "🛸 Fly Check" },
    { "<leader>rm", "<cmd>RustLsp expandMacro<CR>", desc = "📦 Expand Macro" },
    { "<leader>rp", "<cmd>RustLsp parentModule<CR>", desc = "🔼 Parent Module" },
    { "<leader>rs", "<cmd>RustLsp syntaxTree<CR>", desc = "🌳 Syntax Tree" },
    { "<leader>rh", "<cmd>RustLsp hover actions<CR>", desc = "🔍 Hover Actions" },
    { "<leader>rH", "<cmd>RustLsp hover range<CR>", desc = "📏 Hover Range" },
    { "<leader>re", "<cmd>RustLsp explainError<CR>", desc = "❓ Explain Error" },
  },
  config = function()
    -- Mason binary path handling
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if not vim.env.PATH:match(vim.pesc(mason_bin)) then
      vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
    end

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        spacing = 0,
        prefix = "■",
        source = "always",
      },
      float = {
        border = "rounded",
        source = "always",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    vim.g.rustaceanvim = {
      server = {
        standalone = false,
        on_attach = function(client, bufnr)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gr", vim.lsp.buf.references, "Find References")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")

          -- Code Actions
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Actions")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
          map("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature Help")

          -- Formatting
          map("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format Code")

          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,

        -- Use default LSP capabilities without CMP
        capabilities = vim.lsp.protocol.make_client_capabilities(),

        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              buildScripts = { enable = true },
              autoreload = true,
            },
            checkOnSave = {
              command = "clippy",
              extraArgs = {
                "--all-targets",
                "--all-features",
                "--",
                "-D",
                "warnings",
                "-D",
                "clippy::pedantic",
              },
            },
            procMacro = { enable = true },
            diagnostics = {
              disabled = { "unresolved-proc-macro" },
              enable = true,
              experimental = { enable = true },
            },
            lens = { enable = true },
            inlayHints = {
              enable = true,
              typeHints = { enable = true },
              chainingHints = { enable = true },
            },
          },
        },
      },
      dap = {
        adapter = {
          type = "executable",
          command = "lldb-vscode",
          name = "rt_lldb",
          env = { RUST_LOG = "info" },
        },
      },
      tools = {
        hover_actions = {
          auto_focus = true,
          border = "rounded",
          max_width = math.floor(vim.o.columns * 0.8),
          max_height = math.floor(vim.o.lines * 0.8),
        },
        inlay_hints = {
          only_current_line = false,
          show_parameter_hints = true,
          parameter_hints_prefix = "← ",
          other_hints_prefix = "→ ",
          highlight = "Comment",
        },
      },
    }
  end,
}
