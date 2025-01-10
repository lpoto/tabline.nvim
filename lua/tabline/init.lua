local config = require("tabline.config")
local health = require("tabline.health")

local M = {}
local hide_statusline

--- Setup the tabline. The tabline will be always visible.
--- It will be configured with the opts.sections from
--- the provided opts.
function M.setup(opts)
  if not config.has_valid_version() then
    health.show_error(
      "tabline.nvim requires version "
        .. config.get_min_version_string()
        .. " or higher!"
    )
    return
  end

  config.update(opts)

  vim.opt.showtabline = 2
  vim.o.tabline = "%{%v:lua.require('tabline.core').draw()%}"
  if config.current.hide_statusline == true then
    hide_statusline()
  end
end

--- Hide the statusline completely.
--- This is useful when you want to use the tabline
--- to display all the needed information.
--- NOTE: This is called from setup, if hide_statusline is true.
function hide_statusline()
  vim.o.laststatus = 0
  -- NOTE: in normal splits, statusline is still visible
  -- even when laststatus=0, so we make it appear the same
  -- as the window separator.
  vim.opt.statusline =
    "%#WinSeparator#%{%v:lua.string.rep('—', v:lua.vim.fn.winwidth(0))%}"
end

return M
