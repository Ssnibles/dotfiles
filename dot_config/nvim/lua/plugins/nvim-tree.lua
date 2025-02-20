return {
  "nvim-tree/nvim-tree.lua",
  enabled = false,
  config = function()
    require("nvim-tree").setup({
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
    })
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
  end,
}
