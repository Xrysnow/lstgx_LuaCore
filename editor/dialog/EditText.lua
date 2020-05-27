---@class editor.dialog.EditText:ui.DialogBase
local M = class('editor.dialog.EditText', require('cc.ui.DialogBase'))

function M:ctor()
    self.size = cc.size(420, 420)
    self.super.ctor(self, 'Edit Text', self.size)
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(240, 240, 240))

    local lb = require('cc.ui.label').create('Edit text')
    lb:addTo(wi):alignLeft(20):alignTop(30)
    self._lb = lb

    local eb = require('cc.ui.prefab.EditBox').String(cc.size(380, 300))
    eb:addTo(wi):alignCenter()
    self._eb = eb
    require('cc.ui.helper').addFrame(eb, cc.c3b(122, 122, 122), 1)

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:setDescription(str)
    self._lb:setString(str)
end

function M:setString(str)
    self._eb:setString(0, str)
end

function M:getString()
    return self._eb:getString(0)
end

function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local di = M()
    di:setDescription(panel:getSetter(prop_idx):getTitle())
    di:setString(panel:getValue(prop_idx))
    di:setOnConfirm(function()
        panel:setValue(prop_idx, di:getString())
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
