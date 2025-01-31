return {
  "kevinhwang91/nvim-bqf",
  event = { "BufRead", "BufNew" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "junegunn/fzf",
  },
  config = function()
    require("bqf").setup {
      auto_enable = true,
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80,
        border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
      },
      func_map = {
        vsplit = "",
        ptogglemode = "z,",
        stoggleup = "",
      },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "split" },
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
        },
      },
    }

    -- Auto-grep functionality
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      callback = function()
        vim.cmd("silent grep! -R . " .. vim.fn.expand "%")
        vim.cmd "cwindow"
      end,
    })

    -- Keymaps for quick navigation
    vim.keymap.set("n", "]q", ":cnext<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "[q", ":cprev<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>qf", ":copen<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { noremap = true, silent = true })
  end,
}
