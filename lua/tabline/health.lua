local enum = require 'tabline.enum'

local health = {}

function health.check()
  vim.health.start 'Tabline'
  local did_error = false
  if health.has_errors() then
    for _, err in pairs(health.__errors) do
      vim.health.error(err)
      did_error = true
    end
  end
  if not did_error then
    vim.health.ok ''
  end
end

function health.show_error(msg)
  local info = debug.getinfo(2, 'S')
  local from = ''
  if info then from = info.source:match 'lua/tabline/(.+).lua' end
  if type(from) == 'string' and from:len() > 0 then
    from = from:gsub('/', '.'):gsub('\\', '.'):gsub('%.init$', '')
  end
  if type(from) ~= 'string' or from:len() == 0 then
    from = info.name or 'unknown'
  end
  from = 'tabline.' .. from
  msg = '[' .. from .. '] ' .. msg
  if type(health.__errors) ~= 'table' then
    health.__errors = {}
  end
  health.__errors[from] = msg
  if health.__notified then return end
  health.__notified = true
  vim.notify(msg, vim.log.levels.WARN, { title = enum.TITLE })
end

function health.has_errors()
  return type(health.__errors) == 'table' and
    vim.tbl_count(health.__errors) > 0
end

return health
