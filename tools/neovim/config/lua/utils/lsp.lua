local M = {}

---@param bufnr integer
---@param client_name? string
---@return string?
function M.root(bufnr, client_name)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if not client_name or client.name == client_name then
      local root = client.root_dir
      if type(root) ~= "string" and client.config then
        root = client.config.root_dir
      end
      if type(root) == "string" and root ~= "" then
        return root
      end
    end
  end
end

return M
