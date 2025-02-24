--            __  __  _
--   ___ ___ / /_/ /_(_)__  ___ ____
--  (_-</ -_) __/ __/ / _ \/ _ `(_-<
-- /___/\__/\__/\__/_/_//_/\_, /___/
--                        /___/

-- Neovim and Neovide Configuration

-- Global settings
local global = vim.g
local option = vim.opt

-- Neovide-specific settings
if global.neovide then
  -- Font settings
  global.neovide_font_size = 14
  global.neovide_font = "JetBrainsMono Nerd Font"

  -- Appearance
  global.neovide_transparency = 1.0
  global.neovide_padding_top = 10
  global.neovide_padding_bottom = 0
  global.neovide_padding_left = 10
  global.neovide_padding_right = 10
  global.neovide_floating_shadow = false
  global.neovide_scale_factor = 0.85

  -- Animations
  global.neovide_scroll_animation_length = 0.3
  global.neovide_cursor_animation_length = 0.13
  global.neovide_cursor_trail_length = 0.8
  global.neovide_cursor_antialiasing = true
  global.neovide_cursor_vfx_mode = "railgun"
  global.neovide_cursor_vfx_opacity = 200.0
  global.neovide_cursor_vfx_particle_lifetime = 1.2
  global.neovide_cursor_vfx_particle_density = 7.0
  global.neovide_cursor_vfx_particle_speed = 10.0
  global.neovide_cursor_animate_in_insert_mode = true
  global.neovide_cursor_animate_command_line = true
  global.neovide_position_animation_length = 0

  -- Smooth input
  global.neovide_input_use_logo = true -- enable use of the logo (cmd) key
  global.neovide_input_macos_alt_is_meta = true

  -- Performance
  global.neovide_no_idle = true
  global.neovide_rendering = "opengl"

  -- Window settings
  global.neovide_fullscreen = false
  global.neovide_remember_window_size = false
  global.neovide_profiler = false -- disable profiler for better performance
end

-- General Neovim settings
global.have_nerd_font = true

-- Local function for setting options
local function set_options(options)
  for k, v in pairs(options) do
    option[k] = v
  end
end

-- Editor behavior
set_options({
  number = true,
  relativenumber = true,
  clipboard = "unnamedplus",
  autoindent = true,
  smartindent = true,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  softtabstop = 2,
})

-- Appearance
set_options({
  signcolumn = "yes",
  cursorline = true,
  termguicolors = true,
  list = true,
  listchars = { tab = "» ", trail = "·", extends = "❯", precedes = "❮" },
  fillchars = { eob = " " },
})

-- Search
set_options({
  ignorecase = true,
  smartcase = true,
  hlsearch = true,
  incsearch = true,
})

-- Performance
set_options({
  lazyredraw = true,
  updatetime = 300, -- Slightly increased
  timeoutlen = 400, -- Slightly increased
})

-- File handling
set_options({
  autoread = true,
  backup = false,
  writebackup = false,
  swapfile = false,
  undofile = true,
})

-- Miscellaneous
set_options({
  mouse = "a",
  hidden = true,
  history = 1000,
  scrolloff = 8,
  sidescrolloff = 8,
  wildmenu = true,
  wildmode = "longest:full,full",
  completeopt = "menuone,noselect",
  complete = ".,w,b,u,t,i,kspell",
  omnifunc = "v:lua.vim.lsp.omnifunc",
})

-- Split behavior
set_options({
  splitright = true,
  splitbelow = true,
})

-- Additional suggested improvements
option.shortmess:append("c") -- Reduce completion messages
option.pumheight = 10        -- Limit popup menu height
