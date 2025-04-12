return {
  "folke/snacks.nvim",
  event = "VimEnter",
  keys = {
    {
      "<leader>lg",
      function()
        Snacks.lazygit.open()
      end,
      desc = "Open Lazygit",
    },
    {
      "<leader>,",
      function()
        if not Snacks or not Snacks.dim then
          print("Snacks.dim is not available")
          return
        end
        Snacks.dim.enabled = not Snacks.dim.enabled
        Snacks.dim[Snacks.dim.enabled and "enable" or "disable"]()
        print("Snacks.dim " .. (Snacks.dim.enabled and "enabled (can take a while)" or "disabled"))
      end,
      desc = "Toggle Snacks.dim",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Find Buffers",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep Files",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Search Recent Files",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.spelling()
      end,
      desc = "Find Spelling",
    },
    {
      "<leader>sh",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Search Command History",
    },
    {
      "<leader>sn",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Search Notification History",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.man()
      end,
      desc = "Search Man Pages",
    },
    {
      "<leader>si",
      function()
        Snacks.picker.icons()
      end,
      desc = "Search Icons",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Search Colorschemes",
    },
    {
      "<leader>Ps",
      function()
        Snacks.profiler.start()
      end,
      desc = "Start Profiler",
    },
    {
      "<leader>PS",
      function()
        Snacks.profiler.stop()
      end,
      desc = "Stop Profiler and Show results",
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
      enabled = true,
      width = 65,
      row = nil,
      col = nil,
      preset = {
        header = [[
   ________  ________  ________  ________   ________  ________
  /    /   \/        \/        \/    /   \ /        \/        \
 /         /         /         /         /_/       //         /
/         /        _/         /\        //         /         /
\__/_____/\________/\________/  \______/ \________/\__/__/__/ ]],
      },
      sections = {
        { section = "header" },
        {
          section = "keys",
          gap = 1,
          padding = 0,
        },
        {
          padding = 1,
          text = { " " },
        },
        { section = "startup" },
      },
    },

    picker = {
      enabled = true,
      layout = {
        -- preset = "bottom" -- bottom, default, dropdown, ivy, ivy_split, left, right, select, sidebar, telescope, top, vertical, vscode
        preview = true,
        layout = {
          backdrop = false, -- Dim the background
          -- row = 1,
          width = 0.6, -- 50%
          min_width = 80,
          height = 0.6, -- 50%
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
          -- only conceal math expressions
          return type == "math"
        end,
      },
    },
    profiler = {
      autocmds = true,
    },
  },

  -- Function to call each plugin safely
  config = function(_, opts)
    local snacks = require("snacks")
    snacks.setup(opts)

    local function safe_call(obj, method)
      if type(obj[method]) == "function" then
        obj[method]()
      elseif type(obj[method]) == "table" and type(obj[method].enable) == "function" then
        obj[method].enable()
      end
    end

    -- Then call the plugins, add more in the same way
    safe_call(snacks, "dim")
    safe_call(snacks, "notifier")
    safe_call(snacks, "lazygit")
    safe_call(snacks, "indent")
    safe_call(snacks, "dashboard")
    safe_call(snacks, "picker")
    safe_call(snacks, "image")
    safe_call(snacks, "profiler")
  end,
}
