local M = {}

M.step = function(rows, from, direction, count)
  local seen, ahead = {}, {}
  for _, row in ipairs(rows) do
    if (row - from) * direction > 0 and not seen[row] then
      seen[row] = true
      table.insert(ahead, row)
    end
  end
  table.sort(ahead, function(a, b)
    return (a - from) * direction < (b - from) * direction
  end)
  return ahead[math.min(count, #ahead)]
end

return M
