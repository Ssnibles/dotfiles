return {
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "ibhagwan/fzf-lua",
    },
    keys = {
      { "<leader>nc", "<cmd>lua require('neoclip.fzf')()<cr>",    desc = "Neoclip (FZF)" },
      { "<leader>ny", "<cmd>lua require('neoclip.fzf')('y')<cr>", desc = "Yank History" },
      { "<leader>np", "<cmd>lua require('neoclip.fzf')('p')<cr>", desc = "Paste History" },
    },
    config = function()
      require("neoclip").setup({
        enable_persistent_history = true,
        keys = {
          fzf = {
            select = function()
              -- Use fzf-lua through neoclip's integration
              require("neoclip.fzf")("a") -- 'a' for all, 'y' for yanks, 'p' for pastes
            end,
          },
        },
      })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    -- Optional: Lazy-load on first use
    cmd = { "FzfLua" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          preview = {
            default = "bat",
            border = "rounded",
          },
        },
      })
    end,
  },
}
