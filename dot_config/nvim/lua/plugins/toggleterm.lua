return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- Base configuration
      size = 20,
      open_mapping = [[<c-\>]],
      shading_factor = 2,
      direction = "float",
      close_on_exit = true,

      -- Float window configuration
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        winblend = 3,
      },

      -- Terminal appearance
      -- highlights = {
      --   Normal = {
      --     guibg = "#1a1b26",
      --   },
      --   NormalFloat = {
      --     link = "Normal",
      --   },
      --   FloatBorder = {
      --     guifg = "#7aa2f7",
      --     guibg = "#1a1b26",
      --   },
      -- },

      -- Shell configuration
      shell = vim.o.shell,
      auto_scroll = true,
    })

    -- Custom terminal commands
    local Terminal = require("toggleterm.terminal").Terminal

    -- Add any custom terminals you want here, for example:
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      hidden = true,
    })

    -- vim.keymap.set("n", "<leader>gg", function()
    --   lazygit:toggle()
    -- end, { desc = "Toggle lazygit" })
  end,
}
