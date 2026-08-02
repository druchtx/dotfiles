-- Tool integrations: API requests, Docker, and Kubernetes operations.
local function quit_terminal(self, keys)
  local job = vim.b[self.buf].terminal_job_id
  if job then
    vim.api.nvim_chan_send(job, keys)
  end
end

local function open_ops_terminal(cmd, opts)
  opts = opts or {}
  local terminal_cmd = type(cmd) == "table" and cmd or { cmd }
  local win = vim.tbl_deep_extend("force", {
    width = 0,
    height = 0,
    keys = {
      ["<a-h>"] = { "<a-h>", "hide", mode = { "n", "t" }, desc = "Hide" },
      ["<a-q>"] = {
        "<a-q>",
        function(self)
          quit_terminal(self, opts.quit_keys or "q")
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
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      {
        "<leader>or",
        function()
          require("kulala").run()
        end,
        desc = "rest client",
        mode = { "n", "v" },
        ft = { "http", "rest" },
      },
    },
    opts = {
      lsp = {
        enable = true,
        filetypes = { "http", "rest" },
        keymaps = false,
      },
      kulala_keymaps = {
        ["Previous tab"] = {
          "gh",
          function()
            require("kulala.ui").show_previous_tab()
          end,
          mode = { "n" },
        },
        ["Next tab"] = {
          "gl",
          function()
            require("kulala.ui").show_next_tab()
          end,
          mode = { "n" },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>o", group = "Tools", icon = { icon = " ", color = "blue" } })
      table.insert(opts.spec, { "<leader>od", desc = "Lazydocker", icon = { icon = "󰡨 ", color = "blue" } })
      table.insert(opts.spec, { "<leader>ok", desc = "K9s", icon = { icon = "⎈ ", color = "cyan" } })
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
        desc = "Lazydocker",
        mode = { "n", "t" },
      },
      {
        "<leader>ok",
        function()
          open_ops_terminal("k9s", { quit_keys = ":q\r" })
        end,
        desc = "K9s",
        mode = { "n", "t" },
      },
    },
  },
}
