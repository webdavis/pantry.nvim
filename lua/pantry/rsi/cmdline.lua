local edits = require("pantry.rsi.edits")
local text = require("pantry.rsi.text")

local M = {}

local read = function()
  local line = vim.fn.getcmdline()
  return { chars = text.chars(line), cursor = #text.chars(line:sub(1, vim.fn.getcmdpos() - 1)) }
end

local write = function(state, edit)
  local line = text.join(state.chars, 0, edit.from) .. edit.text .. text.join(state.chars, edit.to, #state.chars)
  vim.fn.setcmdline(line, #text.join(text.chars(line), 0, edit.cursor) + 1)
  return ""
end

M.new = function(ring)
  local cmdline = {}
  local last = {}

  local continuing = function(kind)
    return last.kind == kind and last.line == vim.fn.getcmdline() and last.pos == vim.fn.getcmdpos()
  end

  local put = function(kind, step, str)
    local state = read()
    local from, to = state.cursor, state.cursor
    if step > 1 then
      from, to = last.from, last.to
    end
    local stop = from + #text.chars(str)
    write(state, { from = from, to = to, text = str, cursor = stop })
    last = { kind = kind, step = step, from = from, to = stop, line = vim.fn.getcmdline(), pos = vim.fn.getcmdpos() }
    return ""
  end

  cmdline.edit = function(op, fallback)
    return function(lhs)
      local state = read()
      local edit = op(state)
      if not edit then
        return fallback and fallback() or lhs
      end
      if edit.kill then
        ring.push(text.join(state.chars, edit.from, edit.to))
      end
      return write(state, edit)
    end
  end

  cmdline.transpose = function(lhs)
    if vim.fn.getcmdtype():match("[/?]") then
      return lhs
    end
    return cmdline.edit(edits.transpose)(lhs)
  end

  cmdline.yank = function()
    local kill = ring.yank()
    return kill and put("yank", 1, kill) or ""
  end

  cmdline.yank_pop = function()
    return continuing("yank") and put("yank", last.step + 1, ring.rotate()) or ""
  end

  cmdline.last_arg = function()
    local step = continuing("arg") and last.step + 1 or 1
    local arg = vim.fn.histget("cmd", -step):match("(%S+)%s*$")
    return arg and put("arg", step, arg) or ""
  end

  return cmdline
end

return M
