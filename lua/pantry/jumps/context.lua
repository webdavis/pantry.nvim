local M = {}

M.move = function(_, count)
  local ok, context = pcall(require, "treesitter-context")
  if ok then
    context.go_to_context(count)
  end
end

return M
