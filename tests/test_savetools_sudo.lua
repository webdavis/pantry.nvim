local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child, "savetools")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

-- Stands in for sudo: it keeps what arrives on stdin and its arguments, then runs the command.
local fake_sudo = function(exit_code)
  local folder = s.folder()
  child.fn.writefile({
    "#!/bin/sh",
    "IFS= read -r password",
    ('printf "%%s" "$password" > %s/password'):format(folder),
    ('printf "%%s " "$@" > %s/arguments'):format(folder),
    exit_code and ("echo 'Sorry, try again.' >&2; exit " .. exit_code) or 'shift 3; exec "$@"',
  }, folder .. "/sudo")
  child.fn.setfperm(folder .. "/sudo", "rwxr-xr-x")
  child.lua("vim.env.PATH = ... .. ':' .. vim.env.PATH", { folder })
  return folder
end

local until_asked = function()
  vim.wait(2000, function()
    return child.api.nvim_get_mode().mode ~= "n"
  end, 10)
end

local sudo_save = function(password)
  child.lua_notify([[require("pantry.savetools").sudo()]])
  until_asked()
  child.type_keys(password, "<CR>")
  child.lua("vim.wait(200)")
end

T["sudo() takes the password and writes the file through sudo"] = function()
  s.setup()
  local sudo = fake_sudo()
  local path = s.changed_file()
  sudo_save("hunter2")
  eq(s.on_disk(path), { "changed" })
  eq(child.bo.modified, false)
  eq(child.fn.readfile(sudo .. "/password"), { "hunter2" })
  eq(vim.startswith(child.fn.readfile(sudo .. "/arguments")[1], "-S -p  cp "), true)
  eq(s.notices(), { "savetools: saved note.txt with sudo" })
end

T["sudo() keeps the file's mode"] = function()
  s.setup()
  fake_sudo()
  local path = s.changed_file()
  child.fn.setfperm(path, "rw-r-----")
  sudo_save("hunter2")
  eq(child.fn.getfperm(path), "rw-r-----")
end

T["sudo() does nothing when you give no password"] = function()
  s.setup()
  local sudo = fake_sudo()
  local path = s.changed_file()
  sudo_save("")
  eq(s.on_disk(path), { "on disk" })
  eq(child.fn.filereadable(sudo .. "/password"), 0)
end

T["sudo() refuses a file that changed on disk"] = function()
  s.setup()
  local sudo = fake_sudo()
  local path = s.changed_file()
  child.lua("vim.wait(20)")
  child.fn.writefile({ "theirs" }, path)
  child.lua([[require("pantry.savetools").sudo()]])
  eq(s.on_disk(path), { "theirs" })
  eq(child.fn.filereadable(sudo .. "/password"), 0)
  eq(s.notices(), { "savetools: did not save note.txt with sudo, because it changed on disk" })
end

T["sudo() says what sudo said when it fails, and keeps the buffer changed"] = function()
  s.setup()
  fake_sudo(1)
  local path = s.changed_file()
  sudo_save("wrong")
  eq(s.on_disk(path), { "on disk" })
  eq(child.bo.modified, true)
  eq(s.notices(), { "savetools: sudo did not save note.txt: Sorry, try again." })
end

T["sudo() shows the file a link points to, with its owner and mode"] = function()
  s.setup()
  local path = s.file(s.folder(), "real.txt")
  child.fn.setfperm(path, "rw-r-----")
  local link = s.folder() .. "/link.txt"
  child.uv.fs_symlink(path, link)
  s.open(link)
  child.lua([[
    vim.fn.inputsecret = function(prompt)
      _G.prompt = prompt
      return ""
    end
    require("pantry.savetools").sudo()
  ]])
  local owner = child.fn.system("id -un"):gsub("%s+$", "")
  eq(
    child.lua_get("_G.prompt"),
    ("Save %s with sudo? Owner %s, mode 640.\nPassword, or nothing to cancel: "):format(path, owner)
  )
end

T["sudo() leaves the password out of the messages and the command history"] = function()
  s.setup()
  fake_sudo()
  s.changed_file()
  sudo_save("hunter2")
  local seen = child.cmd_capture("messages") .. child.cmd_capture("history all")
  eq(seen:find("hunter2", 1, true), nil)
end

return T
