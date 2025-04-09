--  see `:help lua-guide-autocommands`

-- Define the "currentline" sign with proper namespace and styling
-- vim.fn.sign_define("currentline", {
--   text = "▶", -- More visible symbol
--   texthl = "LineNr", -- Link to existing highlight group
--   numhl = "LineNr", -- Maintain number column appearance
-- })

-- Highlight yanked text with better defaults
-- local yank_group = vim.api.nvim_create_augroup("highlight-yank", { clear = true })
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   desc = "Briefly highlight yanked text",
--   group = yank_group,
--   pattern = "*",
--   callback = function()
--     vim.highlight.on_yank({
--       higroup = "IncSearch", -- Consider using 'Visual' for better visibility
--       timeout = 150, -- Shorter duration for less distraction
--       on_visual = true, -- Also highlight in visual mode
--     })
--   end,
-- })

-- Improved window resize handling
local resize_group = vim.api.nvim_create_augroup("resize-splits", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Automatically balance windows on resize",
  group = resize_group,
  pattern = "*",
  callback = function()
    -- Only adjust if there are multiple windows
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      vim.cmd("wincmd =") -- Remove tabdo to only affect current tab
    end
  end,
})

-- Disable diagnostics in insert mode (for better performance)
-- vim.api.nvim_create_autocmd({ "InsertEnter" }, {
--   desc = "Disable diagnostics in insert mode",
--   group = vim.api.nvim_create_augroup("diagnostics_insert", { clear = true }),
--   callback = function()
--     vim.diagnostic.enable(false)
--   end,
-- })
--
-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
--   group = vim.api.nvim_create_augroup("diagnostics_normal", { clear = true }),
--   callback = function()
--     vim.diagnostic.enable()
--   end,
-- })

-- Auto-fix imports on save for TypeScript/JavaScript
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    local clients = vim.lsp.get_active_clients({ name = "tsserver" })
    if #clients > 0 then
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
    end
  end,
})

-- Automatically expand React fragments
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescriptreact", "javascriptreact" },
  callback = function()
    vim.keymap.set("i", "<C-f>", "<><Esc>hi</><Esc>4hi", { buffer = true })
  end,
})

-- Typewriter mode (centered cursor)
local typewriter_mode = false

local function toggle_typewriter()
  typewriter_mode = not typewriter_mode
  if typewriter_mode then
    -- Enable typewriter mode
    vim.wo.scrolloff = 999 -- Center vertically
    vim.wo.sidescrolloff = 999 -- Center horizontally
    vim.wo.colorcolumn = "80" -- Optional: show line length marker
    vim.notify("Typewriter mode ON ✍️", vim.log.levels.INFO)
  else
    -- Disable typewriter mode
    vim.wo.scrolloff = 5 -- Default value (adjust to your preference)
    vim.wo.sidescrolloff = 0 -- Default value
    vim.wo.colorcolumn = "" -- Clear line length marker
    vim.notify("Typewriter mode OFF ✍️", vim.log.levels.INFO)
  end
end
vim.keymap.set("n", "<leader>tw", toggle_typewriter, { desc = "Toggle typewriter mode" })
