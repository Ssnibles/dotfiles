return {
  "nvim-tree/nvim-tree.lua",
  enabled = false,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree", silent = true },
  },
  opts = {
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 30,
      side = "right",
    },
    renderer = {
      group_empty = true,
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)
  end,
}
