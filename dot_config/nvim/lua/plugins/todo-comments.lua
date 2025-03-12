return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>tt",
			function()
				Snacks.picker.todo_comments({ keywords = { "TODO" } })
			end,
			desc = "Todo",
		},
	},
	opts = {
		signs = true,
	},
}
