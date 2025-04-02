--            __  __  _
--   ___ ___ / /_/ /_(_)__  ___ ____
--  (_-</ -_) __/ __/ / _ \/ _ `(_-<
-- /___/\__/\__/\__/_/_//_/\_, /___/
--                        /___/

-- Optimized Neovim/Neovide Configuration

-- Global settings
local global = vim.g
local option = vim.opt

-- Neovide-specific settings
if global.neovide then
  -- Font configuration
  global.neovide_font = "RecMonoDuotone Nerd Font Mono:h12"
  global.neovide_scale_factor = 1.0

  -- Window appearance
  global.neovide_transparency = 1.0
  global.neovide_padding_top = 5
  global.neovide_padding_bottom = 5
  global.neovide_padding_left = 5
  global.neovide_padding_right = 5
  global.neovide_floating_shadow = false
  global.neovide_floating_blur = false
  global.neovide_hide_mouse_when_typing = true

  -- Cursor and animations
  global.neovide_cursor_animation_length = 0.05
  global.neovide_cursor_trail_length = 0.2
  global.neovide_cursor_vfx_mode = "torpedo"
  global.neovide_cursor_vfx_opacity = 150.0
  global.neovide_cursor_vfx_particle_lifetime = 0.8
  global.neovide_cursor_vfx_particle_density = 3.0
  global.neovide_cursor_vfx_particle_speed = 5.0
  global.neovide_cursor_animate_in_insert_mode = false
  global.neovide_cursor_animate_command_line = false
  global.neovide_scroll_animation_length = 0.2

  -- Performance settings
  global.neovide_no_idle = false
  global.neovide_remember_window_size = true
  global.neovide_touch_deadzone = 6
  global.neovide_confirm_quit = true
  global.neovide_refresh_rate = 60
end

-- General Neovim settings
global.have_nerd_font = true

-- Local function for setting options
local function set_options(options)
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

  -- Line numbers
  number = true,
  relativenumber = true,
  cursorline = true,
  cursorlineopt = "both",

  -- Visual preferences
  winbar = "",
  termguicolors = true,
  signcolumn = "yes:2",
  list = true,
  listchars = {
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
    extends = "»",
    precedes = "«",
  },
  fillchars = {
    eob = " ",
    fold = " ",
    vert = "▕",
    horiz = "",
    horizup = "",
    horizdown = "",
    vertleft = "▏",
    vertright = "▕",
    verthoriz = "╋",
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
  splitkeep = "screen",
  scrolloff = 8,
  sidescrolloff = 8,

  -- Interface behavior
  mouse = "a",
  wildmenu = true,
  wildmode = "longest:full,full",
  completeopt = "noselect",
  viewoptions = "folds,cursor,curdir,slash,unix",
})

-- Advanced performance optimizations
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- vim.api.nvim_set_hl(0, "LineNr", { fg = "#908caa" }) -- Relative numbers
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ea9a97", bold = true }) -- Current line (0)

vim.lsp.handlers["textDocument/signatureHelp"] = function() end
