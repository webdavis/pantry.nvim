local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local record_save_kinds = function()
  child.lua([[
    _G.kinds = {}
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(event)
        table.insert(_G.kinds, vim.b[event.buf].pantry_save or "by hand")
      end,
    })
  ]])
end

T["leaving a buffer saves it"] = function()
  s.setup()
  local path = s.changed_file()
  s.leave()
  eq(s.on_disk(path), { "changed" })
end

T["losing focus saves every changed buffer"] = function()
  s.setup()
  local first = s.changed_file("first.txt")
  child.cmd("noautocmd enew")
  local second = s.changed_file("second.txt")
  child.cmd("noautocmd enew")
  eq({ s.on_disk(first), s.on_disk(second) }, { { "on disk" }, { "on disk" } })
  s.lose_focus()
  eq({ s.on_disk(first), s.on_disk(second) }, { { "changed" }, { "changed" } })
end

T["a pause after an edit saves it"] = function()
  s.setup({ delay = 20 })
  local path = s.changed_file()
  s.edit()
  eq(s.on_disk(path), { "on disk" })
  s.wait()
  eq(s.on_disk(path), { "changed" })
end

T["going back to typing holds the pause save"] = function()
  s.setup({ delay = 20 })
  local path = s.changed_file()
  s.edit()
  child.cmd("doautocmd InsertEnter")
  s.wait()
  eq(s.on_disk(path), { "on disk" })
end

T["a pause save waits while a macro records"] = function()
  s.setup({ delay = 20 })
  local path = s.changed_file()
  child.type_keys("qq")
  s.edit()
  s.wait()
  eq(s.on_disk(path), { "on disk" })
  child.type_keys("q")
  s.leave()
  eq(s.on_disk(path), { "changed" })
end

T["a leave save says so while it writes"] = function()
  s.setup()
  record_save_kinds()
  s.changed_file()
  s.leave()
  eq(child.lua_get("_G.kinds"), { "leave" })
  eq(child.lua_get("vim.b[vim.fn.bufnr('#')].pantry_save"), vim.NIL)
end

T["quitting a window saves its buffer as a leave save"] = function()
  s.setup()
  record_save_kinds()
  local path = s.changed_file()
  child.cmd("split")
  child.cmd("quit")
  eq(s.on_disk(path), { "changed" })
  eq(child.lua_get("_G.kinds"), { "leave" })
end

T["suspending Neovim saves the buffer as a leave save"] = function()
  s.setup()
  record_save_kinds()
  local path = s.changed_file()
  child.cmd("doautocmd VimSuspend")
  eq(s.on_disk(path), { "changed" })
  eq(child.lua_get("_G.kinds"), { "leave" })
end

T["a pause save says so while it writes"] = function()
  s.setup({ delay = 20 })
  record_save_kinds()
  s.changed_file()
  s.edit()
  s.wait()
  eq(child.lua_get("_G.kinds"), { "pause" })
  eq(child.lua_get("vim.b.pantry_save"), vim.NIL)
end

T["a save by hand carries no kind"] = function()
  s.setup()
  record_save_kinds()
  s.changed_file()
  child.cmd("write")
  eq(child.lua_get("_G.kinds"), { "by hand" })
end

T["mode = 'off' saves nothing until autosave is turned on"] = function()
  s.setup({ mode = "off" })
  local path = s.changed_file()
  s.leave()
  eq(s.on_disk(path), { "on disk" })
  s.call("toggle")
  child.cmd("buffer #")
  s.leave()
  eq(s.on_disk(path), { "changed" })
end

T["turning autosave off stops the saves and drops a pending one"] = function()
  s.setup({ delay = 20 })
  local path = s.changed_file()
  s.edit()
  s.call("disable")
  s.wait()
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

return T
