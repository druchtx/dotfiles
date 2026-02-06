local function quit_terminal(self, keys)
  local job = vim.b[self.buf].terminal_job_id
  if job then
    vim.api.nvim_chan_send(job, keys)
  end
end

local function open_ops_terminal(cmd, opts)
  opts = opts or {}
  local quit_keys = opts.quit_keys or "q"
  local terminal_cmd = type(cmd) == "table" and cmd or { cmd }
  local win = vim.tbl_deep_extend("force", {
    width = 0,
    height = 0,
    keys = {
      ["<a-h>"] = { "<a-h>", "hide", mode = { "n", "t" }, desc = "Hide" },
      ["<a-q>"] = {
        "<a-q>",
        function(self)
          quit_terminal(self, quit_keys)
        end,
        mode = { "n", "t" },
        desc = "Quit",
      },
    },
  }, opts.win or {})

  Snacks.terminal.focus(terminal_cmd, {
    count = 1,
    cwd = LazyVim.root(),
    win = win,
  })
end

return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>o", group = "ops/tools", icon = { icon = "󰡨 ", color = "blue" } })
      table.insert(opts.spec, { "<leader>od", desc = "lazydocker", icon = { icon = "󰡨 ", color = "blue" } })
      table.insert(opts.spec, { "<leader>ok", desc = "k9s", icon = { icon = "⎈ ", color = "cyan" } })
    end,
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>od",
        function()
          open_ops_terminal("lazydocker")
        end,
        desc = "lazydocker",
        mode = { "n", "t" },
      },
      {
        "<leader>ok",
        function()
          open_ops_terminal("k9s", { quit_keys = ":q\r" })
        end,
        desc = "k9s",
        mode = { "n", "t" },
      },
    },
  },
}
