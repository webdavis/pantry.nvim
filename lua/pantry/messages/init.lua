local history = require("pantry.messages.history")

local M = {}

local config = {
  ui2 = true,
  view = "auto",
  keys = { ["<leader>nh"] = "history" },
}

local views = {
  buffer = function()
    return require("pantry.messages.buffer")
  end,
  snacks = function()
    return require("pantry.messages.snacks")
  end,
  auto = function()
    local has_snacks = pcall(require, "snacks")
    return require("pantry.messages." .. (has_snacks and "snacks" or "buffer"))
  end,
}

local show = function(view)
  views[view]()(history.newest_first())
end

local actions = {
  history = function()
    show(config.view)
  end,
  history_buffer = function()
    show("buffer")
  end,
  history_snacks = function()
    show("snacks")
  end,
}

local enable_ui2 = function()
  if config.ui2 == false then
    return
  end
  local ok, ui2 = pcall(require, "vim._core.ui2")
  if not ok then
    return
  end
  local options = config.ui2 == true and { msg = { target = "msg" } } or config.ui2
  ui2.enable(options)
end

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  enable_ui2()
  history.record()
  for lhs, action in pairs(config.keys) do
    if action then
      local unknown =
        "pantry.messages: %s maps to unknown action %q, expected history, history_buffer or history_snacks"
      vim.keymap.set("n", lhs, actions[action] or error(unknown:format(lhs, action)), {
        desc = "messages: Show the message history",
      })
    end
  end
end

return M
