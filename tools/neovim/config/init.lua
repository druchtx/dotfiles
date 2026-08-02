-- Neovim rebuild entrypoint.
--
-- Keep this file intentionally minimal. Add behavior only after its native
-- Neovim responsibility and any plugin dependency have been understood.

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Load native user workflows. Each feature owns its implementation and mappings.
require("features.close")
require("features.filetype")
require("features.buffer_save")

require("core.lazy")
