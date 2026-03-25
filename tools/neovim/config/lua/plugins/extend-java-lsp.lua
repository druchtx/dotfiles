-- define a specific jdk for jdtls
local jdtls_java = "/Users/druchtx/.local/share/mise/installs/java/corretto-21.0.10.7.1/bin/java"

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      if vim.fn.executable(jdtls_java) ~= 1 then
        vim.schedule(function()
          vim.notify("Configured jdtls Java not found: " .. jdtls_java, vim.log.levels.ERROR)
        end)
        return opts
      end

      local cmd = vim.deepcopy(opts.cmd or { vim.fn.exepath("jdtls") })
      table.insert(cmd, "--java-executable=" .. jdtls_java)
      opts.cmd = cmd
      return opts
    end,
  },
}
