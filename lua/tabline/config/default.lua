local builtin = require 'tabline.builtin'
local enum = require 'tabline.enum'

return {
  hide_statusline = true,
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
        content = builtin.tabcount
      },
      {
        align = enum.alignment.LEFT,
        highlight = 'Tabline',
        content = builtin.lsp_progress,
      },
    },
    {
      {
        align = enum.alignment.CENTER,
        empty_width = 6,
      },
      {
        align = enum.alignment.CENTER,
        highlight = 'TablineSel',
        content = builtin.filename,
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
