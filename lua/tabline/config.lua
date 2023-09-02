local builtin = require("tabline.builtin")
local enum = require("tabline.enum")

local config = {}

config.current = {
  hide_statusline = false,
  redraw_events = {},
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
        highlight = "Function",
        -- NOTE: an item's content may be a string or any function
        -- returning a string.
        content = builtin.tabcount,
      },
      {
        align = enum.ALIGN.LEFT,
        highlight = "Tabline",
        content = builtin.lsp.get_progress_message,
      },
    },
    {
      {
        align = enum.ALIGN.CENTER,
        content = "   ",
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = "Special",
        content = builtin.filename,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = "TablineFill",
        content = builtin.filename_suffix,
      },
    },
    {
      {
        align = enum.ALIGN.CENTER,
        highlight = "DiagnosticError",
        content = builtin.diagnostic_error,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = "DiagnosticWarn",
        content = builtin.diagnostic_warn,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = "DiagnosticInfo",
        content = builtin.diagnostic_info,
      },
      {
        align = enum.ALIGN.CENTER,
        highlight = "DiagnosticHint",
        content = builtin.diagnostic_hint,
      },
      -- NOTE: These two items will display nothing,
      -- unless gitsigns plugin is attached
      {
        align = enum.ALIGN.RIGHT,
        highlight = "TablineFill",
        content = builtin.gitsigns.status,
      },
      {
        align = enum.ALIGN.RIGHT,
        highlight = "Function",
        content = builtin.gitsigns.branch,
      },
    },
  },
}

function config.update(opts)
  if type(opts) ~= "table" then opts = {} end
  config.current = vim.tbl_extend("force", config.current, opts)
end

return config
