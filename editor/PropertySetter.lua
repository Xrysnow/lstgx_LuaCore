---@class editor.PropertySetter:ccui.Widget
local M = class('editor.PropertySetter', ccui.Widget)
--local _sz = cc.size(320, 32)

function M:ctor(title, types, param)
    table.deploy(self, param, {
        size           = cc.size(320, 18 + 28),
        cap_bg_color   = cc.c3b(221, 221, 221),
        cap_text_color = cc.BLACK,
        cap_h          = 18,
        edit_btn_size  = cc.size(24, 24),
        input_size     = cc.size(145, 28),
    })
    self:setAnchorPoint(cc.p(0, 0.5))
    --self:setContentSize(self.size)

    self._cap = ccui.Layout:create()
    self._cap:setBackGroundColorType(1):setBackGroundColor(self.cap_bg_color)
    self._cap:addTo(self):setContentSize(cc.size(self.size.width, self.cap_h)):alignLeft(0):alignTop(0)

    local yy = self.size.height / 2
    local tt = self:_createTitle(title)
    tt:addTo(self._cap):alignLeft(8):alignVCenter()--:setAnchorPoint(cc.p(0, 0.5)):setPosition(cc.p(24, yy))
    self.title = tt

    self.types = types
    ---@type editor.PropertyInputBase[]
    self.inputs = {}
    for i, v in ipairs(types) do
        local input = self:_createInput(v, param)
        input:addTo(self):alignRight(40):alignTop(self.cap_h)
        --:setAnchorPoint(cc.p(0, 0.5)):setPosition(cc.p(128, 0))
        input:setVisible(false)
        self.inputs[i] = input
    end
    self._cur = 1
    if #types == 1 then
        self.inputs[1]:setVisible(true)
        --local lb = self:_createTitle(types[1])
        --lb:addTo(self):setAnchorPoint(cc.p(0, 0.5)):setPosition(cc.p(64, yy))
    else
        local cur_idx = 1
        if param.cur_type then
            cur_idx = self:_getTypeIndex(param.cur_type) or 1
        end
        self.inputs[cur_idx]:setVisible(true)
        local sel = require('cc.ui.DropDownList').createBase(64, 28, self.types, cur_idx)
        sel:addTo(self):setAnchorPoint(cc.p(0, 0.5)):setPosition(cc.p(64, yy))
        sel:addHideTask(function()
            self:_select(sel:getCurrentIndex())
        end)
        self.sel = sel
    end
    self._onAdvEdit = std.fvoid
    local btn = require('cc.ui.button').Button1(self.edit_btn_size, function()
        self._onAdvEdit()
    end, '...')
    local hh = (self.size.height - self.cap_h) / 2 + self.cap_h - self.edit_btn_size.height / 2
    btn:addTo(self):alignTop(hh):alignRight(8)
    self._btn = btn
    self:setContentSize(self.size)
end

function M:getValue()
    return self.inputs[self._cur]:getValue()
end

function M:setValue(v)
    if v == nil then
        v = ''
    end
    return self.inputs[self._cur]:setValue(v)
end

function M:getString()
    local i = self.inputs[self._cur]
    local ret = i:getString()
    if i.type == 'string' then
        ret = string.format('%q', ret)
    end
    return ret
end

function M:setString(idx, str)
    self.inputs[self._cur]:setString(idx, str)
end

function M:getTitle()
    return self.title:getString()
end

function M:setOnAdvancedEdit(cb)
    self._onAdvEdit = cb
end

function M:_select(idx)
    if self._cur == idx then
        return
    end
    for _, v in ipairs(self.inputs) do
        v:setVisible(false)
    end
    self.inputs[idx]:setVisible(true)
    self._cur = idx
end

function M:_getTypeIndex(type)
    for i, v in ipairs(self.types) do
        if v == type then
            return i
        end
    end
end

function M:_createTitle(str)
    local ret = cc.Label:createWithSystemFont(str, 'Arial', 14)
    ret:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    ret:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    ret:setAnchorPoint(cc.p(0, 0.5))
    ret:setTextColor(self.cap_text_color)
    return ret
end

function M:_createInput(t, param)
    local p = require('editor.property_input.common')
    if t == 'vec2' then
        return require('editor.property_input.vec2'):create(param, param.subtitle or { '1', '2' })
    elseif t == 'enum' then
        return require('editor.property_input.enum'):create(param, self.input_size)
    elseif p[t] then
        return p[t]:create(param, self.input_size)
    else
        return p.string(param, self.input_size)
        --error('invalid type: ' .. t)
    end
end

function M:setContentSize(size)
    self.super.setContentSize(self, size)
    self.size=size
    self._cap:setContentSize(cc.size(size.width,self.cap_h))
    self._btn:alignRight(8)
    for _, input in ipairs(self.inputs) do
        input:alignRight(40)
    end
    return self
end

return M
