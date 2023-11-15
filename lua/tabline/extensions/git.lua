local util = require 'tabline.util'
local enum = require 'tabline.enum'
local health = require 'tabline.health'
---@type table
local uv = vim.uv or vim.loop

local M = {}
local data = {}

local watch, fetch_data, fetch_gitdir, redrawtabline

--- Starts the git watcher. This will create an autocommand
--- that will watch for directory changes, and will create
--- a watcher on the git directory in the current directory.
--- On HEAD changes in the git directory, the watcher will
--- refetch the git data and trigger a redraw of the tabline.
function M.watch()
  data.__initialized = true
  local ok, e = pcall(function()
    local group = vim.api.nvim_create_augroup(
      enum.AUGROUP .. '_GitWatcher',
      { clear = true })
    vim.api.nvim_create_autocmd('DirChanged', {
      group = group,
      callback = function()
        fetch_gitdir(function(git_dir)
          watch(git_dir)
        end)
      end,
    })
    vim.api.nvim_exec_autocmds('DirChanged', {
      group = group
    })
  end)
  if not ok then
    health.show_error(e)
  end
end

--- Returns the current git remote name.
--- This will return nil if the current directory is not a git repository,
--- or the data has not yet been fetched.
--- If the data has not yet been fetched, this will start
--- the watcher.
--- @return string|nil
function M.remote()
  if not data.__initialized then M.watch() end
  return data.remote
end

--- Returns the current git branch name.
--- This will return nil if the current directory is not a git repository,
--- or the data has not yet been fetched.
--- If the data has not yet been fetched, this will start
--- the watcher.
--- @return string|nil
function M.branch()
  if not data.__initialized then M.watch() end
  return data.branch
end

function watch(gitdir)
  if data.__watcher ~= nil then
    pcall(uv.fs_event_stop, data.watcher)
    data.__watcher = nil
  end
  if type(gitdir) ~= 'string' or gitdir == '' then
    return
  end
  local ok, e = pcall(uv.new_fs_event)
  if not ok then
    return health.show_error(e)
  end
  data.watcher = e
  if not data.watcher or not data.watcher.start then
    return health.show_error 'Failed to create fs event'
  end
  data.watcher:start(gitdir, {}, function(err, filename, _)
    vim.schedule(function()
      ok, e = pcall(function()
        if health.has_errors() then
          pcall(uv.fs_event_stop, data.watcher)
          return
        end
        if err then error(err) end
        if type(filename) ~= 'string' or
          not filename:lower():match 'head' then
          return
        end
        data.__needs_refetch = true
        vim.defer_fn(function()
          fetch_data()
        end, 10)
      end)
      if not ok then
        pcall(uv.fs_event_stop, data.watcher)
        health.show_error(e)
      end
    end)
  end)
  data.__needs_refetch = true
  vim.defer_fn(function()
    fetch_data()
  end, 10)
end

function fetch_data()
  if not data.__needs_refetch or health.has_errors() then
    return
  end
  data.__needs_refetch = false
  local remote, branch = nil, nil

  vim.fn.jobstart('git remote show', {
    detach = false,
    on_stdout = function(_, d)
      for _, v in ipairs(d) do
        if type(v) == 'string' and v:len() > 0 then remote = v end
      end
    end,
    on_exit = function()
      vim.fn.jobstart('git branch --show-current', {
        detach = false,
        on_stdout = function(_, d)
          for _, v in ipairs(d) do
            if type(v) == 'string' and v:len() > 0 then branch = v end
          end
        end,
        on_exit = function()
          if remote == data.remote and branch == data.branch then
            return
          end
          data.remote = remote
          data.branch = branch
          data.__needs_redraw = true
          vim.defer_fn(function()
            redrawtabline()
          end, 10)
        end,
      })
    end,
  })
  vim.defer_fn(function()
    redrawtabline()
  end, 10)
end

function redrawtabline()
  if not data.__needs_redraw or health.has_errors() then
    return
  end
  data.__needs_redraw = false
  util.redraw_tabline()
end

function fetch_gitdir(callback)
  if type(callback) ~= 'function' then return end
  local git_dir = nil
  vim.fn.jobstart('git rev-parse --git-dir', {
    detach = false,
    on_stdout = function(_, d, _)
      for _, v in ipairs(d) do
        if type(v) == 'string' and v ~= '' and vim.fn.isdirectory(v) == 1 then
          git_dir = v
          break
        end
      end
    end,
    on_exit = function()
      callback(git_dir)
    end,
  })
end

return M
