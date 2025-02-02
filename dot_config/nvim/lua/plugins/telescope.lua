return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				-- Add your Telescope configuration here
			})

			-- Set up keymaps
			local keymap = vim.keymap.set
			local builtin = require("telescope.builtin")

			keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			keymap("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
			keymap("n", "<leader>fh", builtin.help_tags, { desc = "Find help tags" })
		end,
		keys = {
			{ "<leader>ff", desc = "Find files" },
			{ "<leader>fg", desc = "Live grep" },
			{ "<leader>fb", desc = "Find buffers" },
			{ "<leader>fh", desc = "Find help tags" },
			{
				"<leader>fd",
				function()
					require("telescope.builtin").find_files({
						hidden = true,
						no_ignore = false,
						find_command = {
							"fd",
							"--type",
							"d",
							"--hidden",
							"--follow",
							"--exclude",
							".git",
							"--max-depth",
							"5",
						},
						attach_mappings = function(prompt_bufnr, map)
							local actions = require("telescope.actions")
							local action_state = require("telescope.actions.state")

							map("i", "<CR>", function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								-- Open the selected directory using vim.cmd.cd and then open it
								vim.cmd.cd(selection.path)
								vim.cmd.edit(".")
							end)

							return true
						end,
					})
				end,
				desc = "Find and open directories",
			},
		},
	},
}
