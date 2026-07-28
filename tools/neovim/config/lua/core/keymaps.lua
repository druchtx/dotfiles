vim.g.mapleader = " "

-- Escape
vim.keymap.set({ "i", "v", "s" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>", { desc = "Escape terminal" })

-- Indentation
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent" })

-- Quit
vim.keymap.set("n", "<leader>bq", "<cmd>bdelete<cr>", { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>wq", "<cmd>close<cr>", { desc = "Quit window" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Quit tabpage" })
vim.keymap.set("n", "<leader>qq", "<cmd>quitall<cr>", { desc = "Quit Neovim" })
