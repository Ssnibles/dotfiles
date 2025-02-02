return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>t", desc = "Toggle terminal" },
  },
  opts = {
    size = 10,
    open_mapping = [[<leader>t]],
    shading_factor = 2,
    direction = "float",
    float_opts = {
      border = "curved",
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
