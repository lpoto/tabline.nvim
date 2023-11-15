local health = require 'tabline.health'

local M = {}

function M.get_option(name, opts)
  local ok, v = pcall(function()
    if type(opts) ~= 'table' then opts = {} end
    if type(name) ~= 'string' then return nil end
    if vim.api.nvim_get_option_value then
      return vim.api.nvim_get_option_value(name, opts)
    end
    if opts.buf then
      ---@diagnostic disable-next-line
      return vim.api.nvim_buf_get_option(opts.buf, name)
    end
    if opts.win then
      ---@diagnostic disable-next-line
      return vim.api.nvim_win_get_option(opts.win, name)
    end
    ---@diagnostic disable-next-line
    vim.api.nvim_get_option(name)
  end)
  if not ok then
    return health.show_error(v)
  end
  return v
end

function M.redraw_tabline()
  M.exec 'redrawtabline'
end

function M.exec(cmd)
  local ok, v = pcall(function()
    if vim.api.nvim_exec2 then
      return vim.api.nvim_exec2(cmd, {})
      ---@diagnostic disable-next-line
    elseif vim.api.nvim_exec then
      ---@diagnostic disable-next-line
      return vim.api.nvim_exec(cmd, false)
    else
      return vim.api.nvim_command(cmd)
    end
  end)
  if not ok then
    return health.show_error(v)
  end
  return v
end

return M
