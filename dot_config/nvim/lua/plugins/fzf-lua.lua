return {
  "ibhagwan/fzf-lua",
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

    vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Find help tags" })
    vim.keymap.set("n", "<leader>fd", function()
      fzf.fzf_exec("find . -type d", {
        actions = {
          ["default"] = function(selected)
            vim.cmd("cd " .. selected[1])
          end
        },
        prompt = "Select Directory> ",
        previewer = "fzf.previewers.vim_buffer_dir",
      })
    end, { desc = "Find and open directory" })
  end,
}
