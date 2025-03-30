return {
  "ray-x/go.nvim",
  dependencies = {
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
    "mfussenegger/nvim-dap",
    "leoluz/nvim-dap-go",
  },
  ft = { "go", "gomod" },
  keys = {
    -- Keep previous keybinds
    { "<leader>gr", "<cmd>GoRun<cr>", desc = "Run current file" },
    { "<leader>gb", "<cmd>GoBuild<cr>", desc = "Build package" },
    { "<leader>gt", "<cmd>GoTest<cr>", desc = "Run tests" },
    { "<leader>gT", "<cmd>GoTestFunc<cr>", desc = "Run test under cursor" },
    { "<leader>gl", "<cmd>GoLint<cr>", desc = "Run linter" },
    { "<leader>ga", "<cmd>GoCodeAction<cr>", desc = "Code actions" },
    { "<leader>gC", "<cmd>GoCheat<cr>", desc = "Cheat sheet" },
    { "<leader>gc", "<cmd>GoCmt<cr>", desc = "Generate comment" },
    { "<leader>gd", "<cmd>GoDoc<cr>", desc = "Show documentation" },
    { "<leader>gf", "<cmd>GoFillStruct<cr>", desc = "Fill struct" },
    { "<leader>gi", "<cmd>GoImport<cr>", desc = "Manage imports" },
    { "<leader>ge", "<cmd>GoIfErr<cr>", desc = "Generate error check" },
    { "<leader>gD", "<cmd>GoDebug<cr>", desc = "Start debug session" },
    { "<leader>gta", "<cmd>GoAddTag<cr>", desc = "Add struct tags" },
    { "<leader>gtc", "<cmd>GoClearTag<cr>", desc = "Clear struct tags" },
  },
  opts = {
    lsp_keymaps = false,
    lsp_cfg = true,
    diagnostic = {
      virtual_text = {
        space = 0,
        prefix = "■",
        source = "always", -- Show diagnostic source
      },
    },
    trouble = true,
    test_runner = "go",
    luasnip = false,
    formatter = "gofumpt",
    lsp_format_on_save = true,
    lsp_inlay_hints = {
      enable = true,
      style = "standalone",
    },
  },
  config = function(_, opts)
    require("go").setup(opts)

    -- Updated LSP configuration with position encoding
    require("lspconfig").gopls.setup({
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      on_attach = function(client, bufnr)
        -- Set position encoding for LSP handlers
        client.config.flags = client.config.flags or {}
        client.config.flags.allow_incremental_sync = true
        client.offset_encoding = "utf-16"
      end,
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
          },
        },
      },
    })
  end,
  build = ':lua require("go.install").update_all_sync()',
}
