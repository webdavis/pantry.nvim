local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local m = Helpers.messaging(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local time = "%d%d:%d%d:%d%d"

local matches = function(lines, patterns)
  eq(#lines, #patterns)
  for i, pattern in ipairs(patterns) do
    eq({ i, lines[i]:match("^" .. pattern .. "$") ~= nil }, { i, true })
  end
end

T["the history lists recorded messages newest first with time, level and kind"] = function()
  m.with_ui()
  m.setup({ view = "buffer" })
  child.cmd("echomsg 'first'")
  child.lua([[vim.api.nvim_echo({ { "broken" } }, true, { err = true })]])
  matches(m.history(), { time .. " error echoerr broken", time .. " info echomsg first" })
end

T["a message of several lines continues on indented lines"] = function()
  m.with_ui()
  m.setup({ view = "buffer" })
  child.lua([[vim.api.nvim_echo({ { "one\ntwo" } }, true, {})]])
  local lines = m.history()
  matches(lines, { time .. " info echomsg one", " +two" })
  eq(lines[2]:find("two", 1, true), #lines[1] - 2)
end

T["the history buffer is read-only and q closes it"] = function()
  m.with_ui()
  m.setup({ view = "buffer" })
  child.cmd("echomsg 'first'")
  m.history()
  eq(child.bo.modifiable, false)
  local windows = #child.api.nvim_tabpage_list_wins(0)
  child.type_keys("q")
  eq(#child.api.nvim_tabpage_list_wins(0), windows - 1)
end

T["without recorded messages the history shows the lines of :messages"] = function()
  m.setup({ ui2 = false, view = "buffer" })
  child.cmd("echomsg 'plain'")
  eq(m.history(), { "--:--:-- info plain" })
end

T["a ui2 without a msg_show handler still shows messages and records nothing"] = function()
  m.with_ui()
  child.lua([[package.loaded["vim._core.ui2.messages"] = { msg_show = "not a function" }]])
  m.setup({ ui2 = false, view = "buffer" })
  child.cmd("echomsg 'plain'")
  eq(child.lua_get([[require("vim._core.ui2.messages").msg_show]]), "not a function")
  eq(m.history(), { "--:--:-- info plain" })
end

return T
