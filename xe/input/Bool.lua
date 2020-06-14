local base = require('xe.input.Base')
---@class xe.input.Bool:xe.input.Base
local M = class('xe.input.String', base)
local im = imgui
local wi = require('imgui.Widget')
local map = { ['true'] = true, ['false'] = false }

---@param node xe.SceneNode
function M:ctor(node, idx)
    base.ctor(self, node, idx, 'bool')

    local value = node:getAttrEditValue(idx, self._type)
    if type(value) ~= 'boolean' then
        value = node:getAttrValue(idx)
        if map[value] ~= nil then
            value = map[value]
        else
            value = map[node:getDefaultAttrValue(idx)]
        end
    end
    if type(value) ~= 'boolean' then
        value = false
    end

    self._value = value

    local cb = wi.Checkbox('', self._value, function(_, v)
        self._value = v and true or false
        self:submit(self._value, self:getValue())
    end)
    self:addChild(cb)
end

function M:getValue()
    return self._value and 'true' or 'false'
end

function M:setValue(v)
    if type(v) == 'string' then
        v = map[v]
    end
    self._value = v
end

return M
