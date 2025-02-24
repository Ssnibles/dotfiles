return {
  {
    "echasnovski/mini.nvim",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Basic setup for some commonly used mini modules
      require("mini.ai").setup()
      require("mini.align").setup()
      require("mini.bufremove").setup()
      require("mini.comment").setup()
      require("mini.cursorword").setup()
      -- require("mini.indentscope").setup()
      require("mini.pairs").setup()
      require("mini.statusline").setup()
      require("mini.surround").setup()
      -- require("mini.tabline").setup()
      -- require("mini.starter").setup()

      -- You can add more mini modules or customize their setup here
    end,
  },
}
