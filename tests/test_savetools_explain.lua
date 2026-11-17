local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child, "savetools")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local explain = function()
  return child.lua_get([[require("pantry.savetools").explain()]])
end

T["explain() says a plain save does nothing extra"] = function()
  s.setup()
  s.changed_file()
  eq(explain(), { "Saving note.txt writes the file and does nothing else." })
end

T["explain() lists what a save of a new script would do, without saving"] = function()
  s.setup()
  local root = s.folder()
  local path = root .. "/bin/deploy"
  s.open(path)
  s.change({ "#!/bin/sh" })
  eq(explain(), {
    ("It would make the folder %s."):format(root .. "/bin"),
    "It would make deploy executable, because bin is in executable.always.",
  })
  eq(child.fn.isdirectory(root .. "/bin"), 0)
end

T["explain() says when a save would bring a deleted file back"] = function()
  s.setup()
  local path = s.changed_file()
  child.fn.delete(path)
  eq(explain(), { "note.txt is gone from disk, so a save would bring it back." })
end

T["explain() says when the file changed on disk"] = function()
  s.setup()
  local path = s.changed_file()
  child.lua("vim.wait(20)")
  child.fn.writefile({ "theirs" }, path)
  eq(explain(), { "note.txt changed on disk, so Neovim will ask before it overwrites that change." })
end

T["explain() points to sudo() for a file you cannot write"] = function()
  s.setup()
  local path = s.file(s.folder(), "locked.txt")
  child.fn.setfperm(path, "r--r--r--")
  s.open(path)
  eq(explain(), { "You cannot write locked.txt. sudo() can save it." })
end

T["checkhealth pantry lists savetools"] = function()
  s.setup()
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("savetools is on", 1, true) ~= nil, true)
end

return T
