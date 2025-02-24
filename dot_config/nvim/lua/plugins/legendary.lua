return {
  "mrjones2014/legendary.nvim",
  keys = {
    { "<leader>l", "<cmd>Legendary<cr>", desc = "Open Legendary" },
  },
  dependencies = {
    "kkharji/sqlite.lua",
    "stevearc/dressing.nvim", -- Optional: Enhances UI appearance
  },
  opts = {
    extensions = {
      which_key = { auto_register = true },
      lazy_nvim = { auto_register = true },
    },
    include_builtin = true,
    include_legendary_cmds = true,
    select_prompt = " Legendary ",
    col_separator_char = "│",
  },
}
