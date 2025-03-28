return {
  "folke/flash.nvim",
  keys = {
    {
      "<CR>",
      function()
        require("flash").jump()
      end,
      mode = { "n", "x", "o" },
      desc = "Flash",
    },
    {
      "S",
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
      mode = { "n", "x", "o" },
    },
    {
      "r",
      function()
        require("flash").remote()
      end,
      mode = "o",
      desc = "Remote Flash",
    },
    {
      "R",
      function()
        require("flash").treesitter_remote()
      end,
      mode = { "o", "x" },
      desc = "Remote Flash Treesitter",
    },
    {
      "<c-s>",
      function()
        require("flash").jump()
      end,
      mode = { "c" },
      desc = "Flash",
    },
  },
  opts = {
    modes = {
      search = {
        enabled = true,
        jump_labels = true, -- Enable jump labels for search results
      },
      char = {
        enabled = true,
        jump_labels = true, -- Enable jump labels for character motions (f, t, etc.)
      },
      treesitter = {
        enabled = true,
        jump_labels = true, -- Enable jump labels for treesitter nodes.
      },
    },
    jump_labels = {
      style = "default", -- Change the style of jump labels if desired
      -- other options available, see docs.
    },
    -- add any other configuration options you want to override here.
  },
}
