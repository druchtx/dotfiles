-- Provide a small start screen for opening work quickly.
return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("dashboard_which_key_mappings", { clear = true }),
      pattern = "SnacksDashboardUpdatePre",
      callback = function()
        -- Dashboard registers its own action mappings during every update.
        -- Run afterwards so <leader>e stays disabled without exposing the
        -- plugin's generic "Dashboard action" label in WhichKey.
        vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].filetype == "snacks_dashboard" then
              vim.keymap.set("n", "<leader>e", "<Nop>", {
                buffer = buf,
                desc = "Explorer (cwd)",
              })
            end
          end
        end)
      end,
    })
  end,
  opts = {
    dashboard = {
      enabled = true,
      width = 36,
      sections = {
        {
          gap = 1,
          padding = 1,
          {
            icon = " ",
            key = "n",
            desc = "New File",
            action = function()
              vim.cmd.enew()
            end,
          },
	  -- disable the <leader>e keybinding
          {
            key = "<leader>e",
            hidden = true,
            action = function() end,
          },
          {
            icon = " ",
            key = "e",
            desc = "Explorer",
            action = function()
              vim.cmd("Neotree filesystem float dir=" .. vim.fn.fnameescape(vim.fn.getcwd()))
            end,
          },
          {
            icon = " ",
            key = "p",
            desc = "Projects",
            action = function()
              require("features.projects").pick()
            end,
          },
          {
            icon = " ",
            key = "S",
            desc = "Sessions",
            action = function()
              require("persistence").select()
            end,
          },
          {
            icon = " ",
            key = "l",
            desc = "Restore",
            action = function()
              require("persistence").load({ last = true })
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = function()
              Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
            end,
          },
        },
      },
    },
  },
}
