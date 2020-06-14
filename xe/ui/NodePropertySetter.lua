local base = require('imgui.Widget')
---@class xe.NodePropertySetter:im.Widget
local M = class('xe.NodePropertySetter', base)
local im = imgui
local wi = base

---@param node xe.SceneNode
function M:ctor(node, idx)
    self._node = node
    self._idx = idx
    self._title = node:getAttrName(idx) or ''
    local t = node:getAttrType(idx)
    local types = require('xe.node.edit_type')[t]
    assert(types and #types > 0)
    self._types = types
    local type_items = {}
    ---@type xe.input.Base[]
    self._inputs = {}
    for _, v in ipairs(types) do
        if v == 'const' then
            for _, vv in ipairs(types.const) do
                assert(vv[1] and vv[2])
                local input = self:_createConst(vv[2])
                -- use type to identify different const
                input._type = vv[1]
                input:setVisible(false)
                table.insert(self._inputs, input)
                table.insert(type_items, vv[1])
            end
        else
            local input = self:_createInput(v)
            input:setVisible(false)
            table.insert(self._inputs, input)
            table.insert(type_items, v)
        end
    end
    local num = #self._inputs
    assert(num > 0)
    --TODO: set default edit type in setting
    self._cur = require('xe.main').getSetting('prop.edit.' .. t) or 1
    if num == 1 then
        self._inputs[1]:setVisible(true)
    else
        local cur_idx = self:_getCurIndex() or 1
        self._cur = cur_idx

        local edit_type_sel = wi.Combo('', types, self._cur):setFlags(im.ComboFlags.NoPreview)
        edit_type_sel:setOnChange(function(_, item, ii)
            if ii == 0 then
                return
            end
            self:_select(ii)
        end)
        self:addChild(edit_type_sel):addChild(im.sameLine)

        self._inputs[cur_idx]:setVisible(true)
    end
    for _, input in ipairs(self._inputs) do
        input:addTo(self)
    end
end

function M:getValue()
    return self._inputs[self._cur]:getValue()
end

function M:setValue(v)
    if v == nil then
        v = ''
    end
    return self._inputs[self._cur]:setValue(v)
end

function M:getString()
    local i = self._inputs[self._cur]
    local ret = i:getString()
    if i._type == 'string' then
        ret = string.format('%q', ret)
    end
    return ret
end

function M:setString(idx, str)
    self._inputs[self._cur]:setString(idx, str)
end

function M:getTitle()
    return self._title
end

function M:_select(idx)
    if self._cur == idx then
        return
    end
    for _, v in ipairs(self._inputs) do
        v:setVisible(false)
    end
    --local last = self._inputs[self._cur]
    --last:submit()
    local input = self._inputs[idx]
    assert(input)
    input:setVisible(true)
    self._cur = idx
    -- submit here because inputs don't share values
    require('xe.SceneTree').submit()
end

function M:_getCurIndex()
    local t = self._node:getAttrEditType(self._idx)
    for i, v in ipairs(self._inputs) do
        if v:getType() == t then
            return i
        end
    end
end

function M:_createInput(t)
    -- NOTE: input only submit its value when edit finished

    --if t == 'vec2' then
    --    return require('editor.property_input.vec2'):create(param, param.subtitle or { '1', '2' })
    --elseif t == 'enum' then
    --    return require('editor.property_input.enum'):create(param, self.input_size)
    --end

    local nt = self._node:getType()
    local ret
    --print('createInput', nt, t)
    if t == 'path' then
        --TODO: loadFX
        ret = require('xe.input.Path')(self._node, self._idx, self._types[nt])
    elseif t == 'bool' then
        ret = require('xe.input.Bool')(self._node, self._idx)
    elseif t == 'color_enum' then
        ret = require('xe.input.ColorEnum')(self._node, self._idx)
    else
        ret = require('xe.input.String')(self._node, self._idx, true)
    end
    ret._master = self
    return ret
end

function M:_createConst(v)
    local ret = require('xe.input.Const')(self._node, self._idx, v)
    ret._master = self
    return ret
end

function M:_handler()
    --TODO: tip
    wi.propertyHeader(self._title, self, '')
    im.nextColumn()
    wi._handler(self)
    im.nextColumn()
end

return M
