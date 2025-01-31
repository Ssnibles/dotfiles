return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files {
          hidden = true,
          no_ignore = false,
          find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git", "--max-depth", "5" },
        }
      end,
      desc = "Find files (including hidden)",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep {
          additional_args = { "--hidden", "--glob", "!**/.git/*", "--max-depth", "5" },
          only_sort_text = true,
        }
      end,
      desc = "Live grep (including hidden)",
    },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
    { "<leader>fs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
    { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy find in current buffer" },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").find_files {
          hidden = true,
          no_ignore = false,
          find_command = { "fd", "--type", "d", "--hidden", "--follow", "--exclude", ".git", "--max-depth", "5" },
          attach_mappings = function(prompt_bufnr, map)
            local actions = require "telescope.actions"
            local action_state = require "telescope.actions.state"

            map("i", "<CR>", function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              -- Open the selected directory using vim.cmd.cd and then open it
              vim.cmd.cd(selection.path)
              vim.cmd.edit "."
            end)

            return true
          end,
        }
      end,
      desc = "Find and open directories",
    },
  },
  opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = "▶ ",
      path_display = { "truncate" },
      file_ignore_patterns = { ".git/", "node_modules/", "%.lock" },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob",
        "!**/.git/*",
        "--max-depth",
        "5",
      },
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.5,
          results_width = 0.6,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
      set_env = { ["COLORTERM"] = "truecolor" },
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    },
    pickers = {
      find_files = {
        find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git", "--max-depth", "5" },
      },
      live_grep = {
        only_sort_text = true,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)
    telescope.load_extension "fzf"
  end,
}
