local util = require 'tabline.util'
local enum = require 'tabline.enum'
local config = require 'tabline.config'
local Section = require 'tabline.core.section'

---@class TablineBuilder
---@field buf number
local Builder = {}
Builder.__index = Builder

local helper = {}

---@return TablineBuilder?
function Builder:new()
  local buf = helper.get_buf()
  if not buf then
    return nil
  end
  return setmetatable({
    buf = buf,
  }, self)
end

function Builder:build_tabline()
  if not self.buf then return end
  local sections = helper.get_sections()
  if not sections or #sections == 0 then return end

  local max_width = util.get_option 'columns'
  if not max_width or max_width == 0 then return end
  local section_count = #sections
  if section_count == 0 then return end
  local section_width = math.floor(max_width / section_count)
  local section_width_c = math.ceil(max_width / section_count)
  if section_width <= 0 then return end

  local s = ''
  for i, section in ipairs(sections) do
    local width = 0
    if i == #sections then
      width = section_width_c
    else
      width = section_width
    end
    local str_parts = {}
    for _, item in ipairs(section:get_items()) do
      local part, w = str_parts[item.align], width
      part, w = self:__add_section_item_to_string(item, w, part)
      str_parts[item.align] = part
      width = w
    end
    local spacer_width = math.floor(width / 2)
    s = s .. (str_parts[enum.alignment.LEFT] or '')
    s = s .. helper.get_spacer(spacer_width)
    s = s .. (str_parts[enum.alignment.CENTER] or '')
    spacer_width = width - spacer_width
    s = s .. helper.get_spacer(spacer_width)
    s = s .. (str_parts[enum.alignment.RIGHT] or '')
  end
  return s
end

---@param width number
---@param s string|nil
---@param item SectionItem
function Builder:__add_section_item_to_string(item, width, s)
  if not s then s = '' end

  local edge       = ' '
  local edge2      = ' ' .. helper.get_edge()
  local edge_width = vim.fn.strcharlen(helper.get_edge(true)) + 2
  if not vim.endswith(s, edge2) then
    edge = helper.get_edge() .. ' '
    edge_width = 2 * (vim.fn.strcharlen(helper.get_edge(true)) + 1)
  end
  local c = item:get_content {
    buf = self.buf,
    width = width - edge_width,
  }
  local n = vim.fn.strcharlen(c)
  if n > width - edge_width then c, n = '', 0 end

  local content_is_empty = n == 0
  if content_is_empty then
    if item.empty_width ~= nil then
      n = math.min(item.empty_width, width)
      if n > 0 then
        c = helper.get_spacer(n)
      end
    end
  else
    c     = '%#' .. item.highlight .. '#' .. c .. '%#' .. 'TablineFill' .. '#'
    s     = s .. edge .. c .. edge2
    width = width - n - edge_width
  end
  return s, width
end

---@return Section[]
function helper.get_sections()
  if type(helper.__sections) == 'table' then return helper.__sections end
  if type(config) ~= 'table' or
    type(config.current) ~= 'table' or
    type(config.current.sections) ~= 'table' or
    #config.current.sections == 0 then
    error 'Sections must be a table'
  end
  local sections = {}
  for _, section_items in ipairs(config.current.sections) do
    local section = Section:new(section_items)
    table.insert(sections, section)
  end
  helper.__sections = sections
  return sections
end

function helper.get_spacer(w)
  if w <= 0 then return '' end
  local space = helper.__get_space_char()
  local highlight = helper.__get_space_highlight()
  local s = string.rep(space, w)
  return highlight .. s
end

function helper.get_edge(ignore_highlight)
  local s = helper.__get_space_edge()
  if not ignore_highlight then
    s = helper.__get_space_highlight() .. s
  end
  return s
end

function helper.get_buf()
  local buf = vim.api.nvim_get_current_buf()
  if helper.__validate_buf(buf) then
    helper.__buf = buf
    return helper.__buf
  end
  if helper.__validate_buf(helper.__buf) then
    return helper.__buf
  end
  return nil
end

function helper.__get_space_char()
  if helper.__space_char then return helper.__space_char end
  helper.__space_char = config.current.space.char or '—'
  return helper.__space_char
end

function helper.__get_space_edge()
  if helper.__space_edge then return helper.__space_edge end
  helper.__space_edge = config.current.space.edge or '•'
  return helper.__space_edge
end

function helper.__get_space_highlight()
  if helper.__space_highlight then return helper.__space_highlight end
  local highlight = config.current.space.highlight or 'TablineFill'
  helper.__space_highlight = '%#' .. highlight .. '#'
  return helper.__space_highlight
end

function helper.__validate_buf(buf)
  if type(buf) ~= 'number' or
    not vim.api.nvim_buf_is_valid(buf) or
    vim.tbl_contains(
      { nil, 'nofile', 'prompt' },
      util.get_option('buftype', { buf = buf }
      )
    ) then
    return false
  end
  local _, win = pcall(vim.fn.bufwinid, buf)
  if type(win) ~= 'number' or
    not vim.api.nvim_win_is_valid(win) or
    not vim.tbl_contains(
      { '', 'quickfix', 'loclist' },
      vim.fn.win_gettype(win)
    ) then
    return false
  end
  return true
end

return Builder
