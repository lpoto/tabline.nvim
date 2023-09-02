local lsp = {}

---@class LspProgressMessage
---@field name string?
---@field title string?
---@field message string?
---@field percentage number?
---@field state number?
---@field kind table|string
local LspProgressMessage = {
  spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
  ---@type LspProgressMessage
  kind = {
    BEGIN = "begin",
    REPORT = "report",
    END = "end",
  },
}

function lsp.get_progress_message()
  LspProgressMessage:set_up()
  if type(LspProgressMessage.current_message) == "table" then
    return LspProgressMessage.current_message:format()
  end
  return ""
end

function lsp.compress_progress_message(_, max_width)
  LspProgressMessage:set_up()
  if type(LspProgressMessage.current_message) == "table" then
    return LspProgressMessage.current_message:format(max_width)
  end
  return ""
end

local notifications = {}

function LspProgressMessage:set_up()
  if LspProgressMessage.is_set_up then return end
  LspProgressMessage.is_set_up = true
  local handler = function(_, result, ctx)
    local client_id = ctx.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    local val = result.value
    local token = result.token

    local data = notifications.get_data(client_id, token)
    LspProgressMessage:update_state()

    if not val.kind then return end
    if val.kind == LspProgressMessage.kind.BEGIN then
      data = notifications.add_data(client_id, token, val)
      LspProgressMessage.current_message = LspProgressMessage:new({
        name = client.name,
        title = val.title,
        message = val.message,
        percentage = val.percentage,
        kind = val.kind,
        updated = vim.loop.now(),
      })
    elseif val.kind == LspProgressMessage.kind.REPORT and data then
      LspProgressMessage.current_message = LspProgressMessage:new({
        name = client.name,
        title = val.title or data.title,
        message = val.message,
        percentage = val.percentage,
        kind = val.kind,
        updated = vim.loop.now(),
      })
    elseif val.kind == LspProgressMessage.kind.END then
      notifications.remove_data(client_id, token)
      if not data then
        LspProgressMessage.current_message = nil
      else
        LspProgressMessage.current_message = LspProgressMessage:new({
          name = client.name,
          title = val.title or data.title,
          message = val.message or "Done",
          percentage = val.percentage,
          kind = val.kind,
          updated = vim.loop.now(),
        })
        LspProgressMessage:schedule_deletion()
      end
    end
    LspProgressMessage:redraw()
  end
  local f = vim.lsp.handlers["$/progress"]
  vim.lsp.handlers["$/progress"] = function(...)
    if type(f) == "function" then f(...) end
    handler(...)
  end
end

function LspProgressMessage:new(o)
  setmetatable(o or {}, self)
  self.__index = self
  return o
end

function LspProgressMessage:schedule_deletion()
  LspProgressMessage.last_redrawn = nil
  vim.defer_fn(function()
    if type(LspProgressMessage.current_message) ~= "table" then return end
    if
      type(LspProgressMessage.current_message.updated) ~= "number"
      or vim.loop.now() - LspProgressMessage.current_message.updated >= 4000
    then
      LspProgressMessage.current_message = nil
      vim.cmd("redrawtabline")
      LspProgressMessage.last_redrawn = vim.loop.now()
    end
  end, 5000)
end

function LspProgressMessage:update_state()
  if LspProgressMessage.updating_state then
    LspProgressMessage.updating_state_idx = 1
    return
  end
  if
    type(LspProgressMessage.updating_state_idx) ~= "number"
    or LspProgressMessage.updating_state_idx == 0
  then
    LspProgressMessage.updating_state_idx = 0
  end
  if LspProgressMessage.updating_state_idx > 5 then
    LspProgressMessage.updating_state_idx = 0
    LspProgressMessage.state_updated = nil
    LspProgressMessage.state = nil
    vim.cmd("redrawtabline")
    return
  end
  LspProgressMessage.updating_state_idx = LspProgressMessage.updating_state_idx
    + 1
  LspProgressMessage.updating_state = true
  vim.defer_fn(function()
    if
      type(LspProgressMessage.state) ~= "number"
      or LspProgressMessage.state <= 0
    then
      LspProgressMessage.state = 1
    else
      LspProgressMessage.state = LspProgressMessage.state + 1
    end
    if LspProgressMessage.state > #LspProgressMessage.spinner_frames then
      LspProgressMessage.state = 1
    end
    LspProgressMessage.state_updated = vim.loop.now()
    LspProgressMessage.updating_state = false
    LspProgressMessage:update_state()
  end, 100)
end

function LspProgressMessage:redraw()
  if
    LspProgressMessage.last_redrawn ~= nil
    and vim.loop.now() - LspProgressMessage.last_redrawn < 50
  then
    return
  end
  LspProgressMessage.last_redrawn = vim.loop.now()
  vim.cmd("redrawtabline")
end

function LspProgressMessage:format(max_width)
  if type(max_width) ~= "number" then max_width = 200 end
  local s = ""
  if type(self.name) == "string" then
    local n = vim.fn.strcharlen(self.name)
    if n > 0 and n <= max_width - 2 then
      s = "[" .. self.name .. "]"
      max_width = max_width - vim.fn.strcharlen(s) - 2
    end
  end
  if max_width <= 1 then return s end
  local added_title = false
  if type(self.title) == "string" then
    local n = vim.fn.strcharlen(self.title)
    if n > 0 and n + 3 < max_width then
      local s2 = " " .. self.title
      s = s .. s2
      added_title = true
      max_width = max_width - vim.fn.strcharlen(s2)
    end
  end
  if
    type(LspProgressMessage.state) == "number"
    and LspProgressMessage.spinner_frames[LspProgressMessage.state]
  then
    local s2 = LspProgressMessage.spinner_frames[LspProgressMessage.state]
      .. " "
    s = s2 .. s
    max_width = max_width - vim.fn.strcharlen(s2)
  elseif max_width >= 2 then
    s = "  " .. s
  end

  if type(self.percentage) == "number" and max_width >= 5 then
    local s2 = string.format(" %3d", self.percentage) .. "%%"
    if added_title then
      s2 = ":" .. s2
      added_title = false
    end
    s = s .. s2
    max_width = max_width - vim.fn.strcharlen(s2)
  end
  if type(self.message) == "string" then
    local n = vim.fn.strcharlen(self.message)
    if n > 0 and n < max_width - 1 then
      if added_title then
        s = s .. ":"
        added_title = false
      end
      local s2 = " " .. self.message
      s = s .. s2
      max_width = max_width - vim.fn.strcharlen(s2)
    end
  end
  return s
end

notifications.data = {}

function notifications.remove_data(client_id, token)
  if notifications.data[client_id] then
    notifications.data[client_id][token] = nil
  end
end

function notifications.add_data(client_id, token, val)
  if not notifications.data[client_id] then
    notifications.data[client_id] = {}
  end
  local d = notifications.data[client_id][token]
  if not d then
    d = {
      title = val.title,
    }
    notifications.data[client_id][token] = d
  end
  return d
end

function notifications.get_data(client_id, token)
  if not notifications.data[client_id] then return end

  local d = notifications.data[client_id][token]
  if not d then return end
  return d
end

return lsp
