-- Neovim rebuild entrypoint.
--
-- Keep this file intentionally minimal. Add behavior only after its native
-- Neovim responsibility and any plugin dependency have been understood.

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lazy")
