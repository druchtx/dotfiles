-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "s", "t" }, "<C-g>", "<Esc>", { desc = "Escape" })

-- Toggle diff: buffer vs file on disk (see external changes)
vim.keymap.set("n", "<leader>fd", "<cmd>DiffDisk<cr>", { desc = "File diff (toggle)" })

-- Diff current buffer with another file
vim.keymap.set("n", "<leader>fD", function()
  vim.ui.input({ prompt = "Diff with file: ", completion = "file" }, function(filepath)
    if filepath then
      vim.cmd("DiffWith " .. filepath)
    end
  end)
end, { desc = "File diff with..." })

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
