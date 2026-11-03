local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local conflict = { "a", "<<<<<<< HEAD", "b", ">>>>>>> branch" }

T["pantry.setup turns jumps on"] = function()
  child.lua([[require("pantry").setup({ jumps = {} })]])
  j.open("text", conflict)
  j.at(1)
  eq(j.press("]n"), 2)
end

T["a key set to false keeps Neovim's meaning"] = function()
  child.lua([[require("pantry.jumps").setup({ keys = { ["]n"] = false } })]])
  j.open("text", conflict)
  j.at(1)
  eq(j.press("]n"), 1)
end

T["a key set to false leaves its partner on"] = function()
  child.lua([[require("pantry.jumps").setup({ keys = { ["]n"] = false } })]])
  j.open("text", conflict)
  j.at(4)
  eq(j.press("[n"), 2)
end

T["checkhealth pantry lists jumps"] = function()
  child.lua([[require("pantry").setup({ jumps = {} })]])
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("jumps is on", 1, true) ~= nil, true)
end

return T
