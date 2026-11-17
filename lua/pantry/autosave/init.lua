local disk = require("pantry.disk")
local rules = require("pantry.autosave.rules")
local writer = require("pantry.autosave.writer")

local M = {}

local config = { mode = "on", delay = 1000, skip = {}, paths = { on = {}, off = {} } }
local mode = "off"
local group = "pantry.autosave"
local pending = {}

local decision = function(buf)
  if mode == "off" then
    return { saves = false, reason = "autosave is off" }
  elseif mode == "on" then
    return { saves = true, reason = "autosave is on" }
  end
  return rules.decide(buf, config)
end

local drop_pending = function(buf)
  local timer = pending[buf]
  if timer then
    pending[buf] = nil
    timer:stop()
    timer:close()
  end
end

local save = function(buf, kind)
  drop_pending(buf)
  if vim.api.nvim_buf_is_valid(buf) and decision(buf).saves then
    writer.save(buf, kind, config)
  end
end

local in_a_macro = function()
  return vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= ""
end

local save_after_a_pause = function(buf)
  drop_pending(buf)
  if in_a_macro() or not decision(buf).saves then
    return
  end
  local timer = assert(vim.uv.new_timer())
  pending[buf] = timer
  timer:start(
    config.delay,
    0,
    vim.schedule_wrap(function()
      if pending[buf] == timer and not in_a_macro() then
        save(buf, "pause")
      else
        drop_pending(buf)
      end
    end)
  )
end

local watch = function()
  local id = vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd({ "BufLeave", "QuitPre", "VimSuspend" }, {
    group = id,
    nested = true,
    callback = function()
      save(vim.api.nvim_get_current_buf(), "leave")
    end,
  })
  vim.api.nvim_create_autocmd("FocusLost", {
    group = id,
    nested = true,
    callback = function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        save(buf, "leave")
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = id,
    callback = function(event)
      save_after_a_pause(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "InsertEnter", "BufWipeout" }, {
    group = id,
    callback = function(event)
      drop_pending(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = id,
    callback = function(event)
      writer.forget_problems(event.buf)
    end,
  })
end

M.is_enabled = function()
  return mode ~= "off"
end

M.enable = function()
  if mode ~= "off" then
    return
  end
  mode = config.mode == "off" and "on" or config.mode
  watch()
end

M.disable = function()
  mode = "off"
  vim.api.nvim_create_augroup(group, {})
  for buf in pairs(pending) do
    drop_pending(buf)
  end
end

M.toggle = function()
  if mode == "off" then
    M.enable()
  else
    M.disable()
  end
end

M.status = function(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local decided = decision(buf)
  return { mode = mode, saves = decided.saves, reason = decided.reason, pending = pending[buf] ~= nil }
end

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  disk.watch()
  if config.mode ~= "off" then
    M.enable()
  end
end

return M
