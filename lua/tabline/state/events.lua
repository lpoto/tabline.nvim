local enum = require 'tabline.enum'
local state = require 'tabline.state'

local M = {}

local error, get_callback

--- Redraw tabline on additional events, provided to this function.
--- NOTE: This is called from setup, if redraw_events is provided.
function M.redraw_on(events)
  if events == nil then return end
  if type(events) ~= 'table' then
    return error 'redraw_events must be a list of strings'
  end
  if not next(events) then return end
  for _, v in ipairs(events) do
    if type(v) ~= 'string' then
      return error 'redraw_events must be a list of strings'
    end
  end
  local evts_with_patterns = {}
  local evts = {}
  for k, v in pairs(events) do
    if type(k) == 'number' then
      if type(v) ~= 'string' then
        return error 'redraw_events values must be strings'
      end
      table.insert(evts, v)
    elseif type(v) == 'string' then
      evts_with_patterns[k] = { v }
    elseif type(v) == 'table' then
      for _, pattern in ipairs(v) do
        if type(pattern) ~= 'string' then
          return error 'redraw_events values must be strings'
        end
      end
      evts_with_patterns[k] = v
    end
  end
  local group = vim.api.nvim_create_augroup(enum.AUGROUP, { clear = true })
  if #evts > 0 then
    vim.api.nvim_create_autocmd(evts, {
      group = group,
      callback = get_callback(group),
    })
  end
  for k, v in pairs(evts_with_patterns) do
    for _, pattern in ipairs(v) do
      vim.api.nvim_create_autocmd(k, {
        group = group,
        pattern = pattern,
        callback = get_callback(group),
      })
    end
  end
end

function get_callback(group)
  return function(opts)
    if
      opts.event == 'OptionSet'
      and (opts.match == 'tabline' or opts.match == 'showtabline')
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
end

function error(msg)
  vim.notify(msg, vim.log.levels.ERROR, {
    title = 'tabline.nvim',
  })
end

return M
