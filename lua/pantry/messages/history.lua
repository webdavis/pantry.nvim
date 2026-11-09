local M = {}

local entries = {}
local wrapper

local LEVELS = {
  emsg = "error",
  echoerr = "error",
  lua_error = "error",
  rpc_error = "error",
  wmsg = "warn",
}

local add = function(kind, content, history)
  if not history then
    return
  end
  local text = {}
  for _, chunk in ipairs(content) do
    text[#text + 1] = chunk[2]
  end
  entries[#entries + 1] = {
    added = os.time(),
    kind = kind ~= "" and kind or "echo",
    msg = table.concat(text),
    level = LEVELS[kind] or "info",
  }
end

M.record = function()
  local ok, messages = pcall(require, "vim._core.ui2.messages")
  if not ok or type(messages.msg_show) ~= "function" or messages.msg_show == wrapper then
    return
  end
  local msg_show = messages.msg_show
  wrapper = function(kind, content, replace_last, history, ...)
    -- A ui2 that changed the arguments' shape loses a history row, never the message.
    pcall(add, kind, content, history)
    return msg_show(kind, content, replace_last, history, ...)
  end
  messages.msg_show = wrapper
end

local from_messages = function()
  local list = {}
  for _, line in ipairs(vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n")) do
    if line ~= "" then
      list[#list + 1] = { kind = "", msg = line, level = "info" }
    end
  end
  return list
end

M.newest_first = function()
  local list = #entries > 0 and entries or from_messages()
  return vim.iter(list):rev():totable()
end

return M
