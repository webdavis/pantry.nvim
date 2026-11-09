local render = function(entry)
  local time = entry.added and os.date("%H:%M:%S", entry.added) or "--:--:--"
  local prefix = table.concat(
    vim.tbl_filter(function(field)
      return field ~= ""
    end, { time, entry.level, entry.kind }),
    " "
  ) .. " "
  local lines = vim.split(entry.msg, "\n")
  for i, line in ipairs(lines) do
    lines[i] = (i == 1 and prefix or (" "):rep(#prefix)) .. line
  end
  return lines
end

return function(entries)
  local lines = {}
  for _, entry in ipairs(entries) do
    vim.list_extend(lines, render(entry))
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_open_win(buf, true, { split = "below", win = -1 })
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, desc = "messages: Close the history" })
end
