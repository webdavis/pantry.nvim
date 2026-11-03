local M = {}

local size = 60

M.new = function()
  local kills = {}
  local index = 1
  local ring = {}

  ring.push = function(kill)
    if kill ~= "" then
      table.insert(kills, 1, kill)
      kills[size + 1] = nil
    end
  end

  ring.yank = function()
    index = 1
    return kills[index]
  end

  ring.rotate = function()
    index = index % #kills + 1
    return kills[index]
  end

  return ring
end

return M
