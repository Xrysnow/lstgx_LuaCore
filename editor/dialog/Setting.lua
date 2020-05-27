---@class editor.dialog.Setting:ui.DialogBase
local M = class('editor.dialog.Setting', require('cc.ui.DialogBase'))

function M:ctor()
    self.size = cc.size(214, 230)
    self.super.ctor(self, 'Settings', self.size)
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(240, 240, 240))

    require('cc.ui.label').create('Resolution X'):addTo(wi):alignLeft(16):alignBottom(155)
    require('cc.ui.label').create('Resolution Y'):addTo(wi):alignLeft(16):alignBottom(123)
    --require('ui.label').create('Run in window mode'):addTo(wi):alignLeft(36):alignBottom(90 - 2)
    --require('ui.label').create('Cheat'):addTo(wi):alignLeft(36):alignBottom(60 - 2)

    local eb1 = require('cc.ui.prefab.EditBox').Integer(cc.size(48, 18), 0)
    eb1:addTo(wi):alignLeft(120):alignBottom(155)
    require('cc.ui.helper').addFrame(eb1, cc.c3b(122, 122, 122), 1)
    self._eb1 = eb1

    local eb2 = require('cc.ui.prefab.EditBox').Integer(cc.size(48, 18), 0)
    eb2:addTo(wi):alignLeft(120):alignBottom(123)
    require('cc.ui.helper').addFrame(eb2, cc.c3b(122, 122, 122), 1)
    self._eb2 = eb2

    local cb1 = require('cc.ui.checkbox').createBase()
    cb1:addTo(wi):alignLeft(16):alignBottom(90)
    self._cb1 = cb1
    require('cc.ui.checkbox').addLabel(cb1, 'Run in window mode')

    local cb2 = require('cc.ui.checkbox').createBase()
    cb2:addTo(wi):alignLeft(16):alignBottom(60)
    self._cb2 = cb2
    require('cc.ui.checkbox').addLabel(cb2, 'Cheat')

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:setResX(px)
    self._eb1:setValue(px)
end

function M:getResX()
    return self._eb1:getValue()
end

function M:setResY(px)
    self._eb2:setValue(px)
end

function M:getResY()
    return self._eb2:getValue()
end

function M:setWindowed(b)
    self._cb1:setSelected(b)
end

function M:isWindowed()
    return self._cb1:isSelected()
end

function M:setCheat(b)
    self._cb2:setSelected(b)
end

function M:isCheat()
    return self._cb2:isSelected()
end

return M
