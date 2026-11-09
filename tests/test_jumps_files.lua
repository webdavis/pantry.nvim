local Helpers = require("tests.helpers")
local Folder = require("tests.folder")
local child, hooks = Helpers.jumps_child()
local f = Folder.browsing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["]f opens the next file and counts digits as numbers"] = function()
  local dir = Folder.make({ "a10.txt", "a2.txt", "a1.txt" })
  f.open(dir, "a1.txt")
  eq(f.press("]f"), "a2.txt")
  eq(f.press("]f"), "a10.txt")
end

T["[f opens the previous file"] = function()
  local dir = Folder.make({ "a10.txt", "a2.txt", "a1.txt" })
  f.open(dir, "a10.txt")
  eq(f.press("[f"), "a2.txt")
end

T["a count skips files"] = function()
  local dir = Folder.make({ "a.txt", "b.txt", "c.txt" })
  f.open(dir, "a.txt")
  eq(f.press("2]f"), "c.txt")
end

T["each jump shows the position and the name"] = function()
  local dir = Folder.make({ "a.txt", "b.txt", "c.txt" })
  f.open(dir, "a.txt")
  f.press("]f")
  eq(f.message(), "2/3 b.txt")
end

T["]f stays on the last file and says so"] = function()
  local dir = Folder.make({ "a.txt", "b.txt" })
  f.open(dir, "b.txt")
  eq(f.press("3]f"), "b.txt")
  eq(f.message(), "2/2 b.txt (last file)")
end

T["[f stays on the first file and says so"] = function()
  local dir = Folder.make({ "a.txt", "b.txt" })
  f.open(dir, "a.txt")
  eq(f.press("[f"), "a.txt")
  eq(f.message(), "1/2 a.txt (first file)")
end

T["a buffer whose file is not on disk sits between its neighbors"] = function()
  local dir = Folder.make({ "b1.txt", "b10.txt" })
  f.open(dir, "b5.txt")
  eq(f.press("]f"), "b10.txt")
  f.open(dir, "b5.txt")
  eq(f.press("[f"), "b1.txt")
end

T["an unnamed buffer in an empty folder says there are no files"] = function()
  local dir = Folder.make({})
  child.o.columns = 200
  child.cmd("cd " .. vim.fn.fnameescape(dir))
  f.press("]f")
  eq(f.message(), "No files in " .. vim.fn.fnamemodify(dir, ":~"))
end

return T
