---@class editor.dialog.SelectImage:ui.DialogBase
local M = class('editor.dialog.SelectImage', require('ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'Select Image', cc.size(480, 340))
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(243, 243, 243))

    local box_size = cc.size(192, 256)
    local _box = require('ui.sprite').White(box_size)
    _box:setColor(cc.c3b(255, 200, 200))
    _box:addTo(wi):alignLeft(10):alignTop(30)
    require('ui.helper').addFrame(_box, cc.c3b(122, 122, 122), 1)

    local box = require('ui.ListBox')(box_size, 16)
    box:addTo(wi):alignLeft(10):alignTop(30)
    self._box = box

    local pr = require('ui.ImagePreviewer')(cc.size(256, 256))
    pr:addTo(wi):alignRight(10):alignTop(30)
    self._pr = pr

    ---@type cc.Sprite[]
    self._images = {}
    --[[
    box:setOnSelect(function()
        local idx = box:getIndex()
        if not idx then
            return
        end
        local img = self._images[idx]
        if img then
            img:removeSelf():setVisible(true)
        end
        local last = pr:getSprite()
        if last then
            last:removeSelf():addTo(wi):setVisible(false)
        end
        pr:showSprite(img)
    end)
    ]]
    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:select(idx)
    self._box:_select(idx)
end

function M:reset()
    self._pr:reset()
    self._box:reset()
    for _, v in ipairs(self._images) do
        v:removeSelf():release()
    end
    self._images = {}
end

function M:addImage(name, sprite)
    if sprite then
        sprite:addTo(self:getWidget()):setVisible(false)
        table.insert(self._images, sprite)
        sprite:retain()
    end
    self._box:addItem(name)-- will call onselect
end

--- string or nil
function M:getSelectName()
    return self._box:getString()
end

function M:getString()
    return self:getSelectName() or ''
end

local _imageList = {}

---@param node editor.TreeNode
function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local Tree = require('editor.TreeHelper')
    local di = M()
    local imgonly = false
    local type = node:getType()
    if type == 'loadparticle' or type == 'bglayer' then
        imgonly = true
    end
    di:reset()
    _imageList = {}
    if imgonly then
        for k, v in pairs(Tree.watch.image) do
            if k:getType() == 'loadimage' then
                local a1 = k:getAttrValue(1)
                local a2 = k:getAttrValue(2)
                local name = 'image:' .. a2
                di:addImage(name)
                _imageList[name] = a1
            end
        end
    else
        for k, v in pairs(Tree.watch.image) do
            local type = k:getType()
            local a1 = k:getAttrValue(1)
            local a2 = k:getAttrValue(2)
            if type == 'loadimage' then
                local name = 'image:' .. a2
                di:addImage(name)
                _imageList[name] = a1
            elseif type == 'loadani' then
                local name = 'ani:' .. a2
                di:addImage(name)
                _imageList['ani:' .. a2] = a1
            elseif type == 'loadparticle' then
                local name = 'particle:' .. a2
                di:addImage(name)
                --TODO: show particle image
            end
        end
    end
    di._box:setOnSelect(function()
        local str = di:getString()
        local path = _imageList[str]
        if path then
            -- local file may be changed
            cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
            local fp = cc.FileUtils:getInstance():fullPathForFilename(path)
            local sp = cc.Sprite:create(fp)
            di._pr:showSprite(sp)
        end
    end)
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
