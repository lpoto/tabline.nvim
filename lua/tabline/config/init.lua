local enum = require 'tabline.enum'
local config = {}


config.current = require 'tabline.config.default'

local validator = {}

function config.update(opts)
  if type(opts) ~= 'table' then opts = {} end
  local ok, e = pcall(validator.validate_config, opts)
  if not ok then
    vim.notify(
      'Invalid config: ' .. vim.inspect(e),
      vim.log.levels.WARN, { title = enum.TITLE }
    )
    return
  end
  config.current = vim.tbl_extend('force', config.current, opts)
end

function validator.validate_config(opts)
  assert(type(opts) == 'table', 'Invalid config: ' .. vim.inspect(opts))
  assert(
    not opts.hide_statusline or
    type(opts.hide_statusline) == 'boolean',
    'Invalid hide_statusline: ' .. vim.inspect(opts.hide_statusline))
  validator.validate_space_config(opts.space)
  validator.validate_sections(opts.sections)
end

function validator.validate_space_config(space)
  if not space then return end
  assert(type(space) == 'table', 'Invalid space config: ' .. vim.inspect(space))
  assert(
    not space.highlight or type(space.highlight) == 'string',
    'Invalid space.highlight: ' .. vim.inspect(space.highlight)
  )
  assert(
    not space.char or (
      type(space.char) == 'string'
      and vim.fn.strdisplaywidth(space.char) <= 1
    ),
    'Invalid space.char: ' .. vim.inspect(space.char)
  )
  if space.char == '' then space.char = ' ' end
  assert(
    not space.edge or (
      type(space.edge) == 'string'
      and vim.fn.strdisplaywidth(space.edge) <= 1
    ),
    'Invalid space.edge: ' .. vim.inspect(space.edge)
  )
end

function validator.validate_sections(sections)
  if not sections then return end
  assert(type(sections) == 'table', 'Invalid sections: ' .. vim.inspect(sections))
  for _, section in ipairs(sections) do
    assert(type(section) == 'table', 'Invalid section: ' .. vim.inspect(section))
  end
end

return config
