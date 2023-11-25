local util = require 'tabline.util'

local builtin = {}

function builtin.tabcount()
  local tabs = #vim.api.nvim_list_tabpages()
  if tabs > 1 then
    local s = 'Tab [' .. vim.api.nvim_tabpage_get_number(0) .. '/' .. tabs .. ']'
    return s
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

function builtin.git_branch()
  local git = require 'tabline.extensions.git'
  local branch = git.branch()
  if type(branch) ~= 'string' then return '' end
  return branch
end

function builtin.git_remote()
  local git = require 'tabline.extensions.git'
  local remote = git.remote()
  if type(remote) ~= 'string' then return '' end
  return remote
end

function builtin.lsp_progress(opts)
  if type(opts) ~= 'table' then opts = {} end
  if type(opts.width) ~= 'number' then return '' end
  local lsp = require 'tabline.extensions.lsp'
  local msg = lsp.get_progress_message(opts.width)
  if type(msg) ~= 'string' then return '' end
  return msg
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

function builtin.filename(opts)
  if type(opts) ~= 'table' then opts = {} end
  local get_filename = function()
    if type(opts) ~= 'table' then opts = {} end
    local buf = opts.buf
    local buftype = util.get_option('buftype', { buf = buf })
    if buftype == 'help' then return 'Help' end
    if buftype == 'quickfix' then return 'Quickfix' end
    local name = vim.api.nvim_buf_get_name(buf) or ''
    if name:len() == 0 then return '[No Name]' end
    return vim.fn.fnamemodify(name, ':~:.')
  end
  local filename = get_filename()
  if type(filename) ~= 'string' or filename:len() == 0 then
    return ''
  end
  local max_width = opts.width
  if type(max_width) ~= 'number' or max_width <= 0 then
    return ''
  end
  local n = vim.fn.strcharlen(filename)
  if max_width >= n then
    return filename
  elseif filename == '[No Name]' then
    return filename
  end
  local ok, v = pcall(function()
    local tail = vim.fn.fnamemodify(filename, ':t')
    if max_width >= filename:len() then return filename end
    while max_width < filename:len() and filename:len() > tail:len() do
      local c = nil
      while c ~= '/' and c ~= '\\' and filename:len() > tail:len() do
        c = filename:sub(1, 1)
        filename = filename:sub(2)
      end
    end
    if vim.fn.strcharlen(filename) > max_width then
      local extension = vim.fn.fnamemodify(filename, ':e')
      if vim.fn.strcharlen(extension) > max_width then
        return ''
      end
      return extension
    end
    return filename
  end)
  if not ok then return '' end
  return v
end

return builtin
