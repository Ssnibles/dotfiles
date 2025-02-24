--  See `:help vim.keymap.set()`

-- Set leader keys
vim.g.mapleader = " "

-- Create a local alias for vim.keymap.set
local keymap = vim.keymap.set

-- Disable quitting nvim with <C-z>
keymap({ "n", "v", "i", "s", "x", "o", "c", "t" }, "<C-z>", "", { noremap = true })

-- Exit insert when pressing jk
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Clear highlights on search when pressing <Esc> in normal mode
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Increment and decrement numbers
vim.keymap.set("n", "<A-Up>", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<A-Down>", "<C-x>", { desc = "Decrement number" })

vim.keymap.set("n", "<C-a>", "<Nop>", { desc = "Unbind increment" })

-- Exit terminal mode
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open splits
keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>wh", "<C-w>h", { desc = "Split window horizontally" })
keymap("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
keymap("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" })

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
