local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local s = Helpers.saving(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local repo_with = function(marker)
  local repo = s.folder()
  child.fn.mkdir(repo .. "/.git/" .. marker, "p")
  return repo
end

local changed_in = function(folder, name)
  local path = s.file(folder, name or "note.txt")
  s.open(path)
  s.change()
  return path
end

T["auto saves a file when no rule turns it down"] = function()
  s.setup({ mode = "auto" })
  local path = s.changed_file()
  eq(s.status().saves, true)
  s.leave()
  eq(s.on_disk(path), { "changed" })
end

T["auto holds while the file's repository is in a rebase"] = function()
  s.setup({ mode = "auto" })
  local path = changed_in(repo_with("rebase-merge"))
  eq(s.status(), { mode = "auto", saves = false, reason = "a git rebase is in progress", pending = false })
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

T["auto holds during a merge in a linked worktree"] = function()
  s.setup({ mode = "auto" })
  local main = s.folder()
  child.fn.mkdir(main .. "/.git/worktrees/linked", "p")
  child.fn.writefile({}, main .. "/.git/worktrees/linked/MERGE_HEAD")
  local linked = s.folder()
  child.fn.writefile({ "gitdir: " .. main .. "/.git/worktrees/linked" }, linked .. "/.git")
  local path = changed_in(linked)
  eq(s.status().reason, "a git merge is in progress")
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

T["auto holds a buffer that has conflict markers"] = function()
  s.setup({ mode = "auto" })
  local path = s.file(s.folder(), "note.txt")
  s.open(path)
  s.change({ "<<<<<<< ours", "a", "=======", "b", ">>>>>>> theirs" })
  eq(s.status().reason, "the buffer has conflict markers")
  s.leave()
  eq(s.on_disk(path), { "on disk" })
end

T["auto holds a file under a path in paths.off"] = function()
  local folder = s.folder()
  s.setup({ mode = "auto", paths = { off = { folder .. "/config/**" } } })
  child.fn.mkdir(folder .. "/config", "p")
  local held = changed_in(folder .. "/config")
  s.leave()
  local saved = changed_in(folder)
  s.leave()
  eq({ s.on_disk(held), s.on_disk(saved) }, { { "on disk" }, { "changed" } })
end

T["auto saves only under paths.on once any is listed"] = function()
  local folder = s.folder()
  s.setup({ mode = "auto", paths = { on = { folder .. "/notes/**" } } })
  child.fn.mkdir(folder .. "/notes", "p")
  local saved = changed_in(folder .. "/notes")
  s.leave()
  local held = changed_in(folder)
  eq(s.status().reason, "the file is outside paths.on")
  s.leave()
  eq({ s.on_disk(saved), s.on_disk(held) }, { { "changed" }, { "on disk" } })
end

T["when decides before every other rule"] = function()
  child.lua([[
    require("pantry").setup({
      autosave = {
        mode = "auto",
        when = function(buf)
          if vim.api.nvim_buf_get_name(buf):find("always", 1, true) then
            return true
          end
        end,
      },
    })
  ]])
  local repo = repo_with("rebase-merge")
  local forced = changed_in(repo, "always.txt")
  s.leave()
  local held = changed_in(repo, "other.txt")
  s.leave()
  eq({ s.on_disk(forced), s.on_disk(held) }, { { "changed" }, { "on disk" } })
end

T["mode = 'on' saves during a rebase, since the rules belong to auto"] = function()
  s.setup({ mode = "on" })
  local path = changed_in(repo_with("rebase-merge"))
  s.leave()
  eq(s.on_disk(path), { "changed" })
end

return T
