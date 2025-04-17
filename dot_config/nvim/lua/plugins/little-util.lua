-- A few utility plugins
return {
  {
    enabled = false,
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
        html = { names = true },
      }, {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
      })
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPost",
    opts = {
      render = "virtual", -- 'background' or 'foreground' or 'virtual'
      virtual_symbol = "",
      enable_named_colors = true,
    },
  },
  {
    -- enabled = false,
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
          border = "none",
          zindex = 45,
          max_width = 0,
          max_height = 0,
          x_padding = 0,
          y_padding = 0,
          align = "bottom",
          relative = "editor",
        },
      },
      progress = {
        ignore = { "^null-ls" },
        suppress_on_insert = true,
        ignore_done_already = true,
        ignore_empty_message = true,
      },
      display = {
        done_ttl = 3,
        done_icon = "✔",
        done_style = "Constant",
        progress_icon = { "dots" },
      },
      view = { stack_upwards = true },
    },
  },
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    enabled = false,
    config = function()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 1 },
          placement = { horizontal = "right", vertical = "top" },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified

          return {
            ft_icon and { " ", ft_icon, " " } or "",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#44406e",
            guifg = "#ffffff",
          }
        end,
      })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "meznaric/key-analyzer.nvim",
    cmd = "KeyAnalyzer",
    opts = {
      command_name = "KeyAnalyzer",
      highlights = {
        bracket_used = "KeyAnalyzerBracketUsed",
        letter_used = "KeyAnalyzerLetterUsed",
        bracket_unused = "KeyAnalyzerBracketUnused",
        letter_unused = "KeyAnalyzerLetterUnused",
        promo_highlight = "KeyAnalyzerPromo",
        define_default_highlights = true,
      },
      layout = "qwerty",
    },
  },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        auto_load = true,
        -- theme = "dark",
        update_on_change = true,
        filetype = { "markdown" },
        app = { "zen-browser", "--new-window" },
      })
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
  {
    -- TODO:
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>tt",
        function()
          Snacks.picker.todo_comments({ keywords = { "TODO" } })
        end,
        desc = "Todo",
      },
    },
    opts = {
      signs = true,
    },
  },
  {
    "gbprod/yanky.nvim",
    -- event = "InsertEnter",
    dependencies = {
      { "kkharji/sqlite.lua" },
    },
    opts = {
      ring = { storage = "sqlite" },
    },
    keys = {
      {
        "<leader>p",
        "<cmd>YankyRingHistory<cr>",
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      {
        "y",
        "<Plug>(YankyYank)",
        mode = { "n", "x" },
        desc = "Yank text",
      },
      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = { "n", "x" },
        desc = "Put yanked text after cursor",
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        mode = { "n", "x" },
        desc = "Put yanked text before cursor",
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        mode = { "n", "x" },
        desc = "Put yanked text after selection",
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        mode = { "n", "x" },
        desc = "Put yanked text before selection",
      },
      { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
      { "<c-n>", "<Plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = "TogggleTerm",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            -- Calculate 30% of the current window width
            return math.floor(vim.api.nvim_win_get_height(0) * 0.6)
          end
        end,
        direction = "horizontal",
        open_mapping = [[<c-\>]],
        shading_factor = 2,
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
      })
    end,
  },
  {
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    opts = {
      retirementAgeMins = 10,
      minimumBufferNum = 0,
      notificationOnAutoClose = true,
    },
  },
  {
    "pogyomo/winresize.nvim",
  },
}
