local util = require 'tabline.util'

local builtin = {}

function builtin.filename(opts)
  if type(opts) ~= 'table' then opts = {} end
  local buf = opts.buf
  local buftype = util.get_option('buftype', { buf = buf })
  if buftype == 'help' then return 'Help' end
  if buftype == 'quickfix' then return 'Quickfix' end
  local name = vim.api.nvim_buf_get_name(buf) or ''
  if name:len() == 0 then return '[No Name]' end
  return vim.fn.fnamemodify(name, ':~:.')
end

function builtin.compress_filename(opts)
  if type(opts) ~= 'table' then opts = {} end
  local filename = opts.content
  local max_width = opts.max_width
  if filename:len() == 0 or max_width <= 0 then return end
  return vim.fn.fnamemodify(filename, ':t')
end

function builtin.filename_suffix(opts)
  if type(opts) ~= 'table' then opts = {} end
  if util.get_option('modified', { buf = opts.buf }) then
    return '[+]'
  elseif util.get_option('readonly', { buf = opts.buf }) then
    return '[~]'
  end
  return ''
end

function builtin.tabcount()
  local tabs = #vim.api.nvim_list_tabpages()
  if tabs > 1 then
    return 'Tab [' .. vim.api.nvim_tabpage_get_number(0) .. '/' .. tabs .. ']'
  end
  return ''
end

function builtin.diagnostic_info(opts)
  if type(opts) ~= 'table' then opts = {} end
  local n = #vim.diagnostic.get(opts.buf, {
    severity = vim.diagnostic.severity.INFO,
  })
  return n > 0 and ('I: %d'):format(n) or ''
end

function builtin.diagnostic_hint(opts)
  if type(opts) ~= 'table' then opts = {} end
  local n = #vim.diagnostic.get(opts.buf, {
    severity = vim.diagnostic.severity.HINT,
  })
  return n > 0 and ('H: %d'):format(n) or ''
end

function builtin.diagnostic_warn(opts)
  if type(opts) ~= 'table' then opts = {} end
  local n = #vim.diagnostic.get(opts.buf, {
    severity = vim.diagnostic.severity.WARN,
  })
  return n > 0 and ('W: %d'):format(n) or ''
end

function builtin.diagnostic_error(opts)
  if type(opts) ~= 'table' then opts = {} end
  local n = #vim.diagnostic.get(opts.buf, {
    severity = vim.diagnostic.severity.ERROR,
  })
  return n > 0 and ('E: %d'):format(n) or ''
end

function builtin.git_branch(_)
  local git = require 'tabline.state.git'
  local branch = git.branch()
  if type(branch) ~= 'string' then return '' end
  return branch
end

function builtin.git_remote(_)
  local git = require 'tabline.state.git'
  local remote = git.remote()
  if type(remote) ~= 'string' then return '' end
  return remote
end

function builtin.lsp_progress(_)
  local lsp = require 'tabline.state.lsp'
  local msg = lsp.get_progress_message()
  if type(msg) ~= 'string' then return '' end
  return msg
end

function builtin.compress_lsp_progress(opts)
  if type(opts) ~= 'table' then opts = {} end
  local lsp = require 'tabline.state.lsp'
  local msg = lsp.compress_progress_message(opts.max_width)
  if type(msg) ~= 'string' then return '' end
  return msg
end

return builtin
