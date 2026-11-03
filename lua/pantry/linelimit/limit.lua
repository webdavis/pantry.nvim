local window = require("pantry.linelimit.window")

local from_colorcolumn = function(win, buf)
  local first = vim.split(window.colorcolumn(win), ",")[1]
  local column = tonumber(first)
  if not column then
    return nil
  end
  if first:match("^[+-]") then
    local textwidth = vim.bo[buf].textwidth
    return textwidth > 0 and textwidth + column - 1 or nil
  end
  return column - 1
end

local from_textwidth = function(_, buf)
  local textwidth = vim.bo[buf].textwidth
  return textwidth > 0 and textwidth or nil
end

local from_editorconfig = function(_, buf)
  local editorconfig = vim.b[buf].editorconfig
  return editorconfig and tonumber(editorconfig.max_line_length)
end

local from_filetypes = function(_, buf, opts)
  return opts.filetypes[vim.bo[buf].filetype]
end

local resolvers = { from_colorcolumn, from_textwidth, from_editorconfig, from_filetypes }

return function(win, buf, opts)
  for _, resolve in ipairs(resolvers) do
    local found = resolve(win, buf, opts)
    if found then
      return found
    end
  end
end
