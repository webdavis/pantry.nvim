local display_width = function(text, tabstop)
  local cells = 0
  for segment, tab in text:gmatch("([^\t]*)(\t?)") do
    cells = cells + vim.api.nvim_strwidth(segment)
    if tab ~= "" then
      cells = cells + tabstop - cells % tabstop
    end
  end
  return cells
end

return function(text, limit, near, tabstop)
  local width = display_width(text, tabstop)
  if width > limit then
    return { over = width - limit }
  end
  if width >= limit - near then
    return { mark = limit }
  end
end
