local M = {}

M.chars = function(line)
  local chars = {}
  for char in line:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    chars[#chars + 1] = char
  end
  return chars
end

M.join = function(chars, from, to)
  return table.concat(chars, "", from + 1, to)
end

M.is_word = function(char)
  return char:match("^[%w_]") ~= nil or #char > 1
end

M.not_word = function(char)
  return not M.is_word(char)
end

M.is_blank = function(char)
  return char:match("^%s$") ~= nil
end

M.not_blank = function(char)
  return not M.is_blank(char)
end

M.not_path_sep = function(char)
  return char ~= "/" and M.not_blank(char)
end

M.skip_back = function(chars, i, pred)
  while i > 0 and pred(chars[i]) do
    i = i - 1
  end
  return i
end

M.skip_forward = function(chars, i, pred)
  while i < #chars and pred(chars[i + 1]) do
    i = i + 1
  end
  return i
end

local negate = function(pred)
  return function(char)
    return not pred(char)
  end
end

M.back = function(chars, i, inside)
  return M.skip_back(chars, M.skip_back(chars, i, negate(inside)), inside)
end

M.forward = function(chars, i, inside)
  return M.skip_forward(chars, M.skip_forward(chars, i, negate(inside)), inside)
end

M.first_nonblank = function(chars)
  return M.skip_forward(chars, 0, M.is_blank)
end

return M
