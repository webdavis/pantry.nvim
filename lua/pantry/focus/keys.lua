local M = {}

local registry = {
  { lhs = "<M-o>", desc = "Show more around the cursor", action = "widen" },
  { lhs = "<M-i>", desc = "Show less around the cursor", action = "narrow" },
}

local mapped = {}

local turned_off = function(opts)
  local off = {}
  for lhs, on in pairs(opts.keys or {}) do
    off[vim.keycode(lhs)] = on == false
  end
  return off
end

M.map = function(buf, opts)
  mapped[buf] = true
  local off = turned_off(opts)
  for _, key in ipairs(registry) do
    if not off[vim.keycode(key.lhs)] then
      vim.keymap.set("n", key.lhs, function()
        require("pantry.focus")[key.action]()
      end, { buffer = buf, desc = "focus: " .. key.desc })
    end
  end
end

M.unmap_all = function()
  for buf in pairs(mapped) do
    for _, key in ipairs(registry) do
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.keymap.del, "n", key.lhs, { buffer = buf })
      end
    end
  end
  mapped = {}
end

return M
