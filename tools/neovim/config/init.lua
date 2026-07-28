-- Neovim rebuild entrypoint.
--
-- Keep this file intentionally minimal. Add behavior only after its native
-- Neovim responsibility and any plugin dependency have been understood.

require("core.options")
require("core.keymaps")
require("core.lazy")

local startup = require("learning.startup")

assert(startup.config_dir == vim.fn.stdpath("config"))
