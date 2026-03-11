local gitlab_env = vim.fn.expand("~/.dotfiles/tools/gitlab/env.zsh")

local function git_root()
  return require("lazyvim.util").root.git()
end

local function systemlist(cmd)
  local output = vim.fn.systemlist(cmd)
  return vim.v.shell_error == 0 and output or nil
end

local function trim(value)
  return value and vim.trim(value) or nil
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Git Hosting" })
end

local function open_url(url)
  if not url or url == "" then
    notify("No URL available for selection", vim.log.levels.WARN)
    return
  end
  vim.ui.open(url)
end

local function configured_gitlab_host()
  if vim.env.GITLAB_HOST and vim.env.GITLAB_HOST ~= "" then
    return vim.env.GITLAB_HOST
  end
  if vim.fn.filereadable(gitlab_env) ~= 1 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(gitlab_env)) do
    local host = line:match('^%s*export%s+GITLAB_HOST="([^"]+)"')
      or line:match("^%s*export%s+GITLAB_HOST='([^']+)'")
      or line:match("^%s*export%s+GITLAB_HOST=([^%s]+)")
    if host and host ~= "" then
      return host
    end
  end
end

local function fetch_remote_names()
  local lines = systemlist({ "git", "-C", git_root(), "remote", "-v" }) or {}
  local ret, seen = {}, {}
  for _, line in ipairs(lines) do
    local name = line:match("^(%S+)%s+%S+%s+%(fetch%)$")
    if name and not seen[name] then
      seen[name] = true
      table.insert(ret, name)
    end
  end
  return ret
end

local function preferred_remote_name()
  local upstream = systemlist({ "git", "-C", git_root(), "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  local name = upstream and trim(upstream[1]) and trim(upstream[1]):match("^([^/]+)/")
  if name and name ~= "" then
    return name
  end
  local remotes = fetch_remote_names()
  if vim.tbl_contains(remotes, "origin") then
    return "origin"
  end
  return remotes[1]
end

local function is_gitlab_repo()
  local name = preferred_remote_name()
  if not name then
    return false
  end

  local output = systemlist({ "git", "-C", git_root(), "remote", "get-url", name })
  local remote = output and trim(output[1]) or nil
  if not remote then
    return false
  end

  local host = require("snacks.gitbrowse").get_repo(remote):match("^https?://([^/]+)")
  local gitlab_host = configured_gitlab_host()
  if gitlab_host and host == gitlab_host then
    return true
  end
  return host and host:find("gitlab", 1, true) ~= nil or false
end

local function run_glab_json(args)
  if vim.fn.executable("glab") ~= 1 then
    return nil, "glab is not installed"
  end
  if vim.fn.filereadable(gitlab_env) ~= 1 then
    return nil, "gitlab env file is missing: " .. gitlab_env
  end

  local escaped = {}
  for _, arg in ipairs(args) do
    table.insert(escaped, vim.fn.shellescape(arg))
  end

  local result = vim.system({
    "zsh",
    "-lc",
    "source " .. vim.fn.shellescape(gitlab_env) .. " >/dev/null 2>&1 && " .. table.concat(escaped, " "),
  }, {
    cwd = git_root(),
    text = true,
  }):wait()

  if result.code ~= 0 then
    local err = vim.trim(result.stderr or "")
    return nil, err ~= "" and err or "glab command failed"
  end

  local ok, decoded = pcall(vim.json.decode, result.stdout)
  return ok and decoded or nil, ok and nil or "failed to decode glab JSON output"
end

local function select_item(items, opts)
  if #items == 0 then
    notify(opts.empty, vim.log.levels.INFO)
    return
  end
  vim.ui.select(items, {
    prompt = opts.prompt,
    format_item = opts.format_item,
  }, function(choice)
    if choice then
      open_url(choice.web_url)
    end
  end)
end

local function gitlab_issues(opts)
  local args = { "glab", "issue", "list", "-O", "json", "-P", "100" }
  if opts and opts.state == "all" then
    table.insert(args, "--all")
  end
  local items, err = run_glab_json(args)
  if not items then
    notify(err, vim.log.levels.ERROR)
    return
  end
  select_item(items, {
    prompt = opts and opts.state == "all" and "GitLab Issues (all):" or "GitLab Issues (open):",
    empty = "No GitLab issues found",
    format_item = function(item)
      local ref = item.references and item.references.short or ("#" .. item.iid)
      return string.format("%-10s %-8s %s", ref, item.state or "unknown", item.title or "(no title)")
    end,
  })
end

local function gitlab_mrs(opts)
  local args = { "glab", "mr", "list", "-F", "json", "-P", "100" }
  if opts and opts.state == "all" then
    table.insert(args, "--all")
  end
  local items, err = run_glab_json(args)
  if not items then
    notify(err, vim.log.levels.ERROR)
    return
  end
  select_item(items, {
    prompt = opts and opts.state == "all" and "GitLab Merge Requests (all):" or "GitLab Merge Requests (open):",
    empty = "No GitLab merge requests found",
    format_item = function(item)
      local ref = item.references and item.references.short or ("!" .. item.iid)
      return string.format("%-10s %-8s %s", ref, item.state or "unknown", item.title or "(no title)")
    end,
  })
end

local function issues(opts)
  if is_gitlab_repo() then
    return gitlab_issues(opts)
  end
  return Snacks.picker.gh_issue(opts)
end

local function pull_requests(opts)
  if is_gitlab_repo() then
    return gitlab_mrs(opts)
  end
  return Snacks.picker.gh_pr(opts)
end

return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>gi",
      function()
        issues()
      end,
      desc = "Hosting Issues (open)",
    },
    {
      "<leader>gI",
      function()
        issues({ state = "all" })
      end,
      desc = "Hosting Issues (all)",
    },
    {
      "<leader>gp",
      function()
        pull_requests()
      end,
      desc = "Hosting Pull Requests (open)",
    },
    {
      "<leader>gP",
      function()
        pull_requests({ state = "all" })
      end,
      desc = "Hosting Pull Requests (all)",
    },
  },
}
