local folder = require("pantry.jumps.folder")

local M = {}

local files_in = function(dir)
  local names = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" or (kind == "link" and vim.fn.isdirectory(vim.fs.joinpath(dir, name)) == 0) then
      table.insert(names, name)
    end
  end
  return names
end

local ignored_by_git = function(dir, names)
  local result = vim
    .system({ "git", "-C", dir, "check-ignore", "--stdin" }, { stdin = table.concat(names, "\n") })
    :wait()
  local ignored = {}
  if result.code == 0 then
    for line in vim.gsplit(result.stdout, "\n", { trimempty = true }) do
      ignored[line] = true
    end
  end
  return ignored
end

local echo = function(text)
  vim.api.nvim_echo({ { text } }, false, {})
end

M.move = function(direction, count)
  local path = vim.api.nvim_buf_get_name(0)
  local dir = path ~= "" and vim.fs.dirname(path) or vim.fn.getcwd()
  local current = path ~= "" and vim.fs.basename(path) or ""
  local found = files_in(dir)
  local names = folder.listed(found, current, ignored_by_git(dir, found))
  if #names == 0 then
    return echo("No files in " .. vim.fn.fnamemodify(dir, ":~"))
  end
  local target = folder.target(names, current, direction * count)
  if names[target] == current then
    local edge = direction > 0 and "last" or "first"
    return echo(("%d/%d %s (%s file)"):format(target, #names, current, edge))
  end
  vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(dir, names[target])))
  echo(("%d/%d %s"):format(target, #names, names[target]))
end

return M
