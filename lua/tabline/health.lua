local state = require("tabline.state")

local health = {}

function health.check()
  vim.health.start("Tabline")
  if state.error ~= nil then
    vim.health.error(state.error)
  else
    vim.health.ok("")
  end
end

return health
