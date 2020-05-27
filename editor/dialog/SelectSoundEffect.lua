---@class editor.dialog.SelectSoundEffect:ui.DialogBase
local M = class('editor.dialog.SelectSoundEffect', require('cc.ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'Select Sound Effect', cc.size(200, 330))
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(243, 243, 243))

    local box_size = cc.size(192, 256)
    local _box = require('cc.ui.sprite').White(box_size)
    _box:setColor(cc.c3b(255, 200, 200))
    _box:addTo(wi):alignHCenter():alignTop(30)
    require('cc.ui.helper').addFrame(_box, cc.c3b(122, 122, 122), 1)

    local box = require('cc.ui.ListBox')(box_size, 16)
    box:addTo(wi):alignHCenter():alignTop(30)
    self._box = box

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:getIndex()
    return self._box:getIndex()
end

function M:getString()
    return self._box:getString()
end

function M:reset()
    self._box:reset()
end

function M:addItem(str)
    self._box:addItem(str)
end

function M:addItems(t)
    for _, v in ipairs(t) do
        self:addItem(v)
    end
end

function M:resetItems(t)
    self:reset()
    self:addItems(t)
end

function M:selectString(str)
    self._box:selectString(str)
end

local _soundList = {}

function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local Tree = require('editor.TreeHelper')
    local di = M()
    local snd = require('editor.node_def._checker').getSoundList()
    local lst = {}
    for k, _ in pairs(snd) do
        table.insert(lst, k)
    end
    _soundList = {}
    for k, _ in pairs(Tree.watch.sound) do
        --local name = Tree.data[k].attr[2]
        --local path = Tree.data[k].attr[1]
        local name = k:getAttrValue(2)
        local path = k:getAttrValue(1)
        table.insert(lst, name)
        _soundList[name] = path
    end
    di:resetItems(lst)
    di._box:setOnSelect(nil)
    di:selectString(panel:getValue(prop_idx))
    di._box:setOnSelect(function()
        local str = di:getString()
        if snd[str] then
            PlaySound(str)
        else
            local fp = cc.FileUtils:getInstance():fullPathForFilename(_soundList[str])
            LoadSound(str, fp)
            PlaySound(str)
        end
    end)
    di:setOnConfirm(function()
        local str = di:getString()
        if str ~= '' then
            panel:setValue(prop_idx, str)
        end
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
