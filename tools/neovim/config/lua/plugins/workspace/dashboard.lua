return {
  "snacks.nvim",
  keys = {
    {
      "<leader><tab>n",
      function()
        require("utils.tabpage").create({
          name = "dashboard",
          cwd = LazyVim.root(),
        })
        require("snacks").dashboard.open()
      end,
      desc = "New Dashboard Tab",
    },
    {
      "<leader><tab><tab>",
      "<cmd>tabnext<cr>",
      desc = "Next Tab",
    },
  },
  opts = function(_, opts)
    opts.dashboard = {
      enabled = true,
      width = 40,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
      },
      preset = {
        header = "",
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = " ",
            key = "p",
            desc = "Projects",
            action = "<cmd>ProjectPicker<cr>",
          },
          {
            icon = " ",
            key = "e",
            desc = "Explore",
            action = ":ExplorerRoot",
          },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "l",
            desc = "Restore Session",
            action = ":SessionLoadLast",
          },
          {
            icon = "󰑓 ",
            key = "s",
            desc = "Select Session",
            action = ":SessionSelect",
          },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    }
  end,
}
