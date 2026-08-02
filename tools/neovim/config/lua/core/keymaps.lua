-- Universal input mappings that do not belong to a workflow or plugin domain.

vim.keymap.set({ "i", "v", "s", "t" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })
