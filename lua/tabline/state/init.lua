local util = require 'tabline.util'
local config = require 'tabline.config'
local enum = require 'tabline.enum'

local state = {}

state.error = nil
state.cur_tabline = ''

local error

local buf = nil

function state.draw()
  if state.error ~= nil or util.error then
    return vim.api.nvim_buf_get_name(0)
  end

  if state.check_buftype() and state.check_wintype() then
    buf = vim.api.nvim_get_current_buf()
  end
  if type(buf) ~= 'number' or not vim.api.nvim_buf_is_valid(buf) then
    return ''
  end

  local sections = config.current.sections
  if type(sections) ~= 'table' then
    return error 'Sections must be a table'
  end

  local s = ''
  local ok, e = pcall(function()
    local max_width = util.get_option 'columns'
    if not max_width then max_width = 80 end
    local section_count = #sections
    if section_count == 0 then return '' end
    local section_width = math.floor(max_width / section_count)
    if section_width <= 0 then return '' end

    for i, section_items in ipairs(sections) do
      if max_width <= 0 then break end
      if type(section_items) ~= 'table' then
        return error('Invalid sections: ' .. vim.inspect(section_items))
      end
      local width = 0
      if i == section_count then
        width = max_width
      else
        width = section_width
      end
      max_width = max_width - width
      local parts = {}
      for _, item in ipairs(section_items) do
        if type(item) ~= 'table' then
          return error('Invalid section item: ' .. vim.inspect(item))
        end
        local align = item.align or enum.ALIGN.LEFT
        if
          align ~= enum.ALIGN.LEFT
          and align ~= enum.ALIGN.CENTER
          and align ~= enum.ALIGN.RIGHT
        then
          return error('Invalid align: ' .. vim.inspect(align))
        end
        local highlight = item.highlight or enum.DEFAULT_HIGHLIGHT
        if type(highlight) ~= 'string' then
          return error('Invalid highlight: ' .. vim.inspect(highlight))
        end
        ---@type any
        local content = item.content
        if content == nil then content = '' end
        if type(item.content) == 'function' then
          ---@diagnostic disable-next-line
          content = item.content { buf = buf }
        end
        if type(content) ~= 'string' then content = vim.inspect(content) end
        if item.compress ~= nil and type(item.compress) ~= 'function' then
          return error('Invalid compress: ' .. vim.inspect(item.compress))
        end
        if parts[align] == nil then parts[align] = {} end
        local compact = item.compact
        if compact ~= true then compact = false end
        local empty_width = item.empty_width
        if type(empty_width) ~= 'number' or empty_width < 0 then
          empty_width = 0
        end
        table.insert(parts[align], {
          content = content,
          highlight = item.highlight or enum.DEFAULT_HIGHLIGHT,
          compress = item.compress,
          compact = compact,
          empty_width = empty_width,
        })
      end
      local str_parts = {}
      for _, v in pairs(enum.ALIGN or {}) do
        str_parts[v] = ''
        if width > 2 then
          for _, v2 in ipairs(parts[v] or {}) do
            local c = v2.content
            if c:len() > 0 then
              local n = vim.fn.strcharlen(c)
              if n > width - 2 then
                if v2.compress ~= nil then
                  c = v2.compress {
                    buf = buf,
                    content = c,
                    max_width = width - 2,
                  }
                  if type(c) == 'string' then n = vim.fn.strcharlen(c) end
                end
              end
              if type(c) == 'string' and n <= width - 2 then
                c = '%#'
                  .. v2.highlight
                  .. '#'
                  .. c
                  .. '%#'
                  .. 'Normal'
                  .. '#'
                local sep1, sep2 = '', ''
                local d = 0
                if not v2.compact and width - n - 2 >= 0 then
                  local edge = state.get_edge(true)
                  local edge_w = vim.fn.strcharlen(edge)
                  sep2 = state.get_edge()
                  d = edge_w
                  if not vim.endswith(str_parts[v], edge) then
                    sep1 = state.get_edge()
                    d = d + edge_w
                  end
                  if width - n - d + 2 >= 0 then
                    sep1 = sep1 .. ' '
                    sep2 = ' ' .. sep2
                    d = d + 2
                  end
                end
                str_parts[v] = str_parts[v] .. sep1 .. c .. sep2
                width = width - n - d
                if width <= 2 then break end
              end
            else
              if v2.empty_width ~= nil then
                local n = math.min(v2.empty_width, width)
                if n > 0 then
                  str_parts[v] = str_parts[v] .. state.get_spacer(n)
                  width = width - n
                end
              end
            end
          end
        end
      end
      s = s .. (str_parts['left'] or '')
      local n1 = math.floor(width / 2)
      s = s .. state.get_spacer(n1)
      width = width - n1
      s = s .. (str_parts['center'] or '')
      s = s .. state.get_spacer(width)
      s = s .. (str_parts['right'] or '')
    end
  end)
  if not ok then return error(e) end
  state.cur_tabline = s
  return s
end

function state.get_spacer(w)
  if w <= 0 then return '' end
  local space = config.current.space.char or '—'

  local highlight = config.current.space.highlight or 'TablineFill'
  local s = string.rep(space, w)
  s = '%#' .. highlight .. '#' .. s
  return s
end

function state.get_edge(ignore_highlight)
  local s = config.current.space.edge or '•'
  if not ignore_highlight then
    local highlight = config.current.space.highlight or 'TablineFill'
    s = '%#' .. highlight .. '#' .. s
  end
  return s
end

function state.check_buftype()
  if vim.bo.buftype == 'prompt' or vim.bo.buftype == 'nofile' then
    return false
  end
  return true
end

function state.check_wintype()
  if
    not vim.tbl_contains({ '', 'quickfix', 'loclist' }, vim.fn.win_gettype())
  then
    return false
  end
  return true
end

function error(msg)
  msg = 'Error drawing tabline: ' .. vim.inspect(msg)
  state.error = msg
  vim.notify(msg, vim.log.levels.ERROR, { title = enum.TITLE })
  return vim.api.nvim_buf_get_name(0)
end

return state
