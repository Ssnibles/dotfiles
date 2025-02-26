return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			notification = {
				window = { winblend = 1 },
			},
			progress = {
				ignore = { "^null-ls" },
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
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
				},
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local servers = {
				"lua_ls",
				"rust_analyzer",
				"gopls",
				"ts_ls",
				"clangd",
				"bashls",
				"taplo",
				"marksman",
			}

			for _, server in ipairs(servers) do
				lspconfig[server].setup({})
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local bufOpts = { buffer = ev.buf }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, bufOpts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufOpts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, bufOpts)
				end,
			})
		end,
	},
}
