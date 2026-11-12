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
    format = entries[1] and entries[1].added and "notification" or "text",
    preview = "preview",
    formatters = { severity = { level = true } },
    confirm = "close",
  })
end
