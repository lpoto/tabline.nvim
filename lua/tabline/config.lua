local builtin = require 'tabline.builtin'
local enum = require 'tabline.enum'

local config = {}

config.current = {
  hide_statusline = false,
  redraw_events = {},
  space = {
    char = '—',
    highlight = 'TablineFill',
    edge = '•',
  },
  -- NOTE: items displayed in the tabline are grouped
  -- in sections. Each sections receives equal space
  -- in the tabline.
  --
  -- Each section may contain 0 or more items,
  -- that are displayed in that section.
  sections = {
    {
      {
        -- NOTE: items in a section are displayed based on their alignment
        -- ("left", "center", "right")
        -- Items with same alignment, are displayed in the order they are
        -- defined.
        align = enum.ALIGN.LEFT,
        highlight = 'TablineSel',
        -- NOTE: an item's content may be a string or any function
        -- returning a string.
        content = builtin.tabcount,
      },
      {
        align = enum.ALIGN.LEFT,
        highlight = 'Tabline',
        content = builtin.lsp_progress,
        -- NOTE: a compress function(cur_value, max_width) -> string
        -- may be provided, in case the current value  cannot fit on the
        -- tabline. This function can shorten the string and make it fit.
        compress = builtin.compress_lsp_progress,
      },
    },
    {
      {
        align = enum.ALIGN.CENTER,
        content = '',
        empty_width = 6,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = 'TablineSel',
        content = builtin.filename,
        compress = builtin.compress_filename,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = 'TablineFill',
        content = builtin.filename_suffix,
        empty_width = 6,
      },
    },
    {
      {
        align = enum.ALIGN.CENTER,
        highlight = 'DiagnosticError',
        content = builtin.diagnostic_error,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = 'DiagnosticWarn',
        content = builtin.diagnostic_warn,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = 'DiagnosticInfo',
        content = builtin.diagnostic_info,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = 'DiagnosticHint',
        content = builtin.diagnostic_hint,
      },
      {
        align = enum.ALIGN.RIGHT,
        highlight = 'TablineFill',
        content = builtin.git_remote,
      },
      {
        align = enum.ALIGN.RIGHT,
        highlight = 'TablineSel',
        content = builtin.git_branch,
      },
    },
  },
}

function config.update(opts)
  if type(opts) ~= 'table' then opts = {} end
  if opts.space ~= nil then
    if type(opts.space) ~= 'table' then
      vim.notify(
        'Invalid space: ' .. vim.inspect(opts.space),
        vim.log.levels.ERROR,
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
          vim.log.levels.ERROR,
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
          or vim.fn.strcharlen(opts.space.char) ~= 1
        )
      then
        vim.notify(
          'Invalid space.char: ' .. vim.inspect(opts.space.highlight),
          vim.log.levels.ERROR,
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
          or vim.fn.strcharlen(opts.space.edge) > 1
        )
      then
        vim.notify(
          'Invalid space.edge: ' .. vim.inspect(opts.space.highlight),
          vim.log.levels.ERROR,
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
