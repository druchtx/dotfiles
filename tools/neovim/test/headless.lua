local failures = {}

local function fail(name, err)
  failures[#failures + 1] = string.format("%s: %s", name, err)
end

local function test(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if ok then
    print("ok - " .. name)
  else
    print("not ok - " .. name)
    fail(name, err)
  end
end

local function assert_true(value, message)
  if not value then
    error(message or "expected truthy value", 2)
  end
end

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message or "values differ", vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local function contains(list, expected)
  for _, value in ipairs(list) do
    if value == expected then
      return true
    end
  end
  return false
end

local function realpath(path)
  return (vim.uv.fs_realpath(path) or vim.fn.fnamemodify(path, ":p")):gsub("/$", "")
end

local function system(args)
  local output = vim.fn.system(args)
  if vim.v.shell_error ~= 0 then
    error(table.concat(args, " ") .. " failed: " .. output, 2)
  end
  return output
end

local very_lazy_done = false
local function trigger_very_lazy()
  if very_lazy_done then
    return
  end
  very_lazy_done = true
  vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
end

test("custom lua files compile", function()
  local config = vim.fn.getcwd() .. "/tools/neovim/config"
  local files = vim.fn.systemlist({ "find", config .. "/lua", "-type", "f", "-name", "*.lua" })
  assert_true(#files > 0, "no lua files found")

  for _, file in ipairs(files) do
    system({ "luac", "-p", file })
  end
end)

test("startup options are applied", function()
  assert_eq(vim.o.wrap, true, "wrap")
  assert_eq(vim.o.linebreak, true, "linebreak")
  assert_eq(vim.o.breakindent, true, "breakindent")
  assert_true(vim.o.showbreak:find("\226\134\170", 1, true) ~= nil, "showbreak marker missing")

  local diffopt = vim.opt.diffopt:get()
  assert_true(contains(diffopt, "algorithm:histogram"), "diffopt missing algorithm:histogram")
  assert_true(contains(diffopt, "linematch:60"), "diffopt missing linematch:60")
end)

test("custom modules load", function()
  for _, module in ipairs({
    "config.git",
    "config.tabs",
    "plugins.modules.bufferline",
    "plugins.modules.diffview",
    "plugins.modules.projects",
    "plugins.modules.sessions",
    "shared.snacks_picker",
  }) do
    assert_true(pcall(require, module), "module failed to load: " .. module)
  end
end)

test("git helpers handle repositories and non-repositories", function()
  local git = require("config.git")
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, "p")

  system({ "git", "-C", tmp, "init", "-q" })
  system({ "git", "-C", tmp, "checkout", "-q", "-b", "main" })
  vim.fn.writefile({ "hello" }, tmp .. "/README.md")
  system({ "git", "-C", tmp, "add", "README.md" })
  system({ "git", "-C", tmp, "-c", "user.name=Neovim Test", "-c", "user.email=test@example.com", "commit", "-q", "-m", "init" })
  system({ "git", "-C", tmp, "remote", "add", "origin", "git@example.com:owner/repo.git" })

  assert_eq(git.root(tmp), realpath(tmp), "git root")
  assert_eq(git.current_branch(tmp), "main", "current branch")

  local refs = git.branch_refs(tmp)
  assert_true(contains(refs, "main"), "local main ref missing")
  assert_true(contains(refs, "origin/main") == false, "unfetched remote ref should not be invented")
  assert_eq(git.root(tmp .. "/missing"), nil, "missing path should not resolve a git root")

  vim.fn.delete(tmp, "rf")
end)

test("tab workspace tracks project directories", function()
  local tabs = require("config.tabs")
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, "p")
  local tmp_real = realpath(tmp)

  local original_tab = vim.api.nvim_get_current_tabpage()
  local original_count = #vim.api.nvim_list_tabpages()

  local ok, err = pcall(function()
    tabs.open_project_tab(tmp)
    assert_eq(#vim.api.nvim_list_tabpages(), original_count + 1, "tab count")
    assert_eq(realpath(tabs.project()), tmp_real, "tab project")
    assert_eq(realpath(vim.fn.getcwd(0)), tmp_real, "tab cwd")
  end)

  if vim.api.nvim_get_current_tabpage() ~= original_tab then
    vim.cmd.tabclose()
    vim.api.nvim_set_current_tabpage(original_tab)
  end
  vim.fn.delete(tmp, "rf")

  if not ok then
    error(err, 0)
  end
end)

test("project picker scans direct child projects", function()
  local projects = require("plugins.modules.projects")
  local parent = vim.fn.tempname()
  local child_a = parent .. "/alpha"
  local child_b = parent .. "/beta"
  vim.fn.mkdir(child_a, "p")
  vim.fn.mkdir(child_b, "p")
  vim.fn.writefile({ "noise" }, parent .. "/.DS_Store")

  projects.scan_roots = { parent }
  local snapshot = projects.scan()

  assert_eq(#snapshot.roots, 1, "scan roots count")
  assert_eq(snapshot.roots[1], vim.fn.fnamemodify(parent, ":p"):gsub("/$", ""), "normalized scan root")
  assert_true(contains(snapshot.projects, vim.fn.fnamemodify(child_a, ":p"):gsub("/$", "")), "alpha missing")
  assert_true(contains(snapshot.projects, vim.fn.fnamemodify(child_b, ":p"):gsub("/$", "")), "beta missing")

  vim.fn.delete(parent, "rf")
end)

test("markdown autocmd disables spell", function()
  trigger_very_lazy()

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  vim.cmd("setlocal spell")
  vim.cmd("setfiletype markdown")
  assert_eq(vim.wo.spell, false, "markdown spell")
  vim.api.nvim_buf_delete(buf, { force = true })
end)

test("plugin commands and keymaps are registered", function()
  trigger_very_lazy()
  require("lazy").load({ plugins = { "diffview.nvim" }, wait = true })

  local commands = vim.api.nvim_get_commands({})
  assert_true(commands.DiffviewOpen ~= nil, "DiffviewOpen command missing")
  assert_true(commands.DiffviewOpenProject ~= nil, "DiffviewOpenProject command missing")
  assert_true(commands.DiffviewCompare ~= nil, "DiffviewCompare command missing")
  assert_true(commands.SnacksProjectsRefresh ~= nil, "SnacksProjectsRefresh command missing")

  assert_eq(vim.fn.maparg("<leader>gd", "n", false, true).desc, "Git: Diffview", "diffview keymap")
  assert_eq(vim.fn.maparg("<leader>gD", "n", false, true).desc, "Git: Compare branches", "diffview compare keymap")
  assert_eq(vim.fn.maparg("<leader>fm", "n", false, true).desc, "Set filetype", "filetype picker keymap")
end)

if #failures > 0 then
  print("")
  print("Failures:")
  for _, failure in ipairs(failures) do
    print(failure)
  end
  vim.cmd.cquit(1)
end

print("")
print("All Neovim dotfiles headless tests passed.")
