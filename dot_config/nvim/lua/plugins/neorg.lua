return {
  "nvim-neorg/neorg",
  ft = { "norg", "neorg" },
  version = "*", -- Pin Neorg to the latest stable release
  config = true,
  opts = {
    load = {
      ["core.defaults"] = {},
      -- ["core.concealer"] = {}, -- Folds
      ["core.dirman"] = {
        config = {
          workspaces = {
            notes = "~/Notes",
          },
          default_workspace = "notes",
        },
      },
    },
  },
}
