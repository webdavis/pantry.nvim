local format_row = function(item, picker)
  local format = require("snacks.picker.format")
  return (item.item.added and format.notification or format.text)(item, picker)
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
