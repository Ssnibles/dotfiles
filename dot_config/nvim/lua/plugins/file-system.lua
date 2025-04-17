return {
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
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        filesystem = {
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
      })
    end,
  },
  {
    "stevearc/oil.nvim",
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
            -- If already in oil buffer, close it
            vim.cmd("bd")
          else
            -- Open oil in current buffer with enhanced options
            oil.open(vim.fn.expand("%:p:h"), {
              -- Use current buffer instead of opening new one
              is_target_window = function()
                return true
              end,
              -- Keep the same window options
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
      -- Improved buffer options
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      -- Enhanced window options
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
        number = true,
        relativenumber = true,
      },
      -- More comprehensive keymaps
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
      -- Better editing experience
      skip_confirm_for_simple_edits = true,
      delete_to_trash = false,
      trash_command = "trash-put",
      -- View customization
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
          return vim.startswith(name, ".")
        end,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(_, opts)
      require("oil").setup(opts)

      -- Improved autocmds for better window management
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          -- Set local options for oil buffers
          vim.opt_local.number = true
          vim.opt_local.signcolumn = "no"
          vim.opt_local.cursorline = true
        end,
      })

      -- Automatically focus oil window when opened
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          if vim.bo.filetype == "oil" then
            vim.cmd("norm! gg")
          end
        end,
      })
    end,
  },
}
