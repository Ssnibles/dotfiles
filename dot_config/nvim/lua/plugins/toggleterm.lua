return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- Base configuration
      size = 15, -- Percentage of the window
      open_mapping = [[<c-\>]],
      shading_factor = 2,
      direction = "horizontal", -- Change to horizontal
      close_on_exit = true,

      -- Horizontal split configuration
      -- No need for float_opts anymore

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
      direction = "horizontal", -- Change lazygit to horizontal as well
      hidden = true,
    })

    -- vim.keymap.set("n", "<leader>gg", function()
    --   lazygit:toggle()
    -- end, { desc = "Toggle lazygit" })
  end,
}
