return {
  "ziontee113/icon-picker.nvim",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "IconPickerNormal", "IconPickerYank", "IconPickerInsert" },
  keys = {
    { "<Leader>i",  "<cmd>IconPickerNormal<cr>",           desc = "Icon Picker (Normal Mode)" },
    { "<Leader>iy", "<cmd>IconPickerYank<cr>",             desc = "Icon Picker (Yank)" },
    -- { "<C-i>", "<cmd>IconPickerInsert<cr>", desc = "Icon Picker (Insert Mode)" },
    { "<Leader>ie", "<cmd>IconPickerNormal emoji<cr>",     desc = "Emoji Picker" },
    { "<Leader>in", "<cmd>IconPickerNormal nerd_font<cr>", desc = "Nerd Font Picker" },
    {
      "<Leader>if",
      function()
        require("icon-picker").pick_favicon({
          callback = function(icon)
            vim.api.nvim_put({ icon }, "", true, true)
            print("Selected favicon: " .. icon)
          end,
        })
      end,
      desc = "Favicon Picker"
    },
  },
  opts = {
    disable_legacy_commands = true,
    ui = {
      border = "rounded",
      width = 0.5,
      height = 0.7,
      row = 0.5,
      col = 0.5,
    },
    icons = {
      "emoji",
      "nerd_font",
      "codicons",
      "devicons",
    },
    prompt = "Pick an icon: ",
    search_method = "fzy",
    insert = {
      after_cursor = true,
      use_empty_line = false,
    },
    mappings = {
      ["<C-n>"] = "move_cursor_down",
      ["<C-p>"] = "move_cursor_up",
      ["<C-b>"] = "move_cursor_page_up",
      ["<C-f>"] = "move_cursor_page_down",
      ["<C-c>"] = "close",
    },
  },
  config = function(_, opts)
    local icon_picker = require("icon-picker")
    icon_picker.setup(opts)

    -- Custom function to insert icon and stay in normal mode
    local function insert_icon_normal_mode(icon)
      vim.api.nvim_put({ icon }, "", true, true)
    end

    -- Override the default insert behavior
    local original_pick = icon_picker.pick
    icon_picker.pick = function(pick_opts)
      pick_opts = pick_opts or {}
      pick_opts.callback = insert_icon_normal_mode
      original_pick(pick_opts)
    end
  end,
}
