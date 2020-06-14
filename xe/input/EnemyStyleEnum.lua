local base = require('xe.input.Base')
---@class xe.input.EnemyStyleEnum:xe.input.Base
local M = class('xe.input.EnemyStyleEnum', base)
local im = imgui
local wi = require('imgui.Widget')
local path = 'xe/enemy_style/'
local _num = 34
local types = {}
for i = 1, _num do
    types[i] = tostring(i)
    types[tostring(i)] = i
end

---@param node xe.SceneNode
function M:ctor(node, idx)
    base.ctor(self, node, idx, 'enemy_style')
    self:_loadImage()

    local value = node:getAttrValue(idx)
    if not types[value] then
        value = self:getEditValue() or types[1]
    end
    self._value = value
    self._sel = types[value]

    local btn = wi.Button('', function()
        im.openPopup('xe.input.EnemyStyleEnum')
    end, im.Dir.Down, 'arrow')
    self:addChild(btn)
    local _tint = im.vec4(1, 1, 1, 1)
    self:addChild(function()
        self:_render()
        im.sameLine()
        im.text(self._value)

        local sp = self:_getImage(self._sel, self._color or 1)
        if sp then
            local rect = sp:getTextureRect()
            im.image(sp, im.vec2(rect.width, rect.height), _tint, im.getStyleColorVec4(im.Col.Border))
        end
    end)
end

function M:_loadImage()
    local main = require('xe.main'):getInstance()
    local img = main._enemy_style
    if not img then
        img = {}
        main._enemy_style = img
        for i, v in ipairs(types) do
            local f = ('%senemy%s.png'):format(path, v)
            local sp = cc.Sprite(f)
            sp:setVisible(false):addTo(main)
            img[types[i]] = sp
        end
    end
    self._img = img
end

function M:_render()
    if im.beginPopup('xe.input.EnemyStyleEnum') then
        if self:_renderTypeSelector() then
            im.closeCurrentPopup()
        end
        im.endPopup()
    end
end

function M:_renderTypeSelector(nCol)
    nCol = nCol or 5
    im.pushStyleVar(im.StyleVar.ItemSpacing, im.p(4, 4))
    local w = im.getWindowWidth()
    local spa = im.getStyle().ItemSpacing
    local spaw = spa.x
    local size = im.p(64, 64)
    if nCol == -1 then
        local count = math.floor((w - spaw) / (size.x + spaw))
        nCol = math.max(count, 1)
    end
    local dl = im.getWindowDrawList()

    local ret, any_ret
    local last = self._sel
    for i = 1, #types do
        local p = im.getCursorScreenPos()
        local center = cc.pAdd(p, cc.pMul(size, 1 / 2))
        im.pushID(i)
        ret = im.button('', size)
        if ret then
            self._sel = i
            any_ret = true
        end
        im.popID()
        self:_renderImage(i, dl, center)
        if self._sel == i then
            dl:addRect(p, cc.pAdd(p, size), im.getColorU32(im.Col.ButtonActive), 0, 0, 3)
        end
        if i % nCol ~= 0 and i < #types then
            im.sameLine()
        end
    end
    im.popStyleVar(1)
    if self._sel ~= last then
        self._value = types[self._sel]
        self:submit()
    end
    return any_ret
end

function M:_renderImage(id, drawList, center, scale)
    scale = scale or 1
    local sp = self:_getImage(id)
    if sp then
        local sz = sp:getTextureRect()
        sz = im.p(sz.width, sz.height)
        local hsz = cc.pMul(sz, 1 / 2 * scale)
        local lt = cc.pSub(center, hsz)
        local rb = cc.pAdd(center, hsz)
        drawList:addImage(sp, lt, rb)
    end
end
---@return cc.Sprite
function M:_getImage(id)
    local name = types[id]
    return self._img[name]
end

return M
