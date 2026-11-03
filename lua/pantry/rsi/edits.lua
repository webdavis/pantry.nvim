local text = require("pantry.rsi.text")

local M = {}

local move = function(state, to)
  return { from = state.cursor, to = state.cursor, text = "", cursor = to }
end

local kill = function(from, to)
  return { from = from, to = to, text = "", cursor = from, kill = true }
end

local recase = function(transform)
  return function(state)
    local from = text.skip_forward(state.chars, state.cursor, text.not_word)
    local to = text.skip_forward(state.chars, from, text.is_word)
    return { from = from, to = to, text = transform(text.join(state.chars, from, to)), cursor = to }
  end
end

M.start = function(state)
  return move(state, 0)
end

M.first_nonblank = function(state)
  return move(state, text.first_nonblank(state.chars))
end

M.end_of_line = function(state)
  if state.cursor < #state.chars then
    return move(state, #state.chars)
  end
end

M.left = function(state)
  return move(state, math.max(state.cursor - 1, 0))
end

M.right = function(state)
  if state.cursor < #state.chars then
    return move(state, state.cursor + 1)
  end
end

M.word_back = function(state)
  return move(state, text.back(state.chars, state.cursor, text.is_word))
end

M.word_forward = function(state)
  return move(state, text.forward(state.chars, state.cursor, text.is_word))
end

M.delete_char = function(state)
  if state.cursor < #state.chars then
    return { from = state.cursor, to = state.cursor + 1, text = "", cursor = state.cursor }
  end
end

M.kill_to_end = function(state)
  return kill(state.cursor, #state.chars)
end

M.kill_to_start = function(state)
  return kill(0, state.cursor)
end

M.kill_to_indent = function(state)
  local indent = text.first_nonblank(state.chars)
  return kill(state.cursor > indent and indent or 0, state.cursor)
end

M.kill_word_forward = function(state)
  return kill(state.cursor, text.forward(state.chars, state.cursor, text.is_word))
end

M.kill_word_back = function(state)
  return kill(text.back(state.chars, state.cursor, text.is_word), state.cursor)
end

M.kill_blank_word_back = function(state)
  return kill(text.back(state.chars, state.cursor, text.not_blank), state.cursor)
end

M.kill_path_back = function(state)
  local from = state.cursor
  if from > 0 and not text.not_path_sep(state.chars[from]) then
    from = from - 1
  end
  return kill(text.skip_back(state.chars, from, text.not_path_sep), state.cursor)
end

M.upcase_word = recase(vim.fn.toupper)

M.downcase_word = recase(vim.fn.tolower)

M.capitalize_word = recase(function(word)
  return vim.fn.toupper(vim.fn.strcharpart(word, 0, 1)) .. vim.fn.tolower(vim.fn.strcharpart(word, 1))
end)

M.transpose = function(state)
  if #state.chars < 2 then
    return nil
  end
  local i = math.min(math.max(state.cursor, 1), #state.chars - 1)
  return { from = i - 1, to = i + 1, text = state.chars[i + 1] .. state.chars[i], cursor = i + 1 }
end

return M
