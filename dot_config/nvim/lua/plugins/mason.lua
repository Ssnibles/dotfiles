return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 1,
        },
      },
      progress = {
        ignore = { "^null-ls" },
      },
    },
    config = function(_, opts)
      require("fidget").setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            require("fidget").notify(string.format("LSP %s attached", client.name), "info")
          end
        end,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            require("fidget").notify(string.format("LSP %s detached", client.name), "info")
          end
        end,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "j-hui/fidget.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "bashls", "ast_grep", "pylsp" }  -- Add more packages to be auto-installed
      })

      local function load_lsp_for_filetype(client_name, filetypes, config)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = filetypes,
          callback = function()
            local lspconfig = require("lspconfig")

            local clients = vim.lsp.get_clients()
            for _, client in ipairs(clients) do
              if client.name == client_name then
                return
              end
            end

            local setup_config = vim.tbl_deep_extend("force", {}, config or {})
            lspconfig[client_name].setup(setup_config)

            vim.schedule(function()
              local ok, err = pcall(vim.cmd, "LspStart " .. client_name)
              if not ok then
                require("fidget").notify("Failed to start " .. client_name .. ": " .. err, "error")
              else
                require("fidget").notify(client_name .. " started for " .. vim.bo.filetype, "info")
              end
            end)
          end,
          once = true,
        })
      end

      -- Setup which file types are which LSP and load accordingly
      load_lsp_for_filetype("lua_ls", { "lua" })
      load_lsp_for_filetype("tsserver", { "javascript", "typescript", "javascriptreact", "typescriptreact" })
      load_lsp_for_filetype("bashls", { "sh", "bash" })
      load_lsp_for_filetype("ast_grep", { "dart" })
      load_lsp_for_filetype("pylsp", { "python" })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local bufOpts = { buffer = ev.buf }
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufOpts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufOpts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, bufOpts)
        end,
      })
    end
  }
}
