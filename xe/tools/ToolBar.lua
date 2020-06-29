local base = require('imgui.Widget')
---@class xe.ToolBar:im.Widget
local M = class('xe.ToolBar', base)
local im = imgui
local wi = base

function M:ctor()
    base.ctor(self)
    ---@type table<string,im.ImageButton[]>
    self._btns = {}
    self._states = {}

    local colors = { [im.Col.Button] = function()
        local col = im.getStyleColorVec4(im.Col.Button)
        col.w = 0.1
        return col
    end }
    local vars = { [im.StyleVar.ItemSpacing] = im.vec2(2, 2) }
    local style = wi.style(colors, vars)
    self:addChild(style)

    local toolbar_data = require('xe.tools.toolbar_data')
    local img_size = cc.size(24, 24)
    for i, v in ipairs(toolbar_data) do
        local sp
        local path = 'xe/tool/' .. v.bitmap
        if string.fileext(v.bitmap) == 'svg' then
            sp = cc.Sprite:createWithSVGFile(path, img_size)
        else
            sp = cc.Sprite(path)
        end
        assert(sp)

        local fname = v.name:sub(1, 1):lower() .. v.name:sub(2)
        local cb = function()
            print(string.format('[TOOL] %s', fname))
            require('xe.ToolMgr')[fname]()
            if fname == 'insertAfter' then
                self:disable('insertAfter')
                self:enable('insertChild')
                self:enable('insertBefore')
            elseif fname == 'insertChild' then
                self:disable('insertChild')
                self:enable('insertAfter')
                self:enable('insertBefore')
            elseif fname == 'insertBefore' then
                self:disable('insertBefore')
                self:enable('insertChild')
                self:enable('insertAfter')
            end
        end

        local btn, btn_disable = self:_addContent(sp, cb)
        style:addChild(btn):addChild(btn_disable)
        if i < #toolbar_data then
            style:addChild(im.sameLine)
        end

        local tip = i18n(v.tooltip or v.name)
        if tip then
            style:addChild(function()
                if im.isItemHovered() then
                    im.setTooltip(tip)
                end
            end)
        end

        self._btns[fname] = { btn, btn_disable }
        self._states[fname] = true
    end

    self:addChild(function()
        self:_applyEnable()
    end)

    self:disableAll()
    self:enable('new')
    self:enable('open')
end
---@param sp cc.Sprite
function M:_addContent(sp, cb)
    local btn, btn_disable = require('xe.util').createButton(sp, 4)
    btn:setOnClick(cb)
    return btn, btn_disable
end

function M:disable(name)
    local v = self._btns[name]
    if v then
        self._states[name] = false
    else
        print('invalid tool name:', name)
    end
end
function M:disableAll()
    local states = {}
    for k, v in pairs(self._states) do
        states[k] = false
    end
    self._states = states
end
function M:enable(name)
    local v = self._btns[name]
    if v then
        self._states[name] = true
    else
        print('invalid tool name:', name)
    end
end
function M:enableAll()
    local states = {}
    for k, v in pairs(self._states) do
        states[k] = true
    end
    self._states = states
end
function M:setEnabled(name, b)
    local v = self._btns[name]
    if v then
        self._states[name] = b and true or false
    else
        print('invalid tool name:', name)
    end
end
function M:_applyEnable()
    for k, v in pairs(self._btns) do
        local b = self._states[k]
        v[1]:setVisible(b)
        v[2]:setVisible(not b)
    end
end

return M
