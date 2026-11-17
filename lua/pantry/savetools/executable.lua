local M = {}

local any_execute_bit = 73

local starts_a_script = function(line)
  return line ~= nil and vim.startswith(line, "#!")
end

local first_line_on_disk = function(path)
  local file = io.open(path, "r")
  if not file then
    return
  end
  local line = file:read("*l")
  file:close()
  return line
end

local is_executable = function(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and bit.band(stat.mode, any_execute_bit) ~= 0
end

-- A bare name matches any folder of that name, and a path matches that folder and what its globs reach.
local listed = function(path, patterns)
  local folder = vim.fs.dirname(path)
  for _, pattern in ipairs(patterns or {}) do
    local whole = vim.fs.normalize(pattern)
    if not pattern:find("/", 1, true) then
      if vim.fs.basename(folder) == pattern then
        return pattern
      end
    elseif whole == folder or vim.glob.to_lpeg(whole):match(path) then
      return pattern
    end
  end
end

local other_scripts = function(path)
  local folder = vim.fs.dirname(path)
  local executable, plain = 0, 0
  for name, kind in vim.fs.dir(folder) do
    local other = vim.fs.joinpath(folder, name)
    if kind == "file" and other ~= path and starts_a_script(first_line_on_disk(other)) then
      if is_executable(other) then
        executable = executable + 1
      else
        plain = plain + 1
      end
    end
  end
  return executable, plain
end

local decide = function(path, rules)
  local folder = vim.fs.dirname(path)
  local name = vim.fs.basename(folder)
  if listed(path, rules.never) then
    return {}
  end
  local always = listed(path, rules.always)
  if always then
    return { make = true, reason = always .. " is in executable.always" }
  elseif vim.tbl_contains(vim.split(vim.env.PATH or "", ":"), folder) then
    return { make = true, reason = name .. " is on your PATH" }
  end
  local executable, plain = other_scripts(path)
  if executable > 0 and plain == 0 then
    return { make = true, reason = ("every other script in %s is"):format(name) }
  elseif executable + plain == 0 then
    return { reason = name .. " has no other script to go by" }
  end
  return {}
end

local decision_for = function(ctx)
  local first_line = vim.api.nvim_buf_get_lines(ctx.buf, 0, 1, false)[1]
  if ctx.existed or not starts_a_script(first_line) then
    return {}
  end
  return decide(ctx.path, ctx.config.executable)
end

M.after = function(ctx)
  local decision = decision_for(ctx)
  if decision.make then
    local stat = assert(vim.uv.fs_stat(ctx.path))
    -- Each execute bit follows its read bit, as chmod +x does under a common umask.
    local execute = bit.rshift(bit.band(stat.mode, 292), 2)
    vim.uv.fs_chmod(ctx.path, bit.bor(bit.band(stat.mode, 4095), execute))
    ctx.note(("made %s executable, because %s"):format(ctx.name, decision.reason))
  elseif decision.reason then
    ctx.note(("left %s as it is, because %s"):format(ctx.name, decision.reason))
  end
end

M.explain = function(ctx)
  local decision = decision_for(ctx)
  if decision.make then
    return ("It would make %s executable, because %s."):format(ctx.name, decision.reason)
  end
end

return M
