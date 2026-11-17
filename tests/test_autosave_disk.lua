local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local rewritten_by_someone_else = function(path)
  child.lua([[
    vim.api.nvim_create_autocmd("FileChangedShell", {
      callback = function()
        vim.v.fcs_choice = ""
      end,
    })
    vim.wait(20)
  ]])
  child.fn.writefile({ "theirs" }, path)
end

local mentions = function(notice, text)
  return notice ~= nil and notice:find(text, 1, true) ~= nil
end

T["a file that changed on disk is not overwritten, and autosave says so once"] = function()
  s.setup()
  local path = s.changed_file()
  rewritten_by_someone_else(path)
  s.leave()
  child.cmd("buffer #")
  s.leave()
  eq(s.on_disk(path), { "theirs" })
  eq(#s.notices(), 1)
  eq(mentions(s.notices()[1], "changed on disk"), true)
end

T["reloading the changed file lets autosave save it again"] = function()
  s.setup()
  local path = s.changed_file()
  rewritten_by_someone_else(path)
  s.leave()
  child.cmd("buffer #")
  child.cmd("edit!")
  s.change({ "mine again" })
  s.leave()
  eq(s.on_disk(path), { "mine again" })
end

T["a file that was deleted underneath is not recreated"] = function()
  s.setup()
  local path = s.changed_file()
  child.fn.delete(path)
  s.leave()
  eq(child.fn.filereadable(path), 0)
  eq(mentions(s.notices()[1], "gone from disk"), true)
end

T["a file you cannot write is skipped, and autosave says so once"] = function()
  s.setup()
  local path = s.file(s.folder(), "locked.txt")
  child.fn.setfperm(path, "r--r--r--")
  s.open(path)
  s.change()
  s.leave()
  child.cmd("buffer #")
  s.leave()
  eq(s.on_disk(path), { "on disk" })
  eq(#s.notices(), 1)
  eq(mentions(s.notices()[1], "cannot write"), true)
end

T["saving by hand after a disk change clears the notice for the next one"] = function()
  s.setup()
  local path = s.changed_file()
  rewritten_by_someone_else(path)
  s.leave()
  child.cmd("buffer #")
  child.cmd("silent write!")
  s.change({ "mine again" })
  rewritten_by_someone_else(path)
  s.leave()
  eq(#s.notices(), 2)
end

return T
