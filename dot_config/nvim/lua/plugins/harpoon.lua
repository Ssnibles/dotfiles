return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    -- Toggle Harpoon menu
    {
      "<leader>ha",
      function()
        require("harpoon"):list():append()
      end,
      desc = "Harpoon File",
    },
    -- Open Harpoon menu
    {
      "<leader>hm",
      function()
        require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
      end,
      desc = "Harpoon Quick Menu",
    },
    -- Navigate to Harpoon marks 1-4
    {
      "<leader>h1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon to File 1",
    },
    {
      "<leader>h2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon to File 2",
    },
    {
      "<leader>h3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon to File 3",
    },
    {
      "<leader>h4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon to File 4",
    },
    -- Cycle next/previous in Harpoon list
    {
      "<leader>hn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Harpoon Next",
    },
    {
      "<leader>hp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Harpoon Prev",
    },
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})

    -- Optional: Configure the Harpoon menu appearance
    require("harpoon").ui:toggle_quick_menu(harpoon:list(), {
      border = "rounded",
      title_pos = "center",
    })
  end,
}
