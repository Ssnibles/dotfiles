return {
  {
    "sphamba/smear-cursor.nvim",
    enabled = not vim.g.neovide, -- Disable if Neovide is active
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      scroll_buffer_space = true,
      legacy_computing_symbols_support = false,
      smear_insert_mode = true,
    },
  },
  {
    "karb94/neoscroll.nvim",
    enabled = not vim.g.neovide, -- Disable if Neovide is active
    opts = {}, -- Add any options here if needed
  },
}
