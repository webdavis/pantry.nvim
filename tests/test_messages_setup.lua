local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local m = Helpers.messaging(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local target = function()
  return child.lua_get([[require("vim._core.ui2").cfg.msg.target]])
end

local mapped = function(lhs)
  return child.fn.maparg(lhs, "n") ~= ""
end

T["ui2 sends messages to the message window by default"] = function()
  m.setup()
  eq(target(), "msg")
end

T["a ui2 table is passed to ui2 as its options"] = function()
  m.setup({ ui2 = { msg = { target = "cmd" } } })
  eq(target(), "cmd")
end

T["ui2 = false leaves ui2 off, so the history has only the lines of :messages"] = function()
  m.with_ui()
  m.setup({ ui2 = false, view = "buffer" })
  child.cmd("echomsg 'plain'")
  eq(m.history(), { "--:--:-- info plain" })
end

T["a Neovim without ui2 still maps the key and shows the lines of :messages"] = function()
  child.lua([[package.preload["vim._core.ui2"] = function() error("moved") end]])
  m.setup({ view = "buffer" })
  child.cmd("echomsg 'plain'")
  eq(m.history(), { "--:--:-- info plain" })
end

T["calling setup twice records each message once"] = function()
  m.with_ui()
  m.setup({ view = "buffer" })
  m.setup({ view = "buffer" })
  child.cmd("echomsg 'once'")
  eq(#m.history(), 1)
end

T["a key set to false stays unmapped"] = function()
  m.setup({ keys = { ["<leader>nh"] = false } })
  eq(mapped("<leader>nh"), false)
end

T["a misspelt action fails setup with the key and the valid actions"] = function()
  local ok, err = pcall(m.setup, { keys = { ["<leader>x"] = "histroy" } })
  eq(ok, false)
  eq(err:find("histroy", 1, true) ~= nil, true)
  eq(err:find("history_buffer", 1, true) ~= nil, true)
end

T["checkhealth pantry says messages is on"] = function()
  m.setup()
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("messages is on", 1, true) ~= nil, true)
end

return T
