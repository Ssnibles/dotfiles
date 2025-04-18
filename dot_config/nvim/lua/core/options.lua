--            __  __  _
--   ___ ___ / /_/ /_(_)__  ___ ____
--  (_-</ -_) __/ __/ / _ \/ _ `(_-<
-- /___/\__/\__/\__/_/_//_/\_, /___/
--                        /___/

-- Global settings
local global = vim.g
local option = vim.opt

-- Neovide-specific settings
if global.neovide then
  -- Font Configuration
  option.guifont = "JetBrainsMono Nerd Font:h12" -- Correct way to set font and size

  -- Scaling and Appearance
  global.neovide_scale_factor = 1.0
  global.neovide_refresh_rate = 144 -- Match high-refresh monitors
  global.neovide_hide_mouse_when_typing = true
  global.neovide_floating_shadow = false

  -- Smooth Scrolling
  global.neovide_scroll_animation_length = 0.3

  -- Cursor Customization
  global.neovide_cursor_animation_length = 0.05
  global.neovide_cursor_trail_length = 0.2
  global.neovide_cursor_vfx_mode = "pixie"
  global.neovide_cursor_vfx_opacity = 150.0
  global.neovide_cursor_vfx_particle_lifetime = 0.8
  global.neovide_cursor_vfx_particle_density = 3.0
  global.neovide_cursor_vfx_particle_speed = 5.0
  global.neovide_cursor_animate_in_insert_mode = false
  global.neovide_cursor_animate_command_line = false

  -- Window Padding (Optional)
  global.neovide_padding_top = 5
  global.neovide_padding_bottom = 5
  global.neovide_padding_left = 5
  global.neovide_padding_right = 5

  -- Fullscreen and Floating Settings
  global.neovide_fullscreen = false
  global.neovide_floating_blur = false -- Disable for performance

  -- Advanced Features
  global.neovide_remember_window_size = true

  -- Clipboard Integration (Optional)
  global.neovide_input_use_logo = true -- Enable Super/Logo key

  -- Performance settings
  global.neovide_refresh_rate_idle = 5
end

-- General global Neovim settings
global.have_nerd_font = true
-- global.loaded_netrw = 1
-- global.loaded_netrePlugin = 1

-- Function to set multiple options at once
local function set_options(options)
  -- Apply multiple Neovim options from a table.
  for k, v in pairs(options) do
    option[k] = v
  end
end

-- Core editor configuration
set_options({
  clipboard = "unnamedplus",

  -- Text formatting
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = 2,
  smartindent = true,
  autoindent = true,
  wrap = true,
  breakindent = true,

  -- Line numbers
  number = true,
  relativenumber = true,
  cursorline = true,
  cursorlineopt = "both",

  -- Visual preferences
  winbar = "",
  termguicolors = true,
  -- winborder = "rounded",
  -- signcolumn = "yes:2",
  list = true,
  listchars = { -- Corrected key name
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
    extends = "»",
    precedes = "«",
  },

  fillchars = {
    eob = " ", -- Works as-is
    fold = " ", -- Works, but consider "foldopen=,foldsep=│,foldclose="
    foldopen = "",
    foldclose = "",
    foldsep = "│",
    vert = "▕", -- Vertical split
    horiz = "─", -- Horizontal split (recommend using a visible character)
    horizup = " ", -- Rarely used
    horizdown = " ", -- Rarely used
    vertleft = "▏", -- Left vertical split
    vertright = "▕", -- Right vertical split
    verthoriz = "╋", -- Cross junction
  },

  -- Search behavior
  ignorecase = true,
  smartcase = true,
  hlsearch = true,
  incsearch = true,
  inccommand = "split",

  -- Performance optimizations
  lazyredraw = false,
  updatetime = 250,
  timeoutlen = 300,
  redrawtime = 150,
  synmaxcol = 500,
  ttyfast = true,

  -- File handling
  undofile = true,
  swapfile = false,
  backup = false,
  writebackup = false,
  autoread = true,

  -- Window management
  splitright = true,
  splitbelow = true,
  splitkeep = "cursor",
  mouse = "a",
  scrolloff = 10,
  sidescrolloff = 10,

  -- Interface behavior
  wildmenu = true,
  wildmode = "longest:full,full",
  completeopt = "noselect",
  viewoptions = "folds,cursor,curdir,slash,unix",
  showtabline = 0,

  -- Fold settings
  foldlevelstart = 99,

  -- Encoding
  fileencoding = "utf-8",
  encoding = "utf-8",

  -- Miscellaneous
  title = true,
  backspace = { "start", "eol", "indent" },
})

-- Disable signature help from lsp.
vim.lsp.handlers["textDocument/signatureHelp"] = function() end

--  Set relative line number colour
-- Get NonText properties FIRST
local nontext_hl = vim.api.nvim_get_hl(0, { name = "NonText" })
local main_hl = vim.api.nvim_get_hl(0, { name = "markdownH1" })

-- Create hybrid highlight
vim.api.nvim_set_hl(0, "CursorLineNr", {
  fg = nontext_hl.fg,
  bg = nontext_hl.bg,
  bold = false,
  italic = true,
  undercurl = nontext_hl.undercurl,
  underline = nontext_hl.underline,
})

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "setlocal nonumber norelativenumber signcolumn=no",
})
