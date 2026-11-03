local M = {}

M.root = function(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if ok and parser then
    return parser:parse()[1]:root(), parser:lang()
  end
end

M.captures = function(buf, query_for, capture)
  local root, lang = M.root(buf)
  local query = root and query_for(lang)
  local nodes = {}
  if query then
    for id, node in query:iter_captures(root, buf) do
      if query.captures[id] == capture then
        table.insert(nodes, node)
      end
    end
  end
  return nodes
end

M.start_rows = function(nodes)
  return vim.tbl_map(function(node)
    return node:start() + 1
  end, nodes)
end

return M
