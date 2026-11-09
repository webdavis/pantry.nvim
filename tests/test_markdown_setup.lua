local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local tasks = { "- [ ] one", "text", "- [x] two" }

T["pantry.setup turns markdown on"] = function()
  child.lua([[require("pantry").setup({ markdown = {} })]])
  j.open("markdown", tasks)
  j.at(1)
  eq(j.press("]x"), 3)
end

T["a key set to false keeps Neovim's meaning"] = function()
  child.lua([[require("pantry.markdown").setup({ keys = { ["]x"] = false } })]])
  j.open("markdown", tasks)
  j.at(1)
  eq(j.press("]x"), 1)
end

T["a key set to false leaves its partner on"] = function()
  child.lua([[require("pantry.markdown").setup({ keys = { ["]x"] = false } })]])
  j.open("markdown", tasks)
  j.at(3)
  eq(j.press("[x"), 1)
end

T["the keys are buffer-local"] = function()
  child.lua([[require("pantry.markdown").setup()]])
  j.open("markdown", tasks)
  eq(child.lua_get([[vim.fn.maparg("]x", "n", false, true).buffer]]), 1)
  child.cmd("enew")
  eq(child.fn.maparg("]x", "n"), "")
end

T["checkhealth pantry lists markdown"] = function()
  child.lua([[require("pantry").setup({ markdown = {} })]])
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("markdown is on", 1, true) ~= nil, true)
end

return T
