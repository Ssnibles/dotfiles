return {
  "3rd/image.nvim",
  enabled = false,
  opts = {
    backend = "kitty", -- The backend to use. Options: "kitty", "ueberzug", "viu", "chafa", or "jp2a"
    max_width = 100, -- Maximum image width
    max_height = 50, -- Maximum image height
    max_threads = 4, -- Maximum number of threads to use for processing
    integrations = {
      markdown = {
        enabled = true, -- Enable markdown integration
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" }, -- Filetypes to enable markdown image rendering
      },
      neorg = {
        enabled = true, -- Enable neorg integration
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "norg" }, -- Filetypes to enable neorg image rendering
      },
    },
    editor_only_render_when_focused = false, -- Only render images when the editor is focused
    tmux_show_only_in_active_window = false, -- Only show images in the active tmux window
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- File patterns to hijack
  },
  rocks = {
    hererocks = true, -- Recommended if you do not have a global installation of Lua 5.1
    { "magick", version = "1.6.0-1" }, -- LuaRocks package for image processing
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
}
