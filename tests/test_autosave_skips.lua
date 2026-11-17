local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local count_writes = function()
  child.lua([[
    _G.writes = 0
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        _G.writes = _G.writes + 1
      end,
    })
  ]])
end

T["a buffer with no changes is not written"] = function()
  s.setup()
  count_writes()
  s.open(s.file(s.folder(), "note.txt"))
  s.leave()
  eq(child.lua_get("_G.writes"), 0)
end

T["a buffer with no name is left alone"] = function()
  s.setup()
  count_writes()
  s.change()
  s.leave()
  eq(child.lua_get("_G.writes"), 0)
end

T["a file that is not on disk yet is never created"] = function()
  s.setup()
  local path = s.folder() .. "/new.txt"
  s.open(path)
  s.change()
  s.leave()
  eq(child.fn.filereadable(path), 0)
end

T["a filetype in skip is left alone"] = function()
  s.setup({ skip = { "markdown" } })
  local path = s.changed_file("note.md")
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

T["a buffer that condition turns down is left alone"] = function()
  child.lua([[
    require("pantry").setup({
      autosave = {
        condition = function(buf)
          return not vim.api.nvim_buf_get_name(buf):find("secret", 1, true)
        end,
      },
    })
  ]])
  local secret = s.changed_file("secret.txt")
  s.leave()
  local plain = s.changed_file("plain.txt")
  s.leave()
  eq({ s.on_disk(secret), s.on_disk(plain) }, { { "on disk" }, { "changed" } })
end

T["vim.b.pantry_autosave = false leaves that one buffer alone"] = function()
  s.setup()
  local path = s.changed_file()
  child.b.pantry_autosave = false
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

T["a help or terminal buffer is left alone"] = function()
  s.setup()
  count_writes()
  local path = s.changed_file()
  child.bo.buftype = "nofile"
  s.leave()
  eq({ child.lua_get("_G.writes"), s.on_disk(path) }, { 0, { "on disk" } })
end

return T
