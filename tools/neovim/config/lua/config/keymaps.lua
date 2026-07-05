-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "s", "t" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })

-- Use `q` consistently for closing buffers, windows, and tabs.
for _, lhs in ipairs({ "<leader>bd", "<leader>bD", "<leader>wd", "<leader><tab>d" }) do
  pcall(vim.keymap.del, "n", lhs)
end

vim.keymap.set("n", "<leader>bq", function()
  Snacks.bufdelete()
end, { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bQ", "<cmd>bd<cr>", { desc = "Close Buffer and Window" })
vim.keymap.set("n", "<leader>wq", "<C-W>c", { desc = "Close Window", remap = true })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })

-- using vim.ui.select (LazyVim will use snacks automatically)
vim.keymap.set("n", "<leader>fm", function()
  vim.ui.select(vim.fn.getcompletion("", "filetype"), {
    prompt = "Select filetype:",
  }, function(choice)
    if choice then
      vim.bo.filetype = choice
    end
  end)
end, { desc = "Set filetype" })
