---@class editor.ToolPanel:ccui.Layout
local M = class('editor.ToolPanel', ccui.Layout)
local helper = require('ui.helper')
local _blue = cc.c3b(43, 87, 154)
local _green = cc.c3b(33, 115, 70)

function M:ctor(param)
    self.param = param or {}
    --self.size = cc.size(128, 720)
    --self.sel_size = cc.size(64, 42)
    --self.color = cc.c3b(33, 115, 70)
    table.deploy(self, self.param, {
        size         = cc.size(64, 720),
        sel_size     = cc.size(64, 42),
        color        = cc.c3b(33, 115, 70),
        panel_size   = cc.size(64, 720),
        sel_bg_color = cc.c3b(243, 243, 243),
        verticle     = false,
        dir          = 'right',
    })
    --Print(stringify(self.color))
    self:setBackGroundColorType(1):setBackGroundColor(self.color)
    self._sel = {}
    self._title = {}
    self._panel = {}
    self._label = {}
    self.hinter = require('ui.sprite').White(self.sel_size)
    self.hinter:addTo(self):setVisible(false):setAnchorPoint(cc.p(0, 1)):setColor(self.sel_bg_color)
    if self.dir == 'left' then
        self.hinter:alignRight(0)
    end
    self:setContentSize(self.size)
end

---@return editor.TabContent
function M:createTab(title, icon)
    table.insert(self._title, title)
    assert(not self._panel[title])
    local panel = require('editor.tool_panel.TabContent')(self.panel_size)
    panel:addTo(self):setVisible(false)
    if self.param.dir == 'left' then
        --panel:alignRight(self:getContentSize().width)
        panel:alignLeft(0)
    else
        --panel:alignLeft(self:getContentSize().width)
        panel:alignRight(0)
    end
    self._panel[title] = panel
    local btn = require('ui.button').ButtonNull(self.sel_size, function()
        --Print('select ' .. title)
        self:select(title)
    end)
    btn:addTo(self):setAnchorPoint(cc.p(0, 1)):setLocalZOrder(2)
    table.insert(self._sel, btn)
    local lb = require('ui.label').create(title, 13)
    lb:setTextColor(cc.WHITE)
    lb:addTo(btn):setPosition(6, self.sel_size.height / 2)
    if self.param.verticle then
        lb:arrangeLeftCenter()
        lb:setRotation(90):setPosition(
                self.sel_size.width / 2, -- - lb:getContentSize().height / 2,
                self.sel_size.height - 6)--:alignCenter()
    end
    if self.dir == 'left' then
        btn:alignRight(0)
    else
        btn:alignLeft(0)
    end
    self._label[title] = lb
    if icon then
        local sp = cc.Sprite:create(icon)
        sp:addTo(btn)
        helper.alignCenter(sp)
    end
    self:_updateButtonLayout()
    if #self._sel == 1 then
        self:select(title)
    end
    return panel
end

function M:_updateButtonLayout()
    local sz = self:getContentSize()
    local yy = sz.height
    for i, v in ipairs(self._sel) do
        v:setPositionY(yy)
        if self.dir == 'left' then
            v:alignRight(0)
        end
        yy = yy - v:getContentSize().height
    end
    if self.dir == 'left' then
        self.hinter:alignRight(0)
    end
    if self._cur then
        local x, y = self._sel[self._cur]:getPosition()
        self.hinter:setPositionY(y)
    end
end

---@return editor.TabContent
function M:getPanel(title)
    return self._panel[title]
end

function M:getTitleIndex(title)
    for i, v in ipairs(self._title) do
        if v == title then
            return i
        end
    end
end

function M:select(title)
    for k, v in pairs(self._panel) do
        v:setVisible(false)
    end
    for k, v in pairs(self._label) do
        v:setTextColor(cc.WHITE)
    end
    self._panel[title]:setVisible(true)
    self._label[title]:setTextColor(self.color)
    self._cur = self:getTitleIndex(title)
    local x, y = self._sel[self._cur]:getPosition()
    self.hinter:setPositionY(y)
    self.hinter:setVisible(true)
end

function M:setContentSize(size)
    self.super.setContentSize(self, size)
    self:_updateButtonLayout()
    for _, panel in pairs(self._panel) do
        panel:setContentSize(cc.size(math.max(0, size.width - self.sel_size.width), size.height))
        if self.dir == 'left' then
            panel:alignLeft(0)
        else
            panel:alignRight(0)
        end
    end
    return self
end

return M
