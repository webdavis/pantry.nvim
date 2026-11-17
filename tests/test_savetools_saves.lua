local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child, "savetools")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local files_in = function(folder)
  local names = child.fn.readdir(folder)
  table.sort(names)
  return names
end

local settle = function()
  child.lua("vim.wait(50)")
end

T["saving into a folder that does not exist makes the folder"] = function()
  s.setup()
  local root = s.folder()
  local path = root .. "/new/deeper/note.txt"
  s.open(path)
  s.change()
  child.cmd("silent write")
  eq(s.on_disk(path), { "changed" })
  eq(s.notices(), { ("savetools: made the folder %s"):format(root .. "/new/deeper") })
end

T["folders = false leaves a missing folder to Neovim"] = function()
  s.setup({ folders = false })
  local path = s.folder() .. "/new/note.txt"
  s.open(path)
  s.change()
  eq(pcall(child.cmd, "silent write"), false)
  eq(child.fn.filereadable(path), 0)
end

T["a slip such as :w] saves the buffer and leaves no stray file"] = function()
  s.setup()
  local path = s.changed_file()
  local folder = child.fn.fnamemodify(path, ":h")
  child.cmd("cd " .. folder)
  for _, slip in ipairs({ "w]", [[w\]], "w;", "w'" }) do
    s.change({ "after " .. slip })
    child.cmd("silent " .. slip)
    settle()
    eq(files_in(folder), { "note.txt" })
    eq(s.on_disk(path), { "after " .. slip })
    eq(child.bo.modified, false)
  end
  eq(s.notices()[1], "savetools: saved note.txt, not a new file named ]. Use :w! to write that name")
end

T[":w! with the same name writes it"] = function()
  s.setup()
  local path = s.changed_file()
  local folder = child.fn.fnamemodify(path, ":h")
  child.cmd("cd " .. folder)
  child.cmd("silent w! ]")
  settle()
  eq(files_in(folder), { "]", "note.txt" })
end

T["writing a copy under an ordinary name still works"] = function()
  s.setup()
  local path = s.changed_file()
  local folder = child.fn.fnamemodify(path, ":h")
  child.cmd("silent write " .. folder .. "/copy.txt")
  settle()
  eq(files_in(folder), { "copy.txt", "note.txt" })
  eq(s.on_disk(path), { "on disk" })
end

T["saving a file that was deleted underneath warns that the save brings it back"] = function()
  s.setup()
  local path = s.changed_file()
  child.fn.delete(path)
  child.cmd("silent write")
  eq(s.on_disk(path), { "changed" })
  eq(s.notices(), { "savetools: note.txt was gone from disk, and this save brought it back" })
end

T["a save sets the filetype when the buffer has none"] = function()
  s.setup({ executable = false })
  local path = s.folder() .. "/deploy"
  s.open(path)
  eq(child.bo.filetype, "")
  s.change({ "#!/bin/sh", "echo hello" })
  child.cmd("silent write")
  eq(child.bo.filetype, "sh")
end

T["notify = false silences the notes and keeps the warnings"] = function()
  s.setup({ notify = false })
  local root = s.folder()
  s.open(root .. "/new/note.txt")
  s.change()
  child.cmd("silent write")
  child.fn.delete(root .. "/new/note.txt")
  s.change({ "again" })
  child.cmd("silent write")
  eq(s.notices(), { "savetools: note.txt was gone from disk, and this save brought it back" })
end

T["plain() saves once and says the save is plain while it writes"] = function()
  s.setup()
  child.lua([[
    _G.kinds = {}
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(event)
        table.insert(_G.kinds, vim.b[event.buf].pantry_save or "by hand")
      end,
    })
  ]])
  local path = s.changed_file()
  s.call("plain")
  child.cmd("silent write!")
  eq(s.on_disk(path), { "changed" })
  eq(child.lua_get("_G.kinds"), { "plain", "by hand" })
end

return T
