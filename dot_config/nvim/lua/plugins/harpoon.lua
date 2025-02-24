return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ha", function() require("harpoon"):list():append() end,                                 desc = "Append Position" },
    { "<leader>hl", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Toggle List" },
    { "<leader>h1", function() require("harpoon"):list():select(1) end,                                desc = "Select 1st Entry" },
    { "<leader>h2", function() require("harpoon"):list():select(2) end,                                desc = "Select 2nd Entry" },
    { "<leader>h3", function() require("harpoon"):list():select(3) end,                                desc = "Select 3rd Entry" },
    { "<leader>h4", function() require("harpoon"):list():select(4) end,                                desc = "Select 4th Entry" },
  },
  opts = {
    global_settings = {
      save_on_toggle = true,
      save_on_change = true,
      enter_on_sendcmd = false,
      tmux_autoclose_windows = false,
      excluded_filetypes = { "harpoon" },
      mark_branch = false,
    },
  },
  config = function(_, opts)
    local harpoon = require("harpoon")
    harpoon:setup(opts)
  end,
}
