local builtin = require 'tabline.builtin'
local enum = require 'tabline.enum'

return {
  hide_statusline = true,
  redraw_events = {},
  space = {
    char = '—',
    edge = '•',
    highlight = 'TablineFill',
  },
  sections = {
    {
      {
        align = enum.alignment.LEFT,
        highlight = 'TablineSel',
      },
      {
        align = enum.alignment.LEFT,
        highlight = 'Tabline',
        -- content returns the text to display in the tabline
        content = builtin.lsp_progress,
        -- compress is called when the text returned by content is
        -- too long to fit in the tabline and should be shortened
        compress = builtin.compress_lsp_progress, --
      },
    },
    {
      {
        align = enum.alignment.CENTER,
        content = '',
        -- empty_width determines the width of the section part
        -- when its content is empty, 0 by default
        empty_width = 6,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'TablineSel',
        content = builtin.filename,
        compress = builtin.compress_filename,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'TablineFill',
        content = builtin.filename_suffix,
        empty_width = 6,
      },
    },
    {
      {
        align = enum.alignment.CENTER,
        highlight = 'DiagnosticError',
        content = builtin.diagnostic_error,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'DiagnosticWarn',
        content = builtin.diagnostic_warn,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'DiagnosticInfo',
        content = builtin.diagnostic_info,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'DiagnosticHint',
        content = builtin.diagnostic_hint,
      },
      {
        align = enum.alignment.RIGHT,
        highlight = 'TablineFill',
        content = builtin.git_remote,
      },
      {
        align = enum.alignment.RIGHT,
        highlight = 'TablineSel',
        content = builtin.git_branch,
      },
    },
  },
}
