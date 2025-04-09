return {
  {
    "sphamba/smear-cursor.nvim",
    enabled = not vim.g.neovide,
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
    enabled = not vim.g.neovide,
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "luukvbaal/statuscol.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      relculright = true,
    },
  },
}
