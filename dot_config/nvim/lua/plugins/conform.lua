return {
  "stevearc/conform.nvim",
  dependencies = {
    "mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
      black = {
        prepend_args = { "--line-length", "100" },
      },
      isort = {
        prepend_args = { "--profile", "black" },
      },
    },
    notify_on_error = true,
    notify_no_formatters = true,
  },
  config = function(_, opts)
    local conform = require("conform")

    -- Setup conform
    conform.setup(opts)

    -- Collect unique formatters
    local ensure_installed = {}
    for _, formatters in pairs(opts.formatters_by_ft) do
      for _, formatter in ipairs(formatters) do
        if not vim.tbl_contains(ensure_installed, formatter) then
          table.insert(ensure_installed, formatter)
        end
      end
    end

    -- Setup mason-tool-installer
    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
      auto_update = true,
      run_on_start = true,
    })

    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        conform.format({ bufnr = args.buf })
      end,
    })
  end,
}
