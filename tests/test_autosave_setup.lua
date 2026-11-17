local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local health = function()
  child.cmd("checkhealth pantry")
  return table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

T["status says autosave is on and nothing is pending"] = function()
  s.setup()
  s.open(s.file(s.folder(), "note.txt"))
  eq(s.status(), { mode = "on", saves = true, reason = "autosave is on", pending = false })
end

T["status says a pause save is pending until it runs"] = function()
  s.setup({ delay = 20 })
  s.changed_file()
  s.edit()
  eq(s.status().pending, true)
  s.wait()
  eq(s.status().pending, false)
end

T["status says autosave is off"] = function()
  s.setup({ mode = "off" })
  eq(s.status(), { mode = "off", saves = false, reason = "autosave is off", pending = false })
end

T["toggle goes between off and the mode from setup"] = function()
  s.setup({ mode = "auto" })
  s.call("toggle")
  eq(s.status().mode, "off")
  s.call("toggle")
  eq(s.status().mode, "auto")
end

T["toggle turns a jar set up with mode = 'off' on"] = function()
  s.setup({ mode = "off" })
  s.call("toggle")
  eq(s.status().mode, "on")
end

T["checkhealth pantry says whether autosave is on"] = function()
  s.setup({ mode = "off" })
  eq(health():find("autosave is set up and off", 1, true) ~= nil, true)
  s.call("enable")
  eq(health():find("autosave is on", 1, true) ~= nil, true)
end

return T
