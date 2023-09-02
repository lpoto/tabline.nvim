local config = require("tabline.config")
local enum = require("tabline.enum")

local state = {}

state.error = nil
state.cur_tabline = ""

local error

function state.draw()
  if state.error ~= nil then return vim.api.nvim_buf_get_name(0) end

  if not state.check_buftype() then return state.cur_tabline end
  if not state.check_wintype() then return state.cur_tabline end

  local sections = config.current.sections
  if type(sections) ~= "table" then
    return error("Sections must be a table")
  end

  if state.error ~= nil then return vim.api.nvim_buf_get_name(0) end
  local s = ""
  local ok, e = pcall(function()
    local section_count = #sections
    local columns = vim.api.nvim_get_option("columns")
    for i, section_items in ipairs(sections) do
      if type(section_items) ~= "table" then
        return error("Invalid sections: " .. vim.inspect(section_items))
      end
      local width = 0
      if i == 1 then
        width = math.ceil(columns / section_count)
      else
        width = math.floor(columns / section_count)
      end
      local parts = {}
      for _, item in ipairs(section_items) do
        if type(item) ~= "table" then
          return error("Invalid section item: " .. vim.inspect(item))
        end
        local align = item.align or enum.ALIGN.LEFT
        if
          align ~= enum.ALIGN.LEFT
          and align ~= enum.ALIGN.CENTER
          and align ~= enum.ALIGN.RIGHT
        then
          return error("Invalid align: " .. vim.inspect(align))
        end
        local highlight = item.highlight or enum.DEFAULT_HIGHLIGHT
        if type(highlight) ~= "string" then
          return error("Invalid highlight: " .. vim.inspect(highlight))
        end
        ---@type any
        local content = item.content
        if type(item.content) == "function" then content = item.content() end
        if type(content) ~= "string" then content = vim.inspect(content) end
        if parts[align] == nil then parts[align] = {} end
        table.insert(parts[align], {
          content = content,
          highlight = item.highlight or enum.DEFAULT_HIGHLIGHT,
        })
      end
      local str_parts = {}
      for _, v in pairs(enum.ALIGN or {}) do
        str_parts[v] = ""
        if width > 2 then
          for _, v2 in ipairs(parts[v] or {}) do
            local c = v2.content
            if c:len() > 0 then
              local n = vim.fn.strchars(c)
              if n < width + 2 then
                c = vim.fn.strcharpart(c, 0, width - 2)
              end
              c = "%#" .. v2.highlight .. "#" .. c .. "%#" .. "Normal" .. "#"
              str_parts[v] = str_parts[v] .. " " .. c .. " "
              width = width - n - 2
              if width <= 2 then break end
            end
          end
        end
      end
      s = s .. (str_parts["left"] or "")
      local n1 = math.floor(width / 2)
      if n1 > 0 then
        s = s .. string.rep(" ", n1)
        width = width - n1
      end
      s = s .. (str_parts["center"] or "")
      if width > 0 then
        s = s .. string.rep(" ", width)
        width = 0
      end
      s = s .. (str_parts["right"] or "")
    end
  end)
  if not ok then return error(e) end
  state.cur_tabline = s
  return s
end

function state.check_buftype()
  if vim.bo.buftype == "prompt" or vim.bo.buftype == "nofile" then
    return false
  end
  return true
end

function state.check_wintype()
  if
    not vim.tbl_contains({ "", "quickfix", "loclist" }, vim.fn.win_gettype())
  then
    return false
  end
  return true
end

function error(msg)
  msg = "Error drawing tabline: " .. vim.inspect(msg)
  state.error = msg
  vim.notify(msg, vim.log.levels.ERROR, { title = enum.TITLE })
  return vim.api.nvim_buf_get_name(0)
end
return state
