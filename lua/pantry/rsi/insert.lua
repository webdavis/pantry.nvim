local text = require("pantry.rsi.text")

local M = {}

local move = function(steps)
  local key = steps < 0 and "<C-g>U<Left>" or "<C-g>U<Right>"
  return key:rep(math.abs(steps))
end

M.new = function(ring)
  local insert = {}

  insert.edit = function(op)
    return function(lhs)
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local state = { chars = text.chars(line), cursor = #text.chars(line:sub(1, col)) }
      local edit = op(state)
      if not edit then
        return lhs
      end
      if edit.kill then
        ring.push(text.join(state.chars, edit.from, edit.to))
      end
      local typed = edit.text:gsub("<", "<lt>")
      return move(edit.from - state.cursor)
        .. ("<Del>"):rep(edit.to - edit.from)
        .. typed
        .. move(edit.cursor - edit.from - #text.chars(edit.text))
    end
  end

  return insert
end

return M
