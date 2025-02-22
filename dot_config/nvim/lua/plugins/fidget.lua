return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		notification = {
			window = {
				winblend = 1,
			},
		},
		progress = {
			ignore = { "^null-ls" },
		},
	},
}
