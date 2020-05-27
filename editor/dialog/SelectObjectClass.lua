---@class editor.dialog.SelectObjectClass:ui.DialogBase
local M = class('editor.dialog.SelectObjectClass', require('cc.ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'Select Type', cc.size(200, 330))
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

---@param node editor.TreeNode
function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local Tree = require('editor.TreeHelper')
    --local curNode = node
    local di = M()
    --local type = node:getType()
    di:reset()
    local watch
    local t = node:getType()
    if t == 'enemycreate' then
        watch = 'enemydefine'
    elseif t == 'bosscreate' then
        watch = 'bossdefine'
    elseif t == 'bulletcreate' then
        watch = 'bulletdefine'
    elseif t == 'objectcreate' then
        watch = 'objectdefine'
    elseif t == 'lasercreate' then
        watch = 'laserdefine'
    elseif t == 'laserbentcreate' then
        watch = 'laserbentdefine'
    elseif t == 'bossdefine' then
        watch = 'bgdefine'
    elseif t == 'reboundercreate' then
        watch = 'rebounder'
    else
        --
    end
    local list = {}
    local function append(s)
        if not list[s] then
            list[s] = true
            di:addItem(s)
        end
    end
    if t ~= 'bossdefine' then
        for k, v in pairs(Tree.watch[watch]) do
            local tmp = string.match(k:getAttrValue(1), '^(.+):.+$')
            if tmp then
                append(tmp)
            else
                append(k:getAttrValue(1))
            end
        end
    else
        for k, v in pairs(Tree.watch[watch]) do
            append(k:getAttrValue(1))
        end
    end
    di._box:selectString(panel:getValue(prop_idx))
    di:setOnConfirm(function()
        local str = di:getString()
        if str ~= '' then
            panel:setValue(prop_idx, str)
        end
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
