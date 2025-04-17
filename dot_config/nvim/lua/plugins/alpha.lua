return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Calculate vertical centering padding
    local function get_padding()
      local total_lines = 0
      -- Count header lines
      total_lines = total_lines + #dashboard.section.header.val
      -- Count button lines (1 per button)
      total_lines = total_lines + #dashboard.section.buttons.val
      -- Count footer lines (1 in this case)
      total_lines = total_lines + 1

      -- Calculate available space (subtract 2 for cmdline)
      local available_space = vim.o.lines - 2
      -- Calculate top padding (half of remaining space)
      local padding = math.max(0, math.floor((available_space - total_lines) / 3))

      return padding
    end

    -- Set header
    dashboard.section.header.val = {
      " ∧,,,∧",
      "(• ⩊ •)",
      "|￣U U￣￣￣￣￣￣￣￣￣|",
      "| Just give up          |",
      "|                       |",
      " ￣￣￣￣￣￣￣￣￣￣￣￣",
    }
    dashboard.section.header.opts.hl = "Type"

    -- Set menu buttons
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find File", "<cmd>Telescope find_files<cr>"),
      dashboard.button("t", "  Find Text", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("n", "  New File", "<cmd>ene | startinsert<cr>"),
      dashboard.button("c", "  Config", "<cmd>Telescope find_files cwd=" .. vim.fn.stdpath("config") .. "<cr>"),
      dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
    }

    -- Set footer
    dashboard.section.footer.val = "What the sigma"
    dashboard.section.footer.opts.hl = "Comment"

    -- Set layout with dynamic padding
    dashboard.config.layout = {
      { type = "padding", val = get_padding() },
      dashboard.section.header,
      { type = "padding", val = 2 }, -- Space between header and buttons
      dashboard.section.buttons,
      { type = "padding", val = 1 }, -- Space between buttons and footer
      dashboard.section.footer,
    }

    -- Setup alpha
    alpha.setup(dashboard.config)

    -- Autocommands for statusline
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.opt.laststatus = 0
        vim.opt.showtabline = 0
      end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      callback = function()
        vim.opt.laststatus = 1 -- Changed from 3 to 1
        vim.opt.showtabline = 0 -- Changed from 2 to 0
      end,
    })
  end,
}
