local Builder = require 'tabline.core.builder'
local health = require 'tabline.health'

local M = {}

function M.draw()
  local ok, v = pcall(function()
    if health.has_errors() then
      return vim.api.nvim_buf_get_name(0)
    end
    local builder = Builder:new()
    if not builder then return '' end
    return builder:build_tabline() or ''
  end)
  if not ok then
    health.show_error(v)
    return vim.api.nvim_buf_get_name(0)
  end
  return v
end

return M
