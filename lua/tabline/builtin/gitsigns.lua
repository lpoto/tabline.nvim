local gitsigns = {}

function gitsigns.status(opts)
  local ok, status =
    pcall(vim.api.nvim_buf_get_var, opts.bufnr, "gitsigns_status")
  if ok and type(status) == "string" and status:len() > 0 then
    return status
  end
  return ""
end

function gitsigns.branch(_)
  local branch = type(vim.g.gitsigns_head) == "string" and vim.g.gitsigns_head
    or ""
  if branch == "" then return "" end
  return branch
end

return gitsigns
