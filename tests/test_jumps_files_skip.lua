local Helpers = require("tests.helpers")
local Folder = require("tests.folder")
local child, hooks = Helpers.jumps_child()
local f = Folder.browsing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["images, lock files and .DS_Store are skipped"] = function()
  local dir = Folder.make({ "a.txt", "b.PNG", "c.lock", ".DS_Store", "package-lock.json", "d.txt" })
  f.open(dir, "a.txt")
  eq(f.press("]f"), "d.txt")
end

T["a skipped file that is open still has neighbors"] = function()
  local dir = Folder.make({ "a.txt", "b.png", "c.txt" })
  f.open(dir, "b.png")
  eq(f.press("]f"), "c.txt")
end

T["folders are skipped and links to files are kept"] = function()
  local dir = Folder.make({ "a.txt", "d.txt" })
  vim.fn.mkdir(dir .. "/b", "p")
  vim.uv.fs_symlink(dir .. "/d.txt", dir .. "/c.txt")
  f.open(dir, "a.txt")
  eq(f.press("]f"), "c.txt")
end

T["files that git ignores are skipped"] = function()
  local dir = Folder.make({ "a.txt", "b.txt", "c.txt" })
  vim.system({ "git", "init", "-q", dir }):wait()
  vim.fn.writefile({ "b.txt" }, dir .. "/.gitignore")
  f.open(dir, "a.txt")
  eq(f.press("]f"), "c.txt")
end

return T
