return {
  "folke/snacks.nvim",
  event = "VimEnter",
  keys = {
    {
      "<leader>,",
      function()
        local dim_enabled = not require("snacks.dim").config.enabled
        require("snacks.dim").config.enabled = dim_enabled
        require("snacks.dim")[dim_enabled and "enable" or "disable"]()
        print("Snacks.dim " .. (dim_enabled and "enabled (can take a while)" or "disabled"))
      end,
      desc = "Toggle Snacks.dim",
    },
  },
  opts = {
    dim = {
      enabled = true,
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
      animate = { enabled = false },
    },
    notifier = {
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0.5, right = 0.5, bottom = 0 },
      padding = true,
      sort = { "level", "time" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "compact",
    },
    lazygit = {
      enabled = true,
      configure = true,
      gui = {
        nerdFontVersion = "3",
      },
      win = {
        style = "lazygit",
      },
    },
    indent = {
      enabled = true,
      priority = 1,
      char = "│",
      scope = {
        enabled = true,
        show_start = true,
        show_end = true,
      },
      animate = { enabled = false },
    },
    dashboard = {
      enabled = false,
      width = 40,
      sections = {
        {
          padding = 2,
          text = {
            { "“Life is like a Jar of Pickles” — Socrates", hl = "NonText", align = "center" },
          },
        },
        {
          padding = 1,
          text = {
            { "  Find File    [f]", hl = "Normal", align = "center" },
          },
          action = ":lua Snacks.dashboard.pick('files')",
          key = "f",
        },
        {
          text = {
            { "  Find Text    [t]", hl = "Normal", align = "center" },
          },
          action = ":lua Snacks.dashboard.pick('live_grep')",
          key = "t",
        },
        {
          text = {
            { "  Recent Files [r]", hl = "Normal", align = "center" },
          },
          action = ":lua Snacks.dashboard.pick('oldfiles')",
          key = "r",
        },
        {
          text = {
            { "  New File     [n]", hl = "Normal", align = "center" },
          },
          action = ":ene | startinsert",
          key = "n",
        },
        {
          text = {
            { "  Config       [c]", hl = "Normal", align = "center" },
          },
          action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
          key = "c",
        },
        {
          text = {
            { "󰒲  Lazy         [l]", hl = "Normal", align = "center" },
          },
          action = ":Lazy",
          key = "l",
        },
        {
          text = {
            { "  Quit         [q]", hl = "Normal", align = "center" },
          },
          action = ":quitall",
          key = "q",
        },
        {
          text = " ",
          padding = 1,
        },
        {
          text = {
            { "What the sigma", hl = "NonText", align = "center" },
          },
        },
      },
      formats = { key = { "" } },
    },
    picker = {
      enabled = false,
      layout = {
        preview = true,
        layout = {
          backdrop = false,
          width = 0.6,
          min_width = 80,
          height = 0.6,
          border = "none",
          box = "vertical",
          {
            win = "input",
            height = 1,
            border = "single",
            title = "{title} {live} {flags}",
            title_pos = "center",
          },
          {
            win = "list",
            border = "hpad",
          },
          {
            win = "preview",
            title = "{preview}",
            border = "single",
          },
        },
      },
      matcher = {
        fuzzy = true,
        smartcse = true,
        ignorecase = true,
        sort_empty = true,
        filename_bonus = true,
        file_pos = true,
        history_bonus = true,
      },
      ui_select = true,
      previewers = {
        diff = {
          builtin = false,
          cmd = { "bat" },
        },
        git = {
          builtin = true,
        },
      },
      recent = {
        finder = "recent_files",
        format = "file",
      },
      spelling = {
        finder = "vim_spelling",
        format = "text",
        confirm = "item_action",
      },
    },
    image = {
      formats = {
        "png",
        "jpg",
        "jpeg",
        "gif",
        "bmp",
        "webp",
        "tiff",
        "heic",
        "avif",
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "pdf",
      },
      doc = {
        enabled = true,
        inline = true,
        float = false,
        max_width = 80,
        max_height = 40,
        conceal = function(lang, type)
          return type == "math"
        end,
      },
    },
    profiler = {
      autocmds = true,
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
  end,
}
