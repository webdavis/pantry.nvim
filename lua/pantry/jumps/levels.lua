local blocks = require("pantry.jumps.blocks")
local treesitter = require("pantry.jumps.treesitter")

local M = {}

local history = {}

local paragraph = { [1] = "}", [-1] = "{" }

local remembered = function(buf, row)
  local last = history[buf]
  if last and last.row == row and last.tick == vim.b[buf].changedtick then
    return last.stack
  end
  return {}
end

local outer = function(ranges, row)
  local found
  for _, range in ipairs(ranges) do
    if range.first < row and row <= range.last and (not found or range.first > found) then
      found = range.first
    end
  end
  return found
end

local inner = function(ranges, row)
  local around
  for _, range in ipairs(ranges) do
    if
      range.first <= row
      and row <= range.last
      and (not around or range.last - range.first < around.last - around.first)
    then
      around = range
    end
  end
  local found
  for _, range in ipairs(ranges) do
    if around and range.first > row and range.first <= around.last and (not found or range.first < found) then
      found = range.first
    end
  end
  return found
end

M.find = function(buf, cursor, direction, count)
  if not treesitter.root(buf) then
    vim.cmd(("normal! %d%s"):format(count, paragraph[direction]))
    return nil
  end
  local ranges = blocks.ranges(buf)
  local stack = remembered(buf, cursor[1])
  local row = cursor[1]
  for _ = 1, count do
    local target
    if direction < 0 then
      target = outer(ranges, row)
      if target then
        table.insert(stack, row)
      end
    else
      target = table.remove(stack) or inner(ranges, row)
    end
    row = target or row
  end
  history[buf] = { stack = stack, row = row, tick = vim.b[buf].changedtick }
  return row ~= cursor[1] and row or nil
end

return M
