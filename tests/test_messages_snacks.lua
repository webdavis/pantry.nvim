local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local m = Helpers.messaging(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local fake_snacks = function()
  child.lua([[
    package.loaded.snacks = { picker = function(opts) _G.picked = opts end }
    package.loaded["snacks.picker.format"] = {
      notification = function() return "notification" end,
      text = function() return "text" end,
    }
  ]])
end

local row_format = function(index)
  return child.lua_get("_G.picked.format(_G.picked.items[...])", { index })
end

local picked = function()
  return child.lua_get("vim.tbl_extend('force', _G.picked, { format = type(_G.picked.format) })")
end

T["the snacks view opens the notification picker newest first"] = function()
  m.with_ui()
  fake_snacks()
  m.setup({ view = "snacks" })
  child.cmd("echomsg 'first'")
  child.cmd("echomsg 'second'")
  m.history()
  local opts = picked()
  local added = opts.items[1].item.added
  eq(type(added), "number")
  eq(opts.items[1], {
    text = "info echomsg second",
    item = { added = added, title = "echomsg", msg = "second" },
    severity = "info",
    preview = { text = "second", ft = "text" },
  })
  eq(opts.items[2].item.msg, "first")
  eq(row_format(1), "notification")
  opts.items, opts.format = nil, nil
  eq(opts, {
    title = "Messages",
    preview = "preview",
    formatters = { severity = { level = true } },
    confirm = "close",
  })
end

T["auto picks snacks when it loads"] = function()
  fake_snacks()
  m.setup({ ui2 = false })
  child.cmd("echomsg 'plain'")
  m.history()
  eq(picked().items[1].text, "info plain")
end

T["the snacks view shows the lines of :messages as plain text"] = function()
  fake_snacks()
  m.setup({ ui2 = false, view = "snacks" })
  child.cmd("echomsg 'plain'")
  m.history()
  eq(row_format(1), "text")
end

T["the snacks view shows a message from before setup as plain text below the recorded ones"] = function()
  child.cmd("echomsg 'early'")
  m.with_ui()
  fake_snacks()
  m.setup({ view = "snacks" })
  child.cmd("echomsg 'late'")
  m.history()
  eq({ picked().items[1].text, row_format(1) }, { "info echomsg late", "notification" })
  eq({ picked().items[2].text, row_format(2) }, { "info early", "text" })
end

T["auto falls back to the buffer view without snacks"] = function()
  m.setup({ ui2 = false })
  child.cmd("echomsg 'plain'")
  eq(m.history(), { "--:--:-- info plain" })
end

T["history_buffer and history_snacks ignore view"] = function()
  fake_snacks()
  m.setup({ ui2 = false, keys = { ["<leader>nb"] = "history_buffer", ["<leader>ns"] = "history_snacks" } })
  child.cmd("echomsg 'plain'")
  child.type_keys("<Bslash>ns")
  eq(picked().items[1].item.msg, "plain")
  child.type_keys("<Bslash>nb")
  eq(child.api.nvim_buf_get_lines(0, 0, -1, false), { "--:--:-- info plain" })
end

return T
