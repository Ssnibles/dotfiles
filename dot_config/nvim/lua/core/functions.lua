local function getActiveLsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if next(clients) == nil then
    print("No active LSP clients")
  else
    for _, client in ipairs(clients) do
      print("Active LSP: " .. client.name)
    end
  end
end

local M = {} -- Module table

-- Function to get a centered width
function M.get_centered_width(percentage, min_width)
  local current_win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(current_win)
  local centered_width = width * percentage
  return math.max(centered_width, min_width or 0) -- Ensure minimum width
end

-- Function to get a centered height
function M.get_centered_height(percentage, min_height)
  local current_win = vim.api.nvim_get_current_win()
  local height = vim.api.nvim_win_get_height(current_win)
  local centered_height = height * percentage
  return math.max(centered_height, min_height or 0)
end

return M
