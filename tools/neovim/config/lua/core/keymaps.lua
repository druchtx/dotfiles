vim.g.mapleader = " "

-- Escape
vim.keymap.set({ "i", "v", "s" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>", { desc = "Escape terminal" })

-- Indentation
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })

-- Code
vim.keymap.set("n", "<leader>cf", function()
  vim.lsp.buf.format()
end, { desc = "Format code" })

-- Save, or open a diff when both Neovim and an external tool changed the file.
vim.keymap.set({ "n", "i" }, "<C-s>", function()
  require("features.sync_write").write()
end, { desc = "Sync and save file" })

-- Quit
local function close_with_confirmation(command)
  if not vim.bo.modified then
    vim.cmd(command)
    return
  end

  local choice = vim.fn.confirm(
    "Save changes to " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") .. "?",
    "&Save and close\n&Discard changes\n&Cancel",
    3
  )

  if choice == 1 then
    vim.cmd.write()
    vim.cmd(command)
  elseif choice == 2 then
    vim.cmd(command .. "!")
  end
end

vim.keymap.set("n", "<leader>bq", function()
  close_with_confirmation("bdelete")
end, { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>wq", function()
  close_with_confirmation("close")
end, { desc = "Quit window" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Quit tabpage" })
vim.keymap.set("n", "<leader>qq", "<cmd>quitall<cr>", { desc = "Quit Neovim" })
