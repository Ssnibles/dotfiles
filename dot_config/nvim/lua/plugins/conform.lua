return {
  "stevearc/conform.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  event = { "BufReadPre", "BufNewFile" }, -- Fixed typo: rvent -> event
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "jq" },
      yaml = { "yamlfmt" },
      markdown = { "markdownlint" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      sh = { "shfmt" },
      go = { "gofumpt", "goimports" },
      rust = { "ast_grep" },
      ruby = { "rubyfmt" },
      php = { "php-cs-fixer" },
      java = { "google-java-format" },
      kotlin = { "ktlint" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      -- zig = { "zigfmt" },
      sql = { "sqlfmt" },
      toml = { "taplo" },
      svelte = { "prettier" },
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
        prepend_args = { "--line-length", "100", "--fast" },
      },
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      prettier = {
        prepend_args = { "--prose-wrap", "always" },
      },
      ast_grep = {
        command = "sg",
        args = { "scan", "-r", "~/.config/ast-grep-rules.yml", "--update-all", "$FILENAME" },
        stdin = false,
      },
    },
    notify_on_error = true,
  },
  config = function(_, opts)
    require("conform").setup(opts)

    -- Collect all unique formatters
    local formatters = {}
    for _, ft_formatters in pairs(opts.formatters_by_ft) do
      for _, formatter in ipairs(ft_formatters) do
        formatters[formatter] = true
      end
    end

    -- Convert to list of formatter names and add ast-grep
    local ensure_installed = vim.tbl_keys(formatters)
    table.insert(ensure_installed, "ast-grep") -- Manual addition if not auto-detected

    -- Set up formatter installation
    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
      auto_update = true,
      run_on_start = true,
    })
  end,
}
