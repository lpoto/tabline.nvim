local gitsigns = {}

function gitsigns.status()
  if
    type(vim.b.gitsigns_status) == "string"
    and vim.b.gitsigns_status:len() > 0
  then
    return vim.b.gitsigns_status
  end
  return "    "
end

function gitsigns.branch()
  local branch = type(vim.g.gitsigns_head) == "string" and vim.g.gitsigns_head
    or ""
  if branch == "" then return "" end
  return branch
end

return gitsigns
