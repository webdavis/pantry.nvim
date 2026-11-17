local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child, "savetools")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local script = { "#!/bin/sh", "echo hello" }

local folder_named = function(name)
  local folder = s.folder() .. "/" .. name
  child.fn.mkdir(folder, "p")
  return folder
end

local existing_script = function(folder, name, executable)
  local path = s.file(folder, name, script)
  child.fn.setfperm(path, executable and "rwxr-xr-x" or "rw-r--r--")
  return path
end

local save_new = function(folder, name, lines)
  local path = folder .. "/" .. (name or "deploy")
  s.open(path)
  s.change(lines or script)
  child.cmd("silent write")
  return path
end

local is_executable = function(path)
  return child.fn.getfperm(path):sub(3, 3) == "x"
end

T["a new script in a folder named bin becomes executable, and the notice says why"] = function()
  s.setup()
  local path = save_new(folder_named("bin"))
  eq(is_executable(path), true)
  eq(s.notices(), { "savetools: made deploy executable, because bin is in executable.always" })
end

T["a new script becomes executable when every other script in its folder is"] = function()
  s.setup()
  local folder = folder_named("tools")
  existing_script(folder, "build", true)
  s.file(folder, "README.md", { "# Tools" })
  local path = save_new(folder)
  eq(is_executable(path), true)
  eq(s.notices(), { "savetools: made deploy executable, because every other script in tools is" })
end

T["a new script is left alone when the scripts in its folder are mixed"] = function()
  s.setup()
  local folder = folder_named("tools")
  existing_script(folder, "build", true)
  existing_script(folder, "library", false)
  local path = save_new(folder)
  eq(is_executable(path), false)
  eq(s.notices(), {})
end

T["the first script in a folder is left alone, and the notice says so"] = function()
  s.setup()
  local path = save_new(folder_named("tools"))
  eq(is_executable(path), false)
  eq(s.notices(), { "savetools: left deploy as it is, because tools has no other script to go by" })
end

T["a folder in executable.never wins over one in executable.always"] = function()
  s.setup({ executable = { always = { "hooks" }, never = { "hooks" } } })
  local path = save_new(folder_named("hooks"))
  eq(is_executable(path), false)
end

T["a path in executable.always matches that folder and the ones below it"] = function()
  local root = s.folder()
  s.setup({ executable = { always = { root .. "/project/**" } } })
  child.fn.mkdir(root .. "/project/tools/deep", "p")
  eq(is_executable(save_new(root .. "/project/tools/deep")), true)
end

T["a new script in a folder on PATH becomes executable"] = function()
  s.setup()
  local folder = folder_named("mine")
  child.lua("vim.env.PATH = ... .. ':' .. vim.env.PATH", { folder })
  eq(is_executable(save_new(folder)), true)
end

T["a file that already exists is never touched"] = function()
  s.setup()
  local path = existing_script(folder_named("bin"), "deploy", false)
  s.open(path)
  s.change({ "#!/bin/sh", "echo changed" })
  child.cmd("silent write")
  eq(is_executable(path), false)
end

T["a new file that is not a script is left alone"] = function()
  s.setup()
  local path = save_new(folder_named("bin"), "notes.txt", { "plain text" })
  eq(is_executable(path), false)
  eq(s.notices(), {})
end

T["executable = false turns the tool off"] = function()
  s.setup({ executable = false })
  eq(is_executable(save_new(folder_named("bin"))), false)
end

return T
