local resolvers = {
  function(_, buf)
    local textwidth = vim.bo[buf].textwidth
    return textwidth > 0 and textwidth or nil
  end,
}

return function(win, buf, opts)
  for _, resolve in ipairs(resolvers) do
    local found = resolve(win, buf, opts)
    if found then
      return found
    end
  end
end
