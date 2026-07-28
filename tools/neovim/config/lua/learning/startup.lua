-- A side-effect-free module used to learn Neovim's Lua loading rules.

return {
  config_dir = vim.fn.stdpath("config"),
  data_dir = vim.fn.stdpath("data"),
  state_dir = vim.fn.stdpath("state"),
  cache_dir = vim.fn.stdpath("cache"),
}
