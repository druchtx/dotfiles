-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "s", "t" }, "<C-g>", "<Esc>", { desc = "Escape" })

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
