local disk = require("pantry.disk")

local M = {}

local timeout = 15000

local describe = function(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return "The file does not exist yet."
  end
  local owner = vim.trim(vim.system({ "id", "-un", tostring(stat.uid) }, { text = true }):wait().stdout or "")
  return ("Owner %s, mode %o."):format(owner ~= "" and owner or stat.uid, bit.band(stat.mode, 4095))
end

local write_copy = function(buf)
  local copy = vim.fn.tempname()
  vim.b[buf].pantry_save = "sudo"
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
    vim.cmd("keepalt silent write! " .. vim.fn.fnameescape(copy))
  end)
  vim.b[buf].pantry_save = nil
  return ok and copy or nil, err
end

local reload = function(buf)
  vim.api.nvim_buf_call(buf, function()
    local view = vim.fn.winsaveview()
    vim.cmd("silent edit!")
    vim.fn.winrestview(view)
  end)
end

M.save = function(buf, note, warn)
  local path = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or path == "" then
    return warn("sudo() saves only a buffer that has a file")
  end
  local name = vim.fs.basename(path)
  if disk.state(buf) == "changed" then
    return warn(("did not save %s with sudo, because it changed on disk"):format(name))
  end
  -- The path sudo writes is the one shown, so a link cannot send the write somewhere unseen.
  local target = vim.uv.fs_realpath(path) or path
  local question = ("Save %s with sudo? %s\nPassword, or nothing to cancel: "):format(target, describe(target))
  local password = vim.fn.inputsecret(question)
  if password == "" then
    return
  end
  local copy, err = write_copy(buf)
  if not copy then
    return warn(("could not prepare %s for sudo: %s"):format(name, err))
  end
  local result = vim
    .system({ "sudo", "-S", "-p", "", "cp", copy, target }, { stdin = password .. "\n", text = true, timeout = timeout })
    :wait()
  vim.fn.delete(copy)
  if result.code ~= 0 then
    return warn(("sudo did not save %s: %s"):format(name, vim.trim(result.stderr or "")))
  end
  reload(buf)
  note(("saved %s with sudo"):format(name))
end

return M
