-- Install language parsers and enable syntax-aware highlighting.
-- Managed languages: add parser names after checking `:TSStatus`.
-- Use `:set filetype?` and `:TSStatus`, then add the matching language here.
-- Languages whose parser name differs from their filetype need a separate mapping.
local languages = {
  "go",
}

return {
  "neovim-treesitter/nvim-treesitter",
  dependencies = {
    "neovim-treesitter/treesitter-parser-registry",
  },
  event = { "BufReadPre", "BufNewFile" },
  build = function()
    -- Keep managed parsers compatible after plugin updates.
    require("nvim-treesitter").update(languages):wait(300000)
  end,
  config = function()
    local group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true })

    -- Start highlighting when a parser is available.
    local function start(buf)
      if vim.tbl_contains(languages, vim.bo[buf].filetype) then
        pcall(vim.treesitter.start, buf)
      end
    end

    -- Enable Treesitter for matching buffers.
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = languages,
      callback = function(args)
        start(args.buf)
      end,
    })

    -- Install missing parsers without blocking startup.
    local treesitter = require("nvim-treesitter")
    treesitter.install(languages, { summary = true }):await(function(err, ok)
      vim.schedule(function()
        if err or not ok then
          local detail = err and tostring(err) or "unknown error"
          vim.notify(("Treesitter parser installation failed: %s"):format(detail), vim.log.levels.ERROR)
          return
        end

        -- Retry buffers opened before installation finished.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            start(buf)
          end
        end
      end)
    end)
  end,
}
