-- Enable Lua module loader for better performance
if vim.loader then
  vim.loader.enable()
end

if vim.g.vscode then
  vim.opt.laststatus = 0
  vim.opt.showmode = false
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
require("core.functions") -- Source custom functions

-- vim.diagnostic.config({ virtual_text = false })
