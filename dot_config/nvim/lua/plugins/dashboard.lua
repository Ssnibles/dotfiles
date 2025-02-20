return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup {
      theme = "doom",
      hide = {
        statusline = true,
        tabline = true,
        winbar = true,
      },
      config = {
        -- header = {
        --   "    ____                      __                  ",
        --   "   / __/_  ______  _____    _/_/                  ",
        --   "  / /_/ / / / __ \\/ ___/  _/_/                    ",
        --   " / __/ /_/ / / / / /__   < <                      ",
        --   "/_/ _\\__,_/_/_/_/\\___/ __/ /                    _ ",
        --   "   / __ )(_) /| |     / /\\_\\ __   _____        | |",
        --   "  / __  / / __/ | /| / / __ `/ | / / _ \\       / /",
        --   " / /_/ / / /_ | |/ |/ / /_/ /| |/ /  __/      _>_>",
        --   "/_____/_/\\__/ |__/|__/\\__,_/ |___/\\___/     _/_/  ",
        --   "                                           /_/    ",
        -- },
        -- header = {
        --   "$ųçķ mý bäłł§  ( ͡° ͜ʖ ͡°)",
        --   "                       ",
        -- },
        header = {
          "⠀⠀⢘⣾⣾⣿⣾⣽⣯⣼⣿⣿⣴⣽⣿⣽⣭⣿⣿⣿⣿⣿⣧",
          "⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
          "⠀⠠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
          "⠀⣰⣯⣾⣿⣿⡼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿",
          "⠀⠛⠛⠋⠁⣠⡼⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁",
          "⠀⠀⠤⣶⣾⣿⣿⣿⣦⡈⠉⠉⠉⠙⠻⣿⣿⣿⣿⣿⠿⠁⠀",
          "⠀⠀⠀⠈⠟⠻⢛⣿⣿⣿⣷⣶⣦⣄⠀⠸⣿⣿⣿⠗⠀⠀⠀",
          "⠀⠀⠀⠀⣼⠀⠄⣿⡿⠋⣉⠈⠙⢿⣿⣦⣿⠏⡠⠂⠀⠀⠀",
          "⠀⠀⠀⢰⡌⠀⢠⠏⠇⢸⡇⠐⠀⡄⣿⣿⣃⠈⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠈⣻⣿⢫⢻⡆⡀⠁⠀⢈⣾⣿⠏⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⢀⣿⣻⣷⣾⣿⣿⣷⢾⣽⢭⣍⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⣼⣿⣿⣿⣿⡿⠈⣹⣾⣿⡞⠐⠁⠀⠀⠀⠁⠀⠀⠀",
          "⠀⠀⠨⣟⣿⢟⣯⣶⣿⣆⣘⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀",
          "⠀⠀⠀⠀⡆⠀⠐⠶⠮⡹⣸⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
          "                       ",
        },
        center = {
          {
            icon = "󰈞 ",
            icon_hl = "Title",
            desc = "Find File",
            desc_hl = "String",
            key = "f",
            keymap = "SPC f f",
            key_hl = "Number",
            action = function()
              require("telescope.builtin").find_files { hidden = true }
            end,
          },
          {
            icon = "󰊄 ",
            desc = "Recent Files",
            key = "r",
            action = "Telescope oldfiles",
          },
          {
            icon = "󰈭 ",
            desc = "Find Word",
            key = "w",
            action = function()
              require("telescope.builtin").live_grep { additional_args = { "--hidden" } }
            end,
          },
          {
            icon = "󰓾 ",
            desc = "Bookmarks",
            key = "b",
            keymap = "SPC f b",
            action = "Telescope marks",
          },
          {
            icon = " ",
            desc = "New File",
            key = "n",
            action = "enew",
          },
          {
            icon = "󰒲 ",
            desc = "Lazy",
            key = "l",
            action = "Lazy",
          },
          {
            icon = " ",
            desc = "Quit",
            key = "q",
            keymap = "SPC q",
            action = "qa",
          },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
        vertical_center = true,
      },
    }
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } }
}
