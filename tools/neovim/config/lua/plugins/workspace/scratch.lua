local scratch = require("utils.scratch_workspace")

-- Configure scratch buffers and the additional scratch workspace sources.
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts = scratch.configure_picker(opts)
    opts.scratch = opts.scratch or {}
    opts.scratch.ft = "markdown"
    opts.scratch.win = vim.tbl_deep_extend("force", opts.scratch.win or {}, {
      wo = { wrap = true, linebreak = true, breakindent = true, conceallevel = 2, concealcursor = "n" },
    })
  end,
}
