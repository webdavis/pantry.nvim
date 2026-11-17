local M = {}

local operations = {
  { "rebase-merge", "rebase" },
  { "rebase-apply", "rebase" },
  { "MERGE_HEAD", "merge" },
  { "CHERRY_PICK_HEAD", "cherry-pick" },
  { "REVERT_HEAD", "revert" },
  { "BISECT_LOG", "bisect" },
}

-- A linked worktree has a .git file that names its real git folder.
local git_folder = function(path)
  local dotgit = vim.fs.find(".git", { path = vim.fs.dirname(path), upward = true })[1]
  if not dotgit or vim.fn.isdirectory(dotgit) == 1 then
    return dotgit
  end
  local named = (vim.fn.readfile(dotgit, "", 1)[1] or ""):match("^gitdir: (.+)$")
  if named and not vim.startswith(named, "/") then
    named = vim.fs.joinpath(vim.fs.dirname(dotgit), named)
  end
  return named
end

local git_operation = function(path)
  local folder = git_folder(path)
  if not folder then
    return
  end
  for _, operation in ipairs(operations) do
    if vim.uv.fs_stat(vim.fs.joinpath(folder, operation[1])) then
      return operation[2]
    end
  end
end

local has_conflict_markers = function(buf)
  return vim.api.nvim_buf_call(buf, function()
    return vim.fn.search("^<<<<<<< ", "nw") > 0
  end)
end

local under_any = function(path, patterns)
  for _, pattern in ipairs(patterns or {}) do
    if vim.glob.to_lpeg(vim.fs.normalize(pattern)):match(path) then
      return true
    end
  end
  return false
end

local hold = function(reason)
  return { saves = false, reason = reason }
end

M.decide = function(buf, config)
  local chosen = config.when and config.when(buf)
  if chosen ~= nil then
    return { saves = chosen == true, reason = "when decided" }
  end
  local path = vim.api.nvim_buf_get_name(buf)
  local operation = git_operation(path)
  if operation then
    return hold(("a git %s is in progress"):format(operation))
  elseif has_conflict_markers(buf) then
    return hold("the buffer has conflict markers")
  elseif under_any(path, config.paths.off) then
    return hold("the file is under paths.off")
  elseif #(config.paths.on or {}) > 0 and not under_any(path, config.paths.on) then
    return hold("the file is outside paths.on")
  end
  return { saves = true, reason = "no rule holds it" }
end

return M
