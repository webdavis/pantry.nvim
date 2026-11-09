local Helpers = require("tests.helpers")

local Folder = {}

Folder.make = function(names)
  local dir = vim.fn.resolve(vim.fn.tempname())
  vim.fn.mkdir(dir, "p")
  for _, name in ipairs(names) do
    vim.fn.writefile({}, dir .. "/" .. name)
  end
  return dir
end

Folder.browsing = function(child)
  local screen = Helpers.screen(child)
  return {
    open = function(dir, name)
      child.cmd("edit " .. vim.fn.fnameescape(dir .. "/" .. name))
    end,
    press = function(keys)
      child.type_keys(keys)
      return vim.fs.basename(child.api.nvim_buf_get_name(0))
    end,
    message = function()
      return screen.line(child.o.lines)
    end,
  }
end

return Folder
