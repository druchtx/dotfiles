local M = {}

M.ds_store_exclude = {
  ".DS_Store",
  "**/.DS_Store",
}

function M.is_ds_store(path)
  return vim.fs.basename(path or "") == ".DS_Store"
end

return M
