---@class editor.dialog.NewProject:ui.DialogBase
local M = class('editor.dialog.NewProject', require('ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'NewProject', cc.size(320, 240))
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(243, 243, 243))
    local group = ccui.RadioButtonGroup:create()
    for i, v in ipairs({ 'Empty', 'Single Stage', 'Single Spell Card', 'TouHou' }) do
        local rb = require('ui.prefab.RadioButton').create(cc.size(20, 20))
        local yy = 168 - (i - 1) * 22
        rb:addTo(wi):setPosition(128, yy)
        group:addRadioButton(rb)
        local lb = require('ui.label').create(v)
        lb:setTextColor(cc.BLACK)
        lb:addTo(wi):setPosition(146, yy)
    end
    group:addTo(wi)
    self._group = group

    local fp = require('ui.FilePicker')('luastg', nil, true)
    fp:addTo(wi):setPosition(114, 56)
    require('ui.helper').addFrame(fp:getEditBox(), cc.c3b(122, 122, 122), 1)
    self._fp = fp

    local left = cc.Sprite:create('editor/images/left image.png')
    left:addTo(wi):alignLeft(10):alignBottom(10)

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)

    local hint = require('ui.label').create('1. Choose a template.\n2. Specify file path and name.')
    hint:setTextColor(cc.BLACK)
    hint:addTo(wi):setPosition(118, 200)
end

function M:getMode()
    return self._group:getSelectedButtonIndex()
end

function M:getPath()
    return self._fp:getEditBox():getString(0)
end

return M
