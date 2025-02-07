return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      -- Add any Neotree specific configuration here if needed
      -- For example:
      -- require("neo-tree").setup({
      --   -- Your Neotree configuration options
      -- })

      -- Set up keymap
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree filesystem toggle left<CR>', { desc = 'Toggle Neotree' })
    end,
    keys = {
      { "<leader>e", desc = "Toggle Neotree" },
    },
  }
}
