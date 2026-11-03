local M = {}

local line_range = function(node)
  local first, _, last, last_col = node:range()
  return { first = first, last = last_col == 0 and last > first and last - 1 or last }
end

local covers_line = function(node, row, line)
  local first, first_col, last, last_col = node:range()
  local indent = (line:find("%S") or 1) - 1
  return (first < row or first_col <= indent) and (last > row or line:sub(last_col + 1):match("^[%s,;]*$") ~= nil)
end

local add = function(chain, range)
  local top = chain[#chain]
  if not top or top.first ~= range.first or top.last ~= range.last then
    table.insert(chain, range)
  end
end

local whole = function(buf)
  return { first = 0, last = vim.api.nvim_buf_line_count(buf) - 1 }
end

local paragraph = function(buf, row)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local blank = function(at)
    return lines[at + 1] == nil or lines[at + 1]:match("^%s*$") ~= nil
  end
  local first, last = row, row
  while not blank(row) and not blank(first - 1) do
    first = first - 1
  end
  while not blank(row) and not blank(last + 1) do
    last = last + 1
  end
  return { first = first, last = last }
end

local tree = function(buf, row)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return nil
  end
  parser:parse()
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  local indent = (line:find("%S") or 1) - 1
  local node = parser:named_node_for_range({ row, indent, row, indent })
  while node and node:parent() and not covers_line(node, row, line) do
    node = node:parent()
  end
  local chain = {}
  while node do
    add(chain, line_range(node))
    node = node:parent()
  end
  return chain
end

M.chain = function(buf, row)
  local chain = tree(buf, row)
  local start = 1
  if chain then
    while chain[start + 1] and chain[start].first == chain[start].last do
      start = start + 1
    end
  else
    chain = { paragraph(buf, row) }
  end
  add(chain, whole(buf))
  return chain, start
end

return M
