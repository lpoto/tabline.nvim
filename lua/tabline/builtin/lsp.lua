local lsp = {}

local current_progress_message = nil
local progress_listener_set_up = false

local util = {}

function lsp.get_progress_message()
  if not progress_listener_set_up then util.__set_up_progress_listener() end
  if type(current_progress_message) == "table" then
    return "  " .. (current_progress_message.message or "")
  end
  return ""
end

function lsp.compress_progress_message()
  if not progress_listener_set_up then util.__set_up_progress_listener() end
  if type(current_progress_message) == "table" then
    return "  " .. (current_progress_message.compressed_message or "")
  end
  return ""
end

local last_redrawn = nil
function util.__set_up_progress_listener()
  progress_listener_set_up = true
  local handler = function(_, result, ctx)
    local client_id = ctx.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    local val = result.value
    local token = result.token

    local data = util.get_notif_data(client_id, token)

    if not val.kind then return end
    if val.kind == "begin" then
      data = util.add_notif_data(client_id, token, val)
      current_progress_message = {
        message = util.format_message(
          client.name,
          val.title,
          val.message,
          val.percentage
        ),
        compressed_message = util.format_compressed_message(
          client.name,
          val.percentage
        ),
        updated = vim.loop.now(),
      }
    elseif val.kind == "report" and data then
      current_progress_message = {
        message = util.format_message(
          client.name,
          data.title,
          val.message,
          val.percentage,
          data.state
        ),
        compressed_message = util.format_compressed_message(
          client.name,
          val.percentage,
          nil,
          data.state
        ),
        updated = vim.loop.now(),
      }
    elseif val.kind == "end" then
      util.remove_notif_data(client_id, token)
      last_redrawn = nil
      if not data then
        current_progress_message = nil
      else
        current_progress_message = {
          message = util.format_message(
            client.name,
            data.title,
            val.message or "Complete"
          ),
          compressed_message = util.format_compressed_message(
            client.name,
            val.percentage,
            "Complete"
          ),
          complete = true,
          updated = vim.loop.now(),
        }
        vim.defer_fn(function()
          if type(current_progress_message) == "table" then
            if
              not current_progress_message.updated
              or vim.loop.now() - current_progress_message.updated >= 4000
            then
              current_progress_message = nil
              vim.cmd("redrawtabline")
              last_redrawn = vim.loop.now()
            end
          end
        end, 5000)
      end
    end
    if last_redrawn ~= nil and vim.loop.now() - last_redrawn < 100 then
      return
    end
    last_redrawn = vim.loop.now()
    vim.cmd("redrawtabline")
  end
  local f = vim.lsp.handlers["$/progress"]
  vim.lsp.handlers["$/progress"] = function(...)
    if type(f) == "function" then f(...) end
    handler(...)
  end
end

local client_notifs = {}

function util.remove_notif_data(client_id, token)
  if client_notifs[client_id] then client_notifs[client_id][token] = nil end
end

function util.add_notif_data(client_id, token, val)
  if not client_notifs[client_id] then client_notifs[client_id] = {} end
  local d = client_notifs[client_id][token]
  if not d then
    d = {
      title = val.title,
      state = 1,
    }
    client_notifs[client_id][token] = d
  end
  return d
end

function util.get_notif_data(client_id, token)
  if not client_notifs[client_id] then return end

  local d = client_notifs[client_id][token]
  if not d then return end
  d.state = (d.state + 1)
  if d.state > #util.spinner_frames then d.state = 1 end
  return d
end

util.spinner_frames =
  { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

function util.format_title(title, client_name)
  return client_name .. ((#title > 0 and ": " .. title) or "")
end

function util.format_message(client_name, title, message, percentage, state)
  if type(title) ~= "string" then title = "" end
  if title:len() > 50 then title = "" end
  if type(percentage) == "number" then
    percentage = string.format("%3d", percentage) .. "%%  "
  else
    percentage = ""
  end
  if type(client_name) ~= "string" then client_name = "" end
  if type(message) ~= "string" then message = "" end
  if message:len() > 70 then message = "" end
  if message:len() + title:len() > 90 then title = "" end
  local s = util.format_title(title, client_name)
    .. " "
    .. percentage
    .. message
  if state then s = util.spinner_frames[state] .. " " .. s end
  return s
end

function util.format_compressed_message(
  client_name,
  percentage,
  message,
  state
)
  if type(client_name) ~= "string" then client_name = "" end
  if type(percentage) == "number" then
    percentage = string.format("%3d", percentage) .. "%%  "
  else
    percentage = ""
  end
  if type(message) ~= "string" then message = "" end
  if message:len() > 10 then message = "" end
  local s = util.format_title("", client_name) .. " " .. percentage .. message
  if state then s = util.spinner_frames[state] .. " " .. s end
  return s
end

return lsp
