local util = require 'tabline.util'
local enum = require 'tabline.enum'
---@type table
local uv = vim.uv or vim.loop

local lsp = {}

local do_error

---@class LspProgressMessage
---@field name string?
---@field title string?
---@field message string?
---@field percentage number?
---@field kind table|string
local LspProgressMessage = {
  ---@type LspProgressMessage
  kind = {
    BEGIN = 'begin',
    REPORT = 'report',
    END = 'end',
  },
}

function lsp.get_progress_message()
  return lsp.compress_progress_message(200)
end

function lsp.compress_progress_message(width)
  if lsp.error then return end
  local ok, v = pcall(function()
    LspProgressMessage:set_up()
    if type(LspProgressMessage.current_message) == 'table' then
      return LspProgressMessage.current_message:format(width)
    end
  end)
  if not ok then
    return do_error(v)
  end
  return v
end

local notifications = {}

function LspProgressMessage:set_up()
  if lsp.error then return end
  local did_set_up, err = pcall(function()
    if LspProgressMessage.is_set_up then return end
    LspProgressMessage.is_set_up = true
    local handler = function(_, result, ctx)
      if lsp.error then return end
      local client_id = ctx.client_id
      local ok, client = pcall(vim.lsp.get_client_by_id, client_id)
      local client_name = client_id
      if ok and type(client) == 'table' and client.name then
        client_name = client.name
      end

      local val = result.value
      local token = result.token

      local data = notifications.get_data(client_id, token)
      if not val.kind then return end
      if val.kind == LspProgressMessage.kind.BEGIN then
        data = notifications.add_data(client_id, token, val)
        LspProgressMessage.current_message = LspProgressMessage:new {
          name = client_name,
          title = val.title,
          message = val.message,
          percentage = val.percentage,
          kind = val.kind,
          updated = uv.now(),
        }
      elseif val.kind == LspProgressMessage.kind.REPORT and data then
        LspProgressMessage.current_message = LspProgressMessage:new {
          name = client_name,
          title = val.title or data.title,
          message = val.message,
          percentage = val.percentage,
          kind = val.kind,
          updated = uv.now(),
        }
      elseif val.kind == LspProgressMessage.kind.END then
        notifications.remove_data(client_id, token)
        if not data then
          LspProgressMessage.current_message = nil
        else
          LspProgressMessage.current_message = LspProgressMessage:new {
            name = client_name,
            title = val.title or data.title,
            message = val.message or 'Done',
            percentage = val.percentage,
            kind = val.kind,
            updated = uv.now(),
          }
          LspProgressMessage:schedule_deletion()
        end
      end
      LspProgressMessage:redraw()
    end
    local messages_handler = function(opts)
      if lsp.error then return end
      if type(opts) ~= 'table' then return end
      local title = opts.title
      if type(title) ~= 'string' then title = '' end
      local message = opts.message
      if type(message) ~= 'string' or message:len() == 0 then return end

      LspProgressMessage.current_message = LspProgressMessage:new {
        name = title,
        message = message,
        kind = LspProgressMessage.kind.END,
        updated = uv.now(),
      }
      LspProgressMessage:schedule_deletion(2500)
      LspProgressMessage:redraw()
    end

    local f = vim.lsp.handlers['$/progress']
    ---@diagnostic disable-next-line
    vim.lsp.handlers['$/progress'] = function(...)
      if type(f) == 'function' then f(...) end
      handler(...)
    end
    local f2 = vim.g.display_message
    if f2 ~= nil and type(f2) ~= 'function' then return end
    ---@diagnostic disable-next-line
    vim.g.display_message = function(...)
      if type(f2) == 'function' then f2(...) end
      messages_handler(...)
    end
  end)
  if not did_set_up then
    return do_error(err)
  end
  return err
end

function LspProgressMessage:new(o)
  setmetatable(o or {}, self)
  self.__index = self
  return o
end

function LspProgressMessage:schedule_deletion(delay)
  local ok, err = pcall(function()
    if type(delay) ~= 'number' or delay < 0 then delay = 5000 end
    if type(LspProgressMessage.deletion_schedule) == 'number' then
      if
        LspProgressMessage.deletion_schedule > uv.now() + delay - 500
      then
        return
      end
    end
    LspProgressMessage.deletion_schedule = uv.now() + delay
    vim.defer_fn(function()
      local ok, err = pcall(function()
        LspProgressMessage.deletion_schedule = nil
        if type(LspProgressMessage.current_message) ~= 'table' then return end
        if
          type(LspProgressMessage.current_message.updated) ~= 'number'
          or uv.now() - LspProgressMessage.current_message.updated
          >= delay - 1000
        then
          LspProgressMessage.current_message = nil
          LspProgressMessage:redraw()
        end
      end)
      if not ok then
        return do_error(err)
      end
    end, delay)
  end)
  if not ok then
    return do_error(err)
  end
end

function LspProgressMessage:redraw()
  LspProgressMessage.__needs_redraw = true
  if LspProgressMessage.__is_redrawing then return end
  LspProgressMessage.__is_redrawing = true
  vim.defer_fn(function()
    local ok, err = pcall(function()
      if not LspProgressMessage.__needs_redraw then return end
      LspProgressMessage.__needs_redraw = false
      LspProgressMessage.__is_redrawing = false
      util.redraw_tabline()
    end)
    if not ok then
      return do_error(err)
    end
  end, 100)
end

function LspProgressMessage:format(max_width)
  local ok, e = pcall(function()
    if type(max_width) ~= 'number' then return '' end
    local s = ''
    if type(self.name) == 'string' then
      local n = vim.fn.strdisplaywidth(self.name)
      if n > 0 and n <= max_width - 2 then
        s = '[' .. self.name .. ']'
        max_width = max_width - n - 2
      end
    end
    if max_width <= 1 then return s end
    local added_title = false
    if type(self.title) == 'string' then
      local n = vim.fn.strdisplaywidth(self.title)
      if n > 0 and n + 1 < max_width then
        s = s .. ' ' .. self.title
        added_title = true
        max_width = max_width - n - 1
      end
    end

    if type(self.percentage) == 'number' and max_width >= 5 then
      local s2 = string.format(' %3d', self.percentage) .. '٪'
      if added_title then
        s2 = ':' .. s2
        added_title = false
      end
      s = s .. s2
      max_width = max_width - vim.fn.strdisplaywidth(s2)
    end
    if type(self.message) == 'string' and max_width > 2 then
      local msg = self.message
        :gsub('\n', ' '):gsub('\r', ' '):gsub('\t', ' ')
        :gsub('%s+', ' '):gsub('%%', '٪')
      local n = vim.fn.strdisplaywidth(msg)
      if n > 0 and n < max_width - 1 then
        if added_title and n < max_width - 2 then
          s = s .. ':'
          added_title = false
          n = n + 1
        end
        s = s .. ' ' .. msg
        max_width = max_width - n - 1
      end
    end
    return s
  end)
  if not ok then
    return do_error(e)
  end
  return e
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

function do_error(msg)
  msg = '[tabline.state.lsp] Error: ' .. vim.inspect(msg)
  lsp.error = msg
  vim.notify(msg, vim.log.levels.WARN, { title = enum.TITLE })
end

return lsp
