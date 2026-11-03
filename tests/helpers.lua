local Helpers = {}

Helpers.new_child = function(setup_code)
  local child = MiniTest.new_child_neovim()
  local hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      if setup_code then
        child.lua(setup_code)
      end
    end,
    post_once = child.stop,
  }
  return child, hooks
end

Helpers.rsi_child = function()
  return Helpers.new_child([[require("pantry.rsi").setup()]])
end

Helpers.editing = function(child)
  return {
    lines = function(lines)
      child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end,
    buffer = function()
      return child.api.nvim_buf_get_lines(0, 0, -1, false)
    end,
    line = function()
      return child.api.nvim_get_current_line()
    end,
    cmdline = function()
      return { child.fn.getcmdline(), child.fn.getcmdpos() }
    end,
    open_menu = function()
      child.lua([[package.loaded["blink.cmp"] = { is_visible = function() return true end }]])
    end,
  }
end

return Helpers
