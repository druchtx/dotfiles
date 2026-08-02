-- Load dependency-free Neovim options before plugins begin opening buffers.
require("core.options")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("core.lazy")

-- Native mappings use LazyVim's leader, which is initialized by core.lazy.
require("core.keymaps")
