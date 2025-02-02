--    __            __   _         __
--   / /_____ __ __/ /  (_)__  ___/ /__
--  /  '_/ -_) // / _ \/ / _ \/ _  (_-<
-- /_/\_\\__/\_, /_.__/_/_//_/\_,_/___/
--          /___/

--  See `:help vim.keymap.set()`

-- Set leader keys
vim.g.mapleader = " "

-- Create a local alias for vim.keymap.set
local keymap = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Exit terminal mode
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable arrow keys in normal mode
keymap("n", "<left>", '<cmd>echo "Use h instead"<CR>')
keymap("n", "<right>", '<cmd>echo "Use l instead"<CR>')
keymap("n", "<up>", '<cmd>echo "Use k instead"<CR>')
keymap("n", "<down>", '<cmd>echo "Use j instead"<CR>')

-- Split navigation
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Delete current line using black hole register
keymap("n", "<C-x>", '"dd_:echo "Line deleted"<CR>', { noremap = true, silent = true })
keymap("i", "<C-x>", '<Esc>"dd_:echo "Line deleted"<CR>i', { noremap = true, silent = true })
