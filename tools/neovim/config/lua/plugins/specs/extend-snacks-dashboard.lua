return {
  "snacks.nvim",
  keys = {
    {
      "<leader><tab>n",
      function()
        local tabs = require("config.tabs")
        tabs.open_project_tab(tabs.project() or LazyVim.root())
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
          { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
          {
            icon = " ",
            key = "e",
            desc = "Explore",
            action = function()
              require("plugins.modules.explorer").open({ cwd = LazyVim.root() })
            end,
          },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "l",
            desc = "Restore Session",
            action = function()
              require("persistence").load({ last = true })
            end,
          },
          {
            icon = "󰑓 ",
            key = "s",
            desc = "Select Session",
            action = function()
              require("persistence").select()
            end,
          },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    }
  end,
}
