local config = require("tabline.config")
local enum = require("tabline.enum")
local state = require("tabline.state")

local M = {}
--- Setup the tabline. The tabline will be always visible.
--- It will be configured with the opts.sections from
--- the provided opts.
function M.setup(opts)
  config.update(opts)

  vim.opt.showtabline = 2
  vim.o.tabline = "%{%v:lua.require('tabline.state').draw()%}"
  if config.current.hide_statusline == true then M.hide_statusline() end

  M.redraw_on_events(config.current.redraw_events)
end

--- Hide the statusline completely.
--- This is useful when you want to use the tabline
--- to display all the needed information.
--- NOTE: This is called from setup, if hide_statusline is true.
function M.hide_statusline()
  vim.o.laststatus = 0
  -- NOTE: in normal splits, statusline is still visible
  -- even when laststatus=0, so we make it appear the same
  -- as the window separator.
  vim.opt.statusline =
  "%#WinSeparator#%{%v:lua.string.rep('—', v:lua.vim.fn.winwidth(0))%}"
end

--- Redraw tabline on additional events, provided to this function.
--- NOTE: This is called from setup, if redraw_events is provided.
function M.redraw_on_events(events)
  local error = function(msg)
    vim.notify(msg, vim.log.levels.ERROR, {
      title = "tabline.nvim",
    })
  end
  if events == nil then return end
  if type(events) ~= "table" then
    return error("redraw_events must be a list of strings")
  end
  if not next(events) then return end
  for _, v in ipairs(events) do
    if type(v) ~= "string" then
      return error("redraw_events must be a list of strings")
    end
  end
  local evts_with_patterns = {}
  local evts = {}
  for k, v in pairs(events) do
    if type(k) == 'number' then
      if type(v) ~= "string" then
        return error("redraw_events values must be strings")
      end
      table.insert(evts, v)
    elseif type(v) == 'string' then
      evts_with_patterns[k] = { v }
    elseif type(v) == 'table' then
      for _, pattern in ipairs(v) do
        if type(pattern) ~= 'string' then
          return error("redraw_events values must be strings")
        end
      end
      evts_with_patterns[k] = v
    end
  end
  local group = vim.api.nvim_create_augroup(enum.AUGROUP, { clear = true })
  local cb = function(opts)
    if
        opts.event == "OptionSet"
        and (opts.match == "tabline" or opts.match == "showtabline")
    then
      return
    end
    vim.schedule(function()
      if state.error ~= nil then
        return pcall(vim.api.nvim_del_augroup_by_id, group)
      end
      pcall(vim.api.nvim_exec2, 'redrawtabline', {})
    end)
  end
  if #evts > 0 then
    vim.api.nvim_create_autocmd(evts, {
      group = group,
      callback = cb,
    })
  end
  for k, v in pairs(evts_with_patterns) do
    for _, pattern in ipairs(v) do
      vim.api.nvim_create_autocmd(k, {
        group = group,
        pattern = pattern,
        callback = cb,
      })
    end
  end
end

return M
