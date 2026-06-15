local terminal_win = {
  position = "float",
  width = 0.6,
  height = 0.8,
  border = "rounded",
  backdrop = false,
  title = " TERMIANL ",
  title_pos = "center",
  keys = {
    ["<a-q>"] = { "<a-q>", "close", mode = { "n", "t" }, desc = "Quit" },
  },
}

local function toggle_project_terminal()
  Snacks.terminal.focus(nil, {
    count = 1,
    cwd = vim.fn.getcwd(),
    win = vim.deepcopy(terminal_win),
  })
end
return {
  "snacks.nvim",
  keys = {
    { "<C-/>", toggle_project_terminal, desc = "Terminal (Project Dir)", mode = { "n", "t" } },
    {
      "<C-_>",
      toggle_project_terminal,
      desc = "which_key_ignore",
      mode = { "n", "t" },
    },
  },
}
