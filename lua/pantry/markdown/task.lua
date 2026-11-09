local M = {}

M.toggle = function(line)
  local prefix = line:match("^(%s*[-*+] )") or line:match("^(%s*%d+[.)] )")
  if not prefix then
    local indent, text = line:match("^(%s*)(.*)$")
    return indent .. "- [ ] " .. text, 6
  end
  local box = line:sub(#prefix + 1, #prefix + 3)
  local rest = line:sub(#prefix + 4)
  if box == "[ ]" then
    return prefix .. "[x]" .. rest, 0
  end
  if box == "[x]" or box == "[X]" then
    return prefix .. "[ ]" .. rest, 0
  end
  return prefix .. "[ ] " .. line:sub(#prefix + 1), 4
end

return M
