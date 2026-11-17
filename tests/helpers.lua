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

Helpers.screen = function(child)
  local rows = function()
    child.cmd("redraw")
    return child.get_screenshot().text
  end
  return {
    cell = function(row, col)
      return rows()[row][col]
    end,
    line = function(row)
      return vim.trim(table.concat(rows()[row]))
    end,
  }
end

Helpers.jumps_child = function()
  return Helpers.new_child([[require("pantry.jumps").setup()]])
end

Helpers.markdown_child = function()
  return Helpers.new_child([[require("pantry.markdown").setup()]])
end

Helpers.jumping = function(child)
  local j = {}
  j.open = function(filetype, lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    child.bo.filetype = filetype
  end
  j.at = function(row)
    child.api.nvim_win_set_cursor(0, { row, 0 })
  end
  j.press = function(...)
    child.type_keys(...)
    return child.api.nvim_win_get_cursor(0)[1]
  end
  return j
end

Helpers.focusing = function(child)
  local f = {}
  f.open = function(filetype, lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    child.bo.filetype = filetype
    child.cmd("syntax off")
    child.lua("vim.treesitter.stop()")
  end
  f.at = function(row)
    child.api.nvim_win_set_cursor(0, { row, 0 })
  end
  f.call = function(name)
    child.lua(('require("pantry.focus").%s()'):format(name))
  end
  f.lit = function()
    child.cmd("redraw")
    local attrs = child.get_screenshot().attr
    local rows = {}
    for row = 1, child.api.nvim_buf_line_count(0) do
      if attrs[row][1] == attrs[row][#attrs[row]] then
        table.insert(rows, row)
      end
    end
    return rows
  end
  return f
end

Helpers.messaging = function(child)
  local m = {}
  m.with_ui = function()
    child.lua([[vim.api.nvim_list_uis = function() return { {} } end]])
  end
  m.setup = function(opts)
    child.lua("require('pantry').setup({ messages = ... })", { opts or {} })
  end
  m.history = function()
    child.type_keys("<Bslash>nh")
    return child.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  return m
end

Helpers.saving = function(child)
  local s = {}
  s.setup = function(opts)
    child.lua(
      [[
      _G.notices = {}
      vim.notify = function(message)
        table.insert(_G.notices, message)
      end
      require("pantry").setup({ autosave = ... })
    ]],
      { opts or {} }
    )
  end
  s.folder = function()
    local path = child.fn.tempname()
    child.fn.mkdir(path, "p")
    return child.fn.resolve(path)
  end
  s.file = function(folder, name, lines)
    local path = folder .. "/" .. name
    child.fn.writefile(lines or { "on disk" }, path)
    return path
  end
  s.open = function(path)
    child.cmd("edit " .. child.fn.fnameescape(path))
  end
  s.change = function(lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, lines or { "changed" })
  end
  s.changed_file = function(name, lines)
    local path = s.file(s.folder(), name or "note.txt", lines)
    s.open(path)
    s.change()
    return path
  end
  s.leave = function()
    child.cmd("enew")
  end
  s.lose_focus = function()
    child.cmd("doautocmd FocusLost")
  end
  s.edit = function()
    child.cmd("doautocmd TextChanged")
  end
  s.wait = function()
    child.lua("vim.wait(150)")
  end
  s.on_disk = function(path)
    return child.fn.readfile(path)
  end
  s.notices = function()
    return child.lua_get("_G.notices")
  end
  s.call = function(name)
    child.lua(('require("pantry.autosave").%s()'):format(name))
  end
  s.status = function()
    return child.lua_get([[require("pantry.autosave").status()]])
  end
  return s
end

return Helpers
