local disk = require("pantry.disk")

local M = {}

local config = { notify = true, executable = { always = { "bin" }, never = {} } }
local group = "pantry.savetools"
local tools = { "folders", "vanished", "typos", "executable", "filetype" }
local in_progress = {}

local note = function(text)
  if config.notify then
    vim.notify("savetools: " .. text, vim.log.levels.INFO)
  end
end

local warn = function(text)
  vim.notify("savetools: " .. text, vim.log.levels.WARN)
end

local context = function(buf, target)
  local path = vim.fn.fnamemodify(target, ":p")
  local buffer_name = vim.api.nvim_buf_get_name(buf)
  return {
    buf = buf,
    path = path,
    name = vim.fs.basename(path),
    buffer_name = buffer_name,
    own = path == buffer_name,
    bang = vim.v.cmdbang == 1,
    existed = vim.uv.fs_stat(path) ~= nil,
    config = config,
    note = note,
    warn = warn,
  }
end

local each_tool = function(step, ctx)
  local results = {}
  for _, name in ipairs(tools) do
    local tool = config[name] ~= false and require("pantry.savetools." .. name) or {}
    if tool[step] then
      results[#results + 1] = tool[step](ctx) or nil
    end
  end
  return results
end

local watch = function()
  local id = vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = id,
    callback = function(event)
      -- A sudo save writes a private copy first, and that copy is not a file to tend.
      if vim.b[event.buf].pantry_save ~= "sudo" then
        in_progress[event.buf] = context(event.buf, event.match)
        each_tool("before", in_progress[event.buf])
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = id,
    nested = true,
    callback = function(event)
      local ctx = in_progress[event.buf]
      in_progress[event.buf] = nil
      if ctx then
        each_tool("after", ctx)
      end
    end,
  })
end

M.plain = function()
  vim.b.pantry_save = "plain"
  local ok, err = pcall(vim.cmd, "write")
  vim.b.pantry_save = nil
  if not ok then
    warn(tostring(err))
  end
end

M.sudo = function()
  require("pantry.savetools.sudo").save(vim.api.nvim_get_current_buf(), note, warn)
end

M.explain = function()
  local buf = vim.api.nvim_get_current_buf()
  local ctx = context(buf, vim.api.nvim_buf_get_name(buf))
  local lines = {}
  if disk.state(buf) == "changed" then
    lines[#lines + 1] = ("%s changed on disk, so Neovim will ask before it overwrites that change."):format(ctx.name)
  elseif ctx.existed and not disk.writable(buf) then
    lines[#lines + 1] = ("You cannot write %s. sudo() can save it."):format(ctx.name)
  end
  vim.list_extend(lines, each_tool("explain", ctx))
  if #lines == 0 then
    lines = { ("Saving %s writes the file and does nothing else."):format(ctx.name) }
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  return lines
end

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  disk.watch()
  watch()
end

return M
