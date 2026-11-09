local menu = require("pantry.rsi.menu")

local M = {}

local modes = { insert = "i", cmdline = "c" }

M.setup = function(opts)
  local off = require("pantry.keys").turned_off(opts or {})
  for _, key in ipairs(require("pantry.rsi.keys")) do
    if not off[vim.keycode(key.lhs)] then
      for mode, short in pairs(modes) do
        local action = key[mode]
        if action then
          vim.keymap.set(short, key.lhs, function()
            if key.yields_to_menu and menu.is_visible() then
              return key.lhs
            end
            return action(key.lhs)
          end, { expr = true, desc = "rsi: " .. key.desc })
        end
      end
    end
  end
end

return M
