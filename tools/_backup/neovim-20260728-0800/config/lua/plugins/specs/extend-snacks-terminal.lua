local terminal_win = {
  position = "bottom",
  height = 0.4,
  keys = {
    ["<a-q>"] = { "<a-q>", "close", mode = { "n", "t" }, desc = "Quit" },
    ["<a-m>"] = {
      "<a-m>",
      function()
        Snacks.toggle.zoom():toggle()
      end,
      mode = { "n", "t" },
      desc = "Toggle Maximize",
    },
  },
}

local function toggle_project_terminal()
  Snacks.terminal.focus(nil, {
    count = 1,
    cwd = LazyVim.root(),
    win = vim.deepcopy(terminal_win),
  })
end
return {
  "snacks.nvim",
  keys = {
    { "<leader>ft", false },
    { "<leader>fT", false },
    { "<C-/>", toggle_project_terminal, desc = "Terminal (Project Root)", mode = { "n", "t" } },
    {
      "<C-_>",
      toggle_project_terminal,
      desc = "which_key_ignore",
      mode = { "n", "t" },
    },
  },
}
