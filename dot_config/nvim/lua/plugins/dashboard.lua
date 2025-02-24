return {
  "nvimdev/dashboard-nvim",
  enabled = false,
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
        header = {
          "$ųçķ mý bäłł§  ( ͡° ͜ʖ ͡°)",
          "                       ",
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
            action = function() require("fzf-lua").files() end,
          },
          {
            icon = "󰊄 ",
            desc = "Recent Files",
            key = "r",
            keymap = "SPC f r",
            action = function() require("fzf-lua").oldfiles() end,
          },
          {
            icon = "󰈭 ",
            desc = "Live Grep",
            key = "g",
            keymap = "SPC f g",
            action = function() require("fzf-lua").live_grep() end,
          },
          -- {
          --   icon = "󰓾 ",
          --   desc = "Buffers",
          --   key = "b",
          --   keymap = "SPC f b",
          --   action = function() require("fzf-lua").buffers() end,
          -- },
          {
            icon = " ",
            desc = "Help Tags",
            key = "h",
            keymap = "SPC f h",
            action = function() require("fzf-lua").help_tags() end,
          },
          {
            icon = " ",
            desc = "Find Directory",
            key = "d",
            keymap = "SPC f d",
            action = function()
              require("fzf-lua").fzf_exec("find . -type d", {
                actions = {
                  ["default"] = function(selected)
                    vim.cmd("cd " .. selected[1])
                  end
                },
                prompt = "Select Directory> ",
                previewer = "fzf-lua.previewers.vim_buffer_dir",
              })
            end,
          },
          {
            icon = "󰒲 ",
            desc = "Lazy",
            key = "l",
            action = "Lazy",
          },
          {
            icon = "󰩈 ",
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
  dependencies = { { "nvim-tree/nvim-web-devicons" }, { "ibhagwan/fzf-lua" } }
}
