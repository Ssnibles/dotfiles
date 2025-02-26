return {
	{
		"stevearc/conform.nvim",
		event = "LspAttach",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					dart = { "dcm", "ast-grep" },
					sh = { "beautysh" },
					bash = { "beautysh" },
					fish = { "fish" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "LspAttach",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"isort",
					"black",
					"rustfmt",
					"prettierd",
					"prettier",
					"dcm",
					"ast-grep",
					"beautysh",
					"fish",
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
}
