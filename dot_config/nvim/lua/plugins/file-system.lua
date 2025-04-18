-- MUST BE AT THE VERY TOP
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  {
    "stevearc/oil.nvim",
    priority = 1000, -- Critical for directory handling
    lazy = false, -- Required for proper initialization
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      {
        "<leader>oo",
        function()
          if require("oil").get_current_dir() then
            vim.cmd("bd")
          else
            vim.cmd("Oil")
          end
        end,
        desc = "Toggle Oil explorer",
      },
      {
        "<leader>ob",
        function()
          local oil = require("oil")
          if oil.get_current_dir() then
            vim.cmd("bd")
          else
            oil.open(vim.fn.expand("%:p:h"), {
              is_target_window = function()
                return true
              end,
              win_options = {
                wrap = false,
                signcolumn = "no",
                cursorcolumn = false,
                spell = false,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
              },
            })
          end
        end,
        desc = "Toggle Oil in current buffer",
      },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      buf_options = {
        buflisted = false,
        bufhidden = "wipe", -- Changed from 'hide'
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<leader>ov"] = "actions.select_vsplit",
        ["<leader>os"] = "actions.select_split",
        ["<leader>ot"] = "actions.select_tab",
        ["<leader>op"] = "actions.preview",
        ["<leader>oc"] = "actions.close",
        ["<leader>or"] = "actions.refresh",
        ["<BS>"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
        ["H"] = "actions.toggle_trash",
        ["<C-s>"] = "actions.change_sort",
        ["<C-h>"] = "actions.toggle_hidden",
      },
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true, -- Enable built-in trash functionality
      -- REMOVED: trash_command = "trash-put" (deprecated)
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
          return vim.startswith(name, ".")
        end,
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(event)
          if vim.fn.isdirectory(event.file) == 1 then
            vim.schedule(function()
              vim.cmd.bwipeout() -- Clear initial directory buffer
              require("oil").open(event.file)
            end)
          end
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
          vim.opt_local.signcolumn = "no"
          vim.opt_local.cursorline = true
          vim.keymap.set("n", "q", "<CMD>bd<CR>", { buffer = true })
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree filesystem toggle<cr>", desc = "Toggle Neotree" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      filesystem = {
        hijack_netrw_behavior = "disabled", -- Critical for compatibility
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
        follow_current_file = {
          enabled = true,
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
    },
  },
}
