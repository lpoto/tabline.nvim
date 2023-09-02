local gitsigns = {}

function gitsigns.status()
  local n = 10
  if
    type(vim.b.gitsigns_status) == "string"
    and vim.b.gitsigns_status:len() > 0
  then
    n = n - vim.fn.strcharlen(vim.b.gitsigns_status)
    local s = vim.b.gitsigns_status
    if n > 0 then
      local n1 = math.floor(n / 2)
      if n1 > 0 then
        s = string.rep(" ", n1) .. s
        n = n - n1
      end
      s = s .. string.rep(" ", n)
    end
    return s
  end
  return string.rep(" ", n)
end

function gitsigns.branch()
  local branch = type(vim.g.gitsigns_head) == "string" and vim.g.gitsigns_head
    or ""
  if branch == "" then return "" end
  return branch
end

return gitsigns
