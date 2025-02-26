--             __                                         __
--  ___ ___ __/ /____  _______  __ _  __ _  ___ ____  ___/ /__
-- / _ `/ // / __/ _ \/ __/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
-- \_,_/\_,_/\__/\___/\__/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/

--  see `:help lua-guide-autocommands`

-- Define the "currentline" sign, this sign is displayed next to the left of the active line number
-- vim.fn.sign_define("currentline", { text = "▶", texthl = "LineNr" })

-- ighlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = (function()
		local highlight_group = "IncSearch"
		local timeout = 300

		return function()
			vim.highlight.on_yank({ higroup = highlight_group, timeout = timeout })
		end
	end)(),
})

-- Auto-resize splits when Vim is resized
-- vim.api.nvim_create_autocmd("VimResized", {
-- 	desc = "Auto-resize splits when Vim is resized",
-- 	group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
-- 	callback = function()
-- 		vim.cmd.tabdo("wincmd =")
-- 	end,
-- })

-- Remove trailing whitespace on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	desc = "Remove trailing whitespace on save",
-- 	group = vim.api.nvim_create_augroup("remove-trailing-whitespace", { clear = true }),
-- 	pattern = "*",
-- 	callback = function()
-- 		local save_cursor = vim.fn.getpos(".")
-- 		local save_view = vim.fn.winsaveview()
-- 		vim.cmd([[keeppatterns %s/\s\+$//e]])
-- 		vim.fn.winrestview(save_view)
-- 		vim.fn.setpos(".", save_cursor)
-- 	end,
-- })

-- Set wrap and spell for text filetypes
vim.api.nvim_create_autocmd("FileType", {
	desc = "Set wrap and spell for text filetypes",
	group = vim.api.nvim_create_augroup("text-wrap-spell", { clear = true }),
	pattern = { "gitcommit", "markdown", "text", "tex" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- Add blankline at the end of a file
vim.api.nvim_create_autocmd("BufWritePost", {
	desc = "Add blank line at end of file",
	group = vim.api.nvim_create_augroup("add_blank_line", { clear = true }),
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(buf, -2, -1, false)
		if #lines == 1 and lines[1] ~= "" then
			local save_cursor = vim.fn.getpos(".")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
			vim.fn.setpos(".", save_cursor)
		end
	end,
})
