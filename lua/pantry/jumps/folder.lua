local M = {}

local skipped_extensions = {}
-- stylua: ignore
for _, extension in ipairs({
  "png", "jpg", "jpeg", "gif", "webp", "ico", "icns", "pdf", "zip", "gz", "tar", "tgz", "xz", "dmg",
  "mp3", "mp4", "mov", "woff", "woff2", "ttf", "otf", "lock", "swp", "swo",
}) do
  skipped_extensions[extension] = true
end

local skipped_names = {
  [".DS_Store"] = true,
  ["lazy-lock.json"] = true,
  ["package-lock.json"] = true,
  ["pnpm-lock.yaml"] = true,
}

local skipped = function(name)
  return skipped_names[name] or skipped_extensions[(name:match("%.([^.]+)$") or ""):lower()]
end

local sort_key = function(name)
  return (name:lower():gsub("%d+", function(digits)
    return ("0"):rep(math.max(0, 20 - #digits)) .. digits
  end))
end

local before = function(a, b)
  local key_a, key_b = sort_key(a), sort_key(b)
  if key_a ~= key_b then
    return key_a < key_b
  end
  return a < b
end

M.listed = function(names, current, ignored)
  local kept = vim.tbl_filter(function(name)
    return name == current or not (skipped(name) or ignored[name])
  end, names)
  table.sort(kept, before)
  return kept
end

M.target = function(names, current, offset)
  local index = vim.fn.index(names, current) + 1
  if index == 0 then
    local preceding = #vim.tbl_filter(function(name)
      return before(name, current)
    end, names)
    index = offset > 0 and preceding or preceding + 1
  end
  return math.min(math.max(index + offset, 1), #names)
end

return M
