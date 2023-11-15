local health = {}

local get_error
function health.check()
  vim.health.start 'Tabline'
  local did_error = false
  for _, m in ipairs {
    'tabline.state',
    'tabline.util',
    'tabline.state.git',
    'tabline.state.lsp',
  } do
    local err = get_error(m)
    if err then
      did_error = true
      vim.health.error(err)
    end
  end
  if not did_error then
    vim.health.ok ''
  end
end

function get_error(m)
  if type(m) ~= 'string' or not package.loaded[m] then return end
  local ok, mod = pcall(require, m)
  if not ok or type(mod) ~= 'table' or type(mod.error) ~= 'string' then return end
  return mod.error
end

return health
