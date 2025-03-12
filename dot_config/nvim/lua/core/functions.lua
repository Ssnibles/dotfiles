function getActiveLsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if next(clients) == nil then
    print("No active LSP clients")
  else
    for _, client in ipairs(clients) do
      print("Active LSP: " .. client.name)
    end
  end
end
