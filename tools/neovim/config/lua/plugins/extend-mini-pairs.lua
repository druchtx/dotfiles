return {
  "nvim-mini/mini.pairs",
  event = "InsertEnter",
  opts = {
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  },
  config = function(_, opts)
    require("mini.pairs").setup(opts)
    local map_bs = function(lhs, rhs)
      vim.keymap.set("i", lhs, rhs, { expr = true, replace_keycodes = false, desc = "MiniPairs backspace" })
    end

    map_bs("<C-h>", "v:lua.MiniPairs.bs()")
    map_bs("<C-w>", 'v:lua.MiniPairs.bs("\23")')
    map_bs("<C-u>", 'v:lua.MiniPairs.bs("\21")')
  end,
}
