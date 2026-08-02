-- Select the current buffer's filetype through Neovim's configured UI picker.
local M = {}

function M.select()
  vim.ui.select(vim.fn.getcompletion("", "filetype"), {
    prompt = "Select filetype:",
  }, function(choice)
    if choice then
      vim.bo.filetype = choice
    end
  end)
end

-- Feature mapping: manually correct or change filetype detection for a buffer.
vim.keymap.set("n", "<leader>ft", M.select, { desc = "Set filetype" })

return M
