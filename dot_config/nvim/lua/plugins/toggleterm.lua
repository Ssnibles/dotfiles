return {
  "akinsho/toggleterm.nvim",
  event = { "BufReadPre", "BufNewFile" },
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

    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "horizontal",
      hidden = true,
    })
  end,
}
