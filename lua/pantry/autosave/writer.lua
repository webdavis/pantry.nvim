local disk = require("pantry.disk")

local M = {}

local wants = function(buf, config)
  local bo = vim.bo[buf]
  if not vim.api.nvim_buf_is_loaded(buf) or bo.buftype ~= "" or not bo.modified or not bo.modifiable then
    return false
  end
  if vim.api.nvim_buf_get_name(buf) == "" or vim.b[buf].pantry_autosave == false then
    return false
  end
  if vim.tbl_contains(config.skip, bo.filetype) then
    return false
  end
  return not config.condition or config.condition(buf) ~= false
end

local problem_with = function(buf)
  local state = disk.state(buf)
  if state == "changed" then
    return "it changed on disk"
  elseif state == "gone" then
    return "it is gone from disk"
  elseif not disk.writable(buf) then
    return "you cannot write it"
  end
end

local say_once = function(buf, problem)
  if vim.b[buf].pantry_autosave_problem == problem then
    return
  end
  vim.b[buf].pantry_autosave_problem = problem
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.")
  vim.notify(("autosave: did not save %s, because %s"):format(name, problem), vim.log.levels.WARN)
end

local write_as = function(buf, kind)
  vim.b[buf].pantry_save = kind
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
    vim.cmd("silent lockmarks write")
  end)
  vim.b[buf].pantry_save = nil
  if not ok then
    say_once(buf, tostring(err))
  end
end

M.forget_problems = function(buf)
  vim.b[buf].pantry_autosave_problem = nil
end

---@param kind "leave"|"pause"
M.save = function(buf, kind, config)
  -- Autosave never creates a file, so a new one waits for a save by hand.
  if not wants(buf, config) or disk.state(buf) == "new" then
    return
  end
  local problem = problem_with(buf)
  if problem then
    say_once(buf, problem)
  else
    write_as(buf, kind)
  end
end

return M
