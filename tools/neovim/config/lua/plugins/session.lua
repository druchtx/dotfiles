-- Save editor sessions by project directory and Git branch.
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  dependencies = { "nvim-neo-tree/neo-tree.nvim" },
  keys = {
    {
      "<leader>qs",
      function()
        require("persistence").select()
      end,
      desc = "Select session",
    },
  },
  opts = {},
  config = function(_, opts)
    require("persistence").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("restore_neotree_after_session", { clear = true }),
      pattern = "PersistenceLoadPost",
      callback = function()
        vim.schedule(function()
          local restored_tree = false

          -- Sessions serialize Neo-tree's internal buffer name as an ordinary
          -- file. It can be hidden, so inspect every buffer rather than only
          -- the visible windows.
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
            if vim.bo[buf].filetype ~= "neo-tree" and name:match("^neo%-tree .+ %[%d+%]$") then
              restored_tree = true
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end

          if restored_tree then
            local empty_window
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_get_name(buf) == "" and vim.bo[buf].buftype == "" and not vim.bo[buf].modified then
                empty_window = win
              end
            end

            if empty_window then
              vim.api.nvim_set_current_win(empty_window)
              -- A session may restore a window-local directory for the active
              -- file. Use the saved global project root so Neo-tree does not
              -- reopen inside a nested source directory such as `lua/`.
              vim.cmd("Neotree filesystem show current dir=" .. vim.fn.fnameescape(vim.fn.getcwd(-1, -1)))
            else
              vim.cmd("Neotree filesystem show right dir=" .. vim.fn.fnameescape(vim.fn.getcwd(-1, -1)))
            end
          end
        end)
      end,
    })
  end,
}
