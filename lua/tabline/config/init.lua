local enum = require 'tabline.enum'
local config = {}


config.current = require 'tabline.config.default'

function config.update(opts)
  if type(opts) ~= 'table' then opts = {} end
  if opts.space ~= nil then
    if type(opts.space) ~= 'table' then
      vim.notify(
        'Invalid space: ' .. vim.inspect(opts.space),
        vim.log.levels.WARN,
        {
          title = enum.TITLE,
        }
      )
      opts.space = nil
    else
      if
        opts.space.highlight ~= nil
        and type(opts.space.highlight) ~= 'string'
      then
        vim.notify(
          'Invalid space.highlight: ' .. vim.inspect(opts.space.highlight),
          vim.log.levels.WARN,
          {
            title = enum.TITLE,
          }
        )
        opts.space.highlight = nil
      end
      if
        opts.space.char ~= nil
        and (
          type(opts.space.char) ~= 'string'
          or vim.fn.strdisplaywidth(opts.space.char) ~= 1
        )
      then
        vim.notify(
          'Invalid space.char: ' .. vim.inspect(opts.space.highlight),
          vim.log.levels.WARN,
          {
            title = enum.TITLE,
          }
        )
        opts.space.char = nil
      end
      if
        opts.space.edge ~= nil
        and (
          type(opts.space.edge) ~= 'string'
          or vim.fn.strdisplaywidth(opts.space.edge) > 1
        )
      then
        vim.notify(
          'Invalid space.edge: ' .. vim.inspect(opts.space.highlight),
          vim.log.levels.WARN,
          {
            title = enum.TITLE,
          }
        )
        opts.space.edge = nil
      end
    end
  end
  config.current = vim.tbl_extend('force', config.current, opts)
end

return config
