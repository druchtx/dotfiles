local M = {}

-- Shared synchronous Git helpers for UI commands. These commands are only used
-- from explicit user actions, so blocking briefly is acceptable and keeps the
-- call sites deterministic.
local function normalize_path(path)
  return path and vim.fn.fnamemodify(path, ":p"):gsub("/$", "") or nil
end

function M.systemlist(args)
  local output = vim.fn.systemlist(args)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return output
end

function M.root(path)
  path = normalize_path(path or vim.fn.getcwd(0))
  if not path then
    return nil
  end

  local output = M.systemlist({ "git", "-C", path, "rev-parse", "--show-toplevel" })
  if not output or not output[1] or output[1] == "" then
    return nil
  end

  return normalize_path(vim.trim(output[1]))
end

function M.current_project_root()
  return M.root(vim.fn.getcwd(0))
end

function M.current_branch(cwd)
  local root = M.root(cwd) or cwd
  local output = root and M.systemlist({ "git", "-C", root, "branch", "--show-current" }) or nil
  if not output or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

function M.upstream_ref(cwd)
  local root = M.root(cwd) or cwd
  local output = nil
  if root then
    output = M.systemlist({ "git", "-C", root, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  end
  if not output or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

function M.branch_refs(cwd)
  local root = M.root(cwd) or cwd
  local refs = nil
  if root then
    refs = M.systemlist({
      "git",
      "-C",
      root,
      "for-each-ref",
      "--format=%(refname:short)",
      "refs/heads",
      "refs/remotes",
    })
  end
  if not refs then
    return {}
  end

  local result = {}
  local seen = {}
  table.sort(refs)
  for _, ref in ipairs(refs) do
    ref = vim.trim(ref)
    if ref ~= "" and ref ~= "HEAD" and not ref:match("/HEAD$") and not seen[ref] then
      seen[ref] = true
      result[#result + 1] = ref
    end
  end

  return result
end

function M.prioritize_refs(refs, priorities)
  local seen = {}
  local result = {}

  for _, ref in ipairs(refs) do
    seen[ref] = true
  end

  for _, ref in ipairs(priorities) do
    if ref and seen[ref] then
      result[#result + 1] = ref
      seen[ref] = nil
    end
  end

  for _, ref in ipairs(refs) do
    if seen[ref] then
      result[#result + 1] = ref
      seen[ref] = nil
    end
  end

  return result
end

return M
