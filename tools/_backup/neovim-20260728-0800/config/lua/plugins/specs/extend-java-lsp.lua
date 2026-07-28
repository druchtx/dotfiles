local jdtls_runtime = "corretto-21.0.10.7.1"
local jdtls_java_home = vim.fn.expand("~/.local/share/mise/installs/java/" .. jdtls_runtime)
local jdtls_java_path = jdtls_java_home .. "/bin/java"

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      if vim.fn.isdirectory(jdtls_java_home) ~= 1 then
        vim.schedule(function()
          vim.notify("Configured jdtls Java version not installed: " .. jdtls_runtime, vim.log.levels.ERROR)
        end)
        return opts
      end

      if vim.fn.executable(jdtls_java_path) ~= 1 then
        vim.schedule(function()
          vim.notify("Configured jdtls Java not found: " .. jdtls_java_path, vim.log.levels.ERROR)
        end)
        return opts
      end

      local cmd = vim.deepcopy(opts.cmd or { vim.fn.exepath("jdtls") })
      table.insert(cmd, "--java-executable=" .. jdtls_java_path)
      opts.cmd = cmd
      return opts
    end,
  },
}
