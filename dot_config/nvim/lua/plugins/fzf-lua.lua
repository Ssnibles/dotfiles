return {
  "ibhagwan/fzf-lua",
  -- enabled = false,
  keys = {
    { "<leader>ff", function() require("fzf-lua").files() end,       desc = "Find files" },
    { "<leader>fg", function() require("fzf-lua").live_grep() end,   desc = "Live grep" },
    { "<leader>fb", function() require("fzf-lua").buffers() end,     desc = "Find buffers" },
    { "<leader>fh", function() require("fzf-lua").help_tags() end,   desc = "Find help tags" },
    { "<leader>fr", function() require("fzf-lua").oldfiles() end,    desc = "Find recent files" },
    { "<leader>/",  function() require("fzf-lua").grep_curbuf() end, desc = "Grep current buffer" }, -- New keymap
    {
      "<leader>fd",
      function()
        require("fzf-lua").fzf_exec("find . -type d", {
          actions = {
            ["default"] = function(selected)
              vim.cmd("cd " .. selected[1])
            end
          },
          prompt = "Find Directory > ",
        })
      end,
      desc = "Find and open directory"
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    local actions = require("fzf-lua.actions")

    fzf.setup({
      winopts = {
        height = 0.9,
        width = 0.9,
        preview = {
          default = "bat",
          vertical = "down:60%",
          horizontal = "right:50%",
          layout = "flex",
          flip_columns = 120,
        },
      },
      fzf_opts = {
        ["--layout"] = "reverse",
      },
      files = {
        previewer = "bat",
      },
      grep = {
        previewer = "bat",
        actions = {
          ["default"] = actions.file_edit,
        },
      },
      buffers = {
        previewer = "bat",
      },
      helptags = {
        previewer = "builtin",
      },
    })
  end,
}
