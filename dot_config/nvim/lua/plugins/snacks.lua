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
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, 5, right = 0.5, bottom = 0 },
      padding = true,
      sort = { "level", "time" },
      level = vim.log.levels.TRACE,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
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
    },
    picker = {
      enabled = true,
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
        layout = { preset = "vscode" },
        confirm = "item_action",
      },
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
  end,
}
