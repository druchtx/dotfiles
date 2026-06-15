-- Tab workspaces must be tracked before plugins start opening buffers.
require("config.tabs").setup()

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
