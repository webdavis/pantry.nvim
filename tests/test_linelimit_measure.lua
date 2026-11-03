local measure = require("pantry.linelimit.measure")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set()

T["a short line gets nothing"] = function()
  eq(measure("short", 20, 10, 8), nil)
end

T["a line within near columns of the limit gets a mark after the limit"] = function()
  eq(measure(("a"):rep(10), 20, 10, 8), { mark = 20 })
  eq(measure(("a"):rep(20), 20, 10, 8), { mark = 20 })
end

T["a line one column before the near range gets nothing"] = function()
  eq(measure(("a"):rep(9), 20, 10, 8), nil)
end

T["a line past the limit gets the count of columns over"] = function()
  eq(measure(("a"):rep(25), 20, 10, 8), { over = 5 })
end

T["a tab counts up to the next tabstop"] = function()
  eq(measure("\t" .. ("a"):rep(15), 20, 10, 8), { over = 3 })
  eq(measure("ab\tc", 20, 15, 4), { mark = 20 })
end

T["a wide character counts as two columns"] = function()
  eq(measure(("界"):rep(11), 20, 10, 8), { over = 2 })
end

return T
