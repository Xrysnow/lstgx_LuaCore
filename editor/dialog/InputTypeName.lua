---@class editor.dialog.InputTypeName:ui.DialogBase
local M = class('editor.dialog.InputTypeName', require('ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'Input Type Name', cc.size(286, 140))
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(243, 243, 243))

    require('ui.label').create('Type name'):addTo(wi):alignLeft(10):alignTop(36)
    require('ui.label').create('Difficulty'):addTo(wi):alignLeft(10):alignTop(36 + 32)

    local input = require('ui.prefab.EditBox').String(cc.size(192, 22))
    input:addTo(wi):alignLeft(84):alignTop(36)
    self._input = input
    require('ui.helper').addFrame(input, cc.c3b(122, 122, 122))

    self._difs = { 'All', 'Easy', 'Normal', 'Hard', 'Lunatic' }
    local sel = require('ui.DropDownList').createBase(192, 22, self._difs, 1)
    sel:addTo(wi):alignLeft(84):setPositionY(52)
    self._sel = sel
    require('ui.helper').addFrame(sel.button, cc.c3b(122, 122, 122))

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:setTypeName(str)
    self._input:setString(0, str)
end

function M:getTypeName()
    return self._input:getString()
end

function M:setDifficulty(str)
    for i, v in ipairs(self._difs) do
        if v == str then
            self._sel.button:setTitleText(str)
        end
    end
end

function M:getDifficulty()
    return self._sel.button:getTitleText()
end

---@param node editor.TreeNode
function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local di = M()
    local tname = node:getAttrValue(1)
    local t1 = string.match(tname, '^(.+):.+$')
    local t2 = string.match(tname, '^.+:(.+)$')
    if t1 then
        di:setTypeName(t1)
        di:setDifficulty(t2)
    else
        di:setTypeName(tname)
        di:setDifficulty("All")
    end

    di:setOnConfirm(function()
        local typename = di:getTypeName()
        local dif = di:getDifficulty()
        if dif == 'All' or string.match(dif, "^[%s]*$") then
            panel:setValue(prop_idx, typename)
        else
            panel:setValue(prop_idx, typename .. ':' .. dif)
        end
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
