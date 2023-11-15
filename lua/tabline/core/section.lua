local enum = require 'tabline.enum'

---@class Section
---@field items SectionItem
local Section = {}
Section.__index = Section

---@class SectionItem
---@field content string|function|number|boolean
---@field highlight string
---@field compress function?
---@field empty_width number
---@field align string
local SectionItem = {
  priority = 0
}
SectionItem.__index = SectionItem

---@param o table
---@return Section
function Section:new(o)
  if type(o) ~= 'table' then
    error('Invalid section: ' .. vim.inspect(o))
  end
  local section = { items = {} }
  for _, item in ipairs(o) do
    table.insert(section.items, SectionItem:new(item))
  end
  return setmetatable(section, Section)
end

---@return SectionItem[]
function Section:get_items()
  return self.items or {}
end

---@param item table
---@return SectionItem
function SectionItem:new(item)
  if type(item) ~= 'table' then
    error('Invalid section item: ' .. vim.inspect(item))
  end
  local align = item.align or enum.alignment.LEFT
  if
    align ~= enum.alignment.LEFT
    and align ~= enum.alignment.CENTER
    and align ~= enum.alignment.RIGHT
  then
    error('Invalid align: ' .. vim.inspect(align))
  end
  local highlight = item.highlight or enum.DEFAULT_HIGHLIGHT
  if type(highlight) ~= 'string' then
    error('Invalid highlight: ' .. vim.inspect(highlight))
  end
  ---@type any
  local content = item.content
  if content ~= nil and
    type(content) ~= 'string' and
    type(content) ~= 'function' then
    error('Invalid content: ' .. vim.inspect(content))
  end
  if item.compress ~= nil and type(item.compress) ~= 'function' then
    error('Invalid compress: ' .. vim.inspect(item.compress))
  end
  if item.priority ~= nil and type(item.priority) ~= 'number' then
    error('Invalid priority: ' .. vim.inspect(item.priority))
  end
  local empty_width = item.empty_width
  if type(empty_width) ~= 'number' or empty_width < 0 then
    empty_width = 0
  end
  return setmetatable({
    content = content,
    highlight = item.highlight or enum.DEFAULT_HIGHLIGHT,
    compress = item.compress,
    empty_width = empty_width,
    priority = item.priority or 0,
    align = align,
  }, SectionItem)
end

---@param opts { buf: number, width: number }
---@return string
function SectionItem:get_content(opts)
  if type(opts) ~= 'table' or
    type(opts.buf) ~= 'number' or
    self.content == nil
  then
    return ''
  end
  local content = self.content
  if type(content) == 'string' then
    return content
  end
  if type(content) == 'boolean' then
    return content and 'true' or 'false'
  end
  if type(content) == 'number' then
    return tostring(content)
  end
  if type(content) == 'function' then
    ---@diagnostic disable-next-line
    content = self.content { buf = opts.buf, width = opts.width }
  end
  if type(content) ~= 'string' then return '' end
  return content
end

return Section
