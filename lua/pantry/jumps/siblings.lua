local treesitter = require("pantry.jumps.treesitter")

local M = {}

local neighbor = { [1] = "next_named_sibling", [-1] = "prev_named_sibling" }

local same_start = function(a, b)
  local a_row, a_col = a:start()
  local b_row, b_col = b:start()
  return a_row == b_row and a_col == b_col
end

local has_peer_below_or_above = function(parent, node)
  local row, col = node:start()
  for child in parent:iter_children() do
    local child_row, child_col = child:start()
    if child:named() and child_row ~= row and child_col == col then
      return true
    end
  end
  return false
end

local line_node = function(root, buf, row)
  local col = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]:find("%S")
  if not col then
    return nil
  end
  local node = root:named_descendant_for_range(row - 1, col - 1, row - 1, col - 1)
  local parent = node:parent()
  while parent and same_start(node, parent) and not has_peer_below_or_above(parent, node) do
    node, parent = parent, parent:parent()
  end
  return node
end

local sibling = function(node, direction)
  local row = node:start()
  local found = node[neighbor[direction]](node)
  while found and found:start() == row do
    found = found[neighbor[direction]](found)
  end
  return found
end

M.find = function(buf, cursor, direction, count)
  local root = treesitter.root(buf)
  local node = root and line_node(root, buf, cursor[1])
  local target
  for _ = 1, count do
    local found = node and sibling(node, direction)
    if not found then
      break
    end
    node, target = found, found
  end
  return target and target:start() + 1
end

return M
