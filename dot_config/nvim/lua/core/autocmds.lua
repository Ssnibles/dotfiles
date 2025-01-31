--             __                                         __
--  ___ ___ __/ /____  _______  __ _  __ _  ___ ____  ___/ /__
-- / _ `/ // / __/ _ \/ __/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
-- \_,_/\_,_/\__/\___/\__/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/

--  see `:help lua-guide-autocommands`

-- Define the "currentline" sign, this sign is displayed next to the left of the active line number
vim.fn.sign_define("currentline", { text = "▶", texthl = "LineNr" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = (function()
    local highlight_group = "IncSearch"
    local timeout = 300

    return function()
      vim.highlight.on_yank { higroup = highlight_group, timeout = timeout }
    end
  end)(),
})

-- Highlight current line
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  desc = "Highlight current line",
  group = vim.api.nvim_create_augroup("highlight-current-line", { clear = true }),
  callback = (function()
    local sign_name = "currentline"
    local group_name = "currentlinegroup"
    local is_sign_defined = false

    return function()
      local current_line = vim.fn.line "."
      local bufnr = vim.api.nvim_get_current_buf()

      if not is_sign_defined then
        is_sign_defined = #vim.fn.sign_getdefined(sign_name) > 0
      end

      if is_sign_defined then
        vim.fn.sign_unplace(group_name, { buffer = bufnr })
        vim.fn.sign_place(0, group_name, sign_name, bufnr, { lnum = current_line })
      end
    end
  end)(),
})

-- Auto-resize splits when Vim is resized
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Auto-resize splits when Vim is resized",
  group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
  callback = function()
    vim.cmd.tabdo "wincmd ="
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  group = vim.api.nvim_create_augroup("remove-trailing-whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos "."
    local save_view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(save_view)
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Auto-reload files when changed externally",
  group = vim.api.nvim_create_augroup("auto-reload-file", { clear = true }),
  callback = (function()
    local ignored_filetypes = { "gitcommit" }

    return function()
      if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      if not vim.bo.readonly and filepath ~= "" and vim.loop.fs_stat(filepath) then
        vim.cmd("checktime " .. bufnr)
      end
    end
  end)(),
})

-- Set wrap and spell for text filetypes
vim.api.nvim_create_autocmd("FileType", {
  desc = "Set wrap and spell for text filetypes",
  group = vim.api.nvim_create_augroup("text-wrap-spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Auto-format on save for specific filetypes
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Auto-format on save for specific filetypes",
  group = vim.api.nvim_create_augroup("auto-format", { clear = true }),
  callback = (function()
    local format_filetypes = {
      lua = true,
      python = true,
      javascript = true,
      typescript = true,
      javascriptreact = true,
      typescriptreact = true,
      go = true,
      cpp = true,
      c = true,
      cs = true,
      rust = true,
      json = true,
      yaml = true,
      markdown = true,
      html = true,
      css = true,
    }

    return function()
      if format_filetypes[vim.bo.filetype] then
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients { bufnr = bufnr }

        -- Check if there are any active LSP clients
        if #clients == 0 then
          vim.notify("No active LSP clients for this buffer", vim.log.levels.WARN)
          return
        end

        local formatted = false
        for _, client in ipairs(clients) do
          if client.supports_method "textDocument/formatting" then
            vim.lsp.buf.format {
              async = false,
              bufnr = bufnr,
              filter = function(c)
                return c.id == client.id
              end,
            }
            formatted = true
            break
          end
        end

        if not formatted then
          vim.notify("No LSP formatting capability for this buffer", vim.log.levels.WARN)
        end
      end
    end
  end)(),
})

-- Add blankline at the end of a file
vim.api.nvim_create_autocmd("BufWritePost", {
  desc = "Add blank line at end of file",
  group = vim.api.nvim_create_augroup("add_blank_line", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, -2, -1, false)
    if #lines == 1 and lines[1] ~= "" then
      local save_cursor = vim.fn.getpos "."
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
      vim.fn.setpos(".", save_cursor)
    end
  end,
})
