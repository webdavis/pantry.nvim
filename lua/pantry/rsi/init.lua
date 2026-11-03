local menu = require("pantry.rsi.menu")

local M = {}

local modes = { insert = "i", cmdline = "c" }

local turned_off = function(opts)
  local off = {}
  for lhs, on in pairs(opts.keys or {}) do
    off[vim.keycode(lhs)] = on == false
  end
  return off
end

M.setup = function(opts)
  local off = turned_off(opts or {})
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
