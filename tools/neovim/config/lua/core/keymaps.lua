vim.g.mapleader = " "

-- Native editing keys that do not belong to a feature or plugin.
vim.keymap.set({ "i", "v", "s" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>", { desc = "Escape terminal" })
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })

-- Wrapped-line navigation: move by display rows unless an explicit count is
-- provided, in which case preserve Vim's normal physical-line movement.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
