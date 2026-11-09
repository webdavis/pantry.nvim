local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local diagnose = function()
  j.open("text", { "a", "b", "c", "d", "e", "f", "g" })
  child.lua([[
    local severity = vim.diagnostic.severity
    local at = function(row, level)
      return { lnum = row - 1, col = 0, message = "m", severity = level }
    end
    vim.diagnostic.set(vim.api.nvim_create_namespace("test"), 0, {
      at(2, severity.ERROR),
      at(3, severity.WARN),
      at(4, severity.ERROR),
      at(5, severity.WARN),
      at(6, severity.ERROR),
    })
  ]])
end

T["]E goes to the next error and skips warnings"] = function()
  diagnose()
  j.at(1)
  eq(j.press("]E"), 2)
  eq(j.press("]E"), 4)
end

T["[E goes to the previous error"] = function()
  diagnose()
  j.at(7)
  eq(j.press("[E"), 6)
end

T["]W goes to the next warning and skips errors"] = function()
  diagnose()
  j.at(1)
  eq(j.press("]W"), 3)
  eq(j.press("]W"), 5)
end

T["[W goes to the previous warning"] = function()
  diagnose()
  j.at(7)
  eq(j.press("[W"), 5)
end

T["a count skips errors"] = function()
  diagnose()
  j.at(1)
  eq(j.press("3]E"), 6)
end

return T
