local state = require 'tabline.state'
local util = require 'tabline.util'
local git = require 'tabline.state.git'
local lsp = require 'tabline.state.lsp'

local health = {}

function health.check()
  vim.health.start 'Tabline'
  local did_error = false
  if state.error ~= nil then
    did_error = true
    vim.health.error(state.error)
  end
  if git.error ~= nil then
    did_error = true
    vim.health.error(git.error)
  end
  if util.error ~= nil then
    did_error = true
    vim.health.error(util.error)
  end
  if lsp.error ~= nil then
    did_error = true
    vim.health.error(lsp.error)
  end
  if not did_error then
    vim.health.ok ''
  end
end

return health
