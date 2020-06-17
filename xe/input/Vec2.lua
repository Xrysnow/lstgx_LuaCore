local base = require('xe.input.Base')
---@class xe.input.Vec2:xe.input.Base
local M = class('xe.input.Vec2', base)
local im = imgui
local wi = require('imgui.Widget')

---@param node xe.SceneNode
function M:ctor(node, idx, labels)
    base.ctor(self, node, idx, 'string')
    local value = self:getEditValue()
    if value == '' then
        value = node:getAttrValue(idx) or ''
    end
    local values = require('xe.util').splitParam(value)
    for i = 1, 2 do
        if not values[i] or values[i] == '' then
            values[i] = '0'
        end
    end
    self._val = values
    self:_updateValue()

    if not labels then
        labels = { '1', '2' }
    end

    self:addChild(im.nextColumn)
    for i = 1, 2 do
        local label = '    ' .. labels[i] or i
        local input = wi.InputText('', values[i], nil, -1)
        self:addChild(function()
            wi.propertyHeader(label, self, '')
        end):addChild(im.nextColumn):addChild(input)
        self:addChild(function()
            if im.isItemDeactivatedAfterEdit() then
                self._val[i] = input:getString()
                self:_updateValue()
                self:submit()
            end
        end)
        if i < 2 then
            self:addChild(im.nextColumn)
        end
    end
end

function M:_updateValue()
    local val = {}
    for _, v in ipairs(self._val) do
        if v == '' then
            table.insert(val, 'nil')
        else
            table.insert(val, v)
        end
    end
    self._value = table.concat(val, ', ')
end

return M
