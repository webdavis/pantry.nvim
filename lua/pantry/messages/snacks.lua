local format_row = function(item, picker)
  local row = require("snacks.picker.format").notification(item, picker)
  local time = row[1]
  if not item.item.added and time and time[1]:match("^%d%d:%d%d") then
    time[1] = (" "):rep(#time[1])
  end
  return row
end

return function(entries)
  local items = {}
  for _, entry in ipairs(entries) do
    items[#items + 1] = {
      text = table.concat(
        vim.tbl_filter(function(field)
          return field ~= ""
        end, { entry.level, entry.kind, entry.msg }),
        " "
      ),
      item = { added = entry.added, title = entry.kind, msg = entry.msg },
      severity = entry.level,
      preview = { text = entry.msg, ft = "text" },
    }
  end
  require("snacks").picker({
    title = "Messages",
    items = items,
    format = format_row,
    preview = "preview",
    formatters = { severity = { level = true } },
    confirm = "close",
  })
end
