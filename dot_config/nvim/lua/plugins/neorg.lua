return {
  {
    "vhyrro/luarocks.nvim",
    ft = "norg",
    event = { "BufReadPre", "BufNewFile" },
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "vhyrro/luarocks.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = ":Neorg sync-parsers",
    ft = "norg",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              icon_preset = "basic",
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
        },
      })
    end,
  },
}
