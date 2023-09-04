local builtin = {}

function builtin.filename()
  if vim.bo.buftype == "help" then return "Help" end
  if vim.bo.buftype == "quickfix" then return "Quickfix" end
  local name = vim.api.nvim_buf_get_name(0) or ""
  if name:len() == 0 then return "[No Name]" end
  return vim.fn.fnamemodify(name, ":~:.")
end

function builtin.compress_filename(filename, max_width)
  if filename:len() == 0 or max_width <= 0 then return end
  return vim.fn.fnamemodify(filename, ":t")
end

function builtin.filename_suffix()
  if vim.bo.modified then
    return "[+]"
  elseif vim.bo.readonly then
    return "[~]"
  end
  return ""
end

function builtin.tabcount()
  local tabs = #vim.api.nvim_list_tabpages()
  if tabs > 1 then
    return "Tab [" .. vim.api.nvim_tabpage_get_number(0) .. "/" .. tabs .. "]"
  end
  return ""
end

function builtin.diagnostic_info()
  local n = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.INFO,
  })
  return n > 0 and ("I: %d"):format(n) or ""
end

function builtin.diagnostic_hint()
  local n = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.HINT,
  })
  return n > 0 and ("H: %d"):format(n) or ""
end

function builtin.diagnostic_warn()
  local n = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.WARN,
  })
  return n > 0 and ("W: %d"):format(n) or ""
end

function builtin.diagnostic_error()
  local n = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.ERROR,
  })
  return n > 0 and ("E: %d"):format(n) or ""
end

function builtin.lsp_progress()
  return require("tabline.builtin.lsp.progress").get_progress_message()
end

function builtin.compress_lsp_progress(...)
  return require("tabline.builtin.lsp.progress").compress_progress_message(
    ...
  )
end

function builtin.gitsigns_status()
  return require("tabline.builtin.gitsigns").status()
end

function builtin.gitsigns_branch()
  return require("tabline.builtin.gitsigns").branch()
end

return builtin
