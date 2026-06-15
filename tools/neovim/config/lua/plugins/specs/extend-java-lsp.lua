local jdtls_runtime = "corretto-21"

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local java_home = vim.trim(vim.fn.system({ "mise", "where", "java@" .. jdtls_runtime }))
      local jdtls_java = (vim.v.shell_error == 0 and java_home ~= "" and java_home .. "/bin/java")
        or (vim.env.JAVA_HOME and vim.env.JAVA_HOME .. "/bin/java")
        or "java"

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
