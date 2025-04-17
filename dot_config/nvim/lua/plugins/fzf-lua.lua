return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", mode = { "n" }, desc = "Open fzf-lua file picker" },
    { "<leader>fl", "<cmd>FzfLua blines<cr>", mode = { "n" }, desc = "Open fzf-lua buffer lines picker" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", mode = { "n" }, desc = "Open fzf-lua buffer picker" },
    { "<leader>fh", "<cmd>FzfLua command_history", mode = { "n" }, desc = "Open fzf-lua command history picker" },
    { "<leader>fg", "<cmd>FzfLua lines<cr>", mode = { "n" }, desc = "Open fzf-lua grep picker" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", mode = { "n" }, desc = "Open fzf-lua recent files picker" },
    { "<leader>/", "<cmd>FzfLua blines<cr>", mode = { "n" }, desc = "Open fzf-lua current buffer picker" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
}
