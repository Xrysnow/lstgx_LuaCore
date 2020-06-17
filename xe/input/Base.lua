local base = require('imgui.Widget')
---@class xe.input.Base:im.Widget
local M = class('xe.input.Base', base)

---@param node xe.SceneNode
function M:ctor(node, idx, type)
    base.ctor(self)
    assert(node and idx and type)
    ---@type xe.SceneNode
    self._node = node
    self._idx = idx
    self._type = type
end

function M:getValue()
    return self._value
end

function M:setValue(v)
    self._value = v
end

function M:getString()
    return M:getValue()
end

function M:getType()
    return self._type
end

function M:submit(value, str)
    if value == nil then
        value = self:getValue()
    end
    str = str or tostring(value)
    --if self._master then
    --    self._master:submit(self)
    --else
    --end
    self._node:setAttrEditType(self._idx, self._type)
    self._node:setAttrEditValue(self._idx, self._type, value, str)
    require('xe.SceneTree').submit()
end

function M:getEditValue()
    local node = self._node
    local idx = self._idx
    return node:getAttrEditValue(idx, self._type) or node:getDefaultAttrValue(idx) or ''
end

return M
