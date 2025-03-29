return {
  "otavioschwanck/arrow.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  keys = {
    { "<leader>au", "<Cmd>Arrow open<CR>", mode = { "n" }, desc = "Open Arrow.nvim ui" },
  },
  opts = {
    show_icons = true,
    global_bookmarks = true,
    mappings = {
      edit = "e",
      delete_mode = "d",
      clear_all_items = "C",
      toggle = "s", -- used as save if separate_save_and_remove is true
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      remove = "x", -- only used if separate_save_and_remove is true
      next_item = "<Down>",
      prev_item = "<Up>"
    },
    window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
      width = "auto",
      height = "auto",
      row = "auto",
      col = "auto",
      border = "rounded",
    },
    per_buffer_config = {
      sort_automatically = true,
      lines = 4,
    }
  }
}
