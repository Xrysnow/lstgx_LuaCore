---@class editor.TabContent:ccui.Layout
local M = class('editro.TabContent', ccui.Layout)
local btn_size = cc.size(56, 48)
local helper = require('ui.helper')
local margin = 8

function M:ctor(size, param)
    table.deploy(self, param, {
        color = cc.c3b(243, 243, 243),
    })
    self:setBackGroundColorType(1):setBackGroundColor(self.color)
    ---@type cc.Node[]
    self._content = {}
    self.btn_size = btn_size

    self.scr = ccui.ScrollView:create()
    self.scr:setScrollBarEnabled(false)
    self.scr:addTo(self):alignCenter()

    self:setContentSize(size)
    --scr:setBackGroundColorType(1):setBackGroundColor(cc.c3b(255, 200, 200))
end

function M:addContent(title, ico, cb)
    local btn = require('ui.button').BaseButton(self.btn_size, cb)
    btn:setColor(self.color)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    local sp = cc.Sprite:create(ico)
    --sp:setScale(1.5)
    sp:addTo(btn)
    btn:addTo(self.scr)
    table.insert(self._content, btn)
    helper.alignCenter(sp)
    self:updateLayout()
end

function M:updateLayout()
    local sz = self:getContentSize()
    local w, h = self.btn_size.width, self.btn_size.height
    local hh = (h + margin) * #self._content + margin
    self.scr:setInnerContainerSize(cc.size(sz.width, hh))
    if hh < sz.height then
        self.scr:setContentSize(cc.size(sz.width, hh))
        self.scr:setPositionY(sz.height - hh)
    else
        self.scr:setContentSize(sz)
        self.scr:setPositionY(0)
    end
    for i, v in ipairs(self._content) do
        v:setPosition(sz.width / 2, hh - (h + margin) * (i - 0.5) - margin / 2)
    end
end

function M:setOnResize(cb)
    self._onResize = cb
end

function M:setContentSize(size)
    self.super.setContentSize(self, size)
    self:updateLayout()
    if self._onResize then
        self:_onResize(size)
    end
    return self
end

return M
