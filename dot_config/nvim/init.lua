-- Enable Lua module loader for better performance
if vim.loader then
  vim.loader.enable()
end

-- Performance profiler using snacks.nvim
-- Start the profiler by running nvim like this "PROF=1 nvim"
if vim.env.PROF then
  local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
  vim.opt.rtp:append(snacks)
  require("snacks.profiler").startup({
    startup = {
      event = "VimEnter",
    },
  })
end

-- Source files
require("core.lazy") -- Source lazy
require("core.keymaps") -- Source keymaps
require("core.options") -- Source options
require("core.autocmds") -- Source autocmds

-- Core configuration
-- local core_modules = {
--   "core.options",
--   "core.autocmds",
--   "core.keymaps",
-- }
-- for _, module in ipairs(core_modules) do
--   local ok, err = pcall(require, module)
--   if not ok then
--     vim.notify("Error loading " .. module .. "\n\n" .. err, vim.log.levels.ERROR)
--   end
-- end

-- Bootstrap lazy.nvim
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "--branch=stable",
--     "https://github.com/folke/lazy.nvim.git",
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)

-- -- Plugin configuration
-- require("lazy").setup {
--   spec = {
--     { import = "plugins" },
--   },
--   defaults = {
--     lazy = true,
--     version = false,
--   },
--   install = {
--     colorscheme = { "habamax" },
--   },
--   checker = {
--     enabled = true,
--     notify = false,
--   },
--   change_detection = {
--     notify = true,
--   },
-- }
