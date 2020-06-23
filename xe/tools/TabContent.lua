local base = require('imgui.widgets.TabItem')
---@class xe.TabContent:im.TabItem
local M = class('xe.TabContent', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor(title)
    base.ctor(self, title)
end

function M:addContent(icon, tooltip, cb)
    local sp = cc.Sprite(icon)
    local btn = require('imgui.widgets.ImageButton')(sp)
    self:addChild(btn)
    sp:setVisible(false)--:addTo(btn)

    if tooltip then
        btn:addChild(function()
            if im.isItemHovered() then
                im.setTooltip(tooltip)
            end
        end)
    end
    if cb then
        btn:setOnClick(cb)
    end

    local sz = sp:getContentSize()
    sz = im.vec2(sz.width, sz.height)
    local tint = im.vec4(1, 1, 1, 1)
    local btn_disable = wi.CCNode(sp, tint, im.getStyleColorVec4(im.Col.Border))
    btn_disable:setVisible(false)
    self:addChild(btn_disable)

    local program = ccb.Program:getBuiltinProgram(15)
    assert(program)
    sp:setProgramState(ccb.ProgramState(program))
    sp:setBlendFunc({ src = ccb.BlendFactor.SRC_ALPHA, dst = ccb.BlendFactor.ONE_MINUS_SRC_ALPHA })

    self:addChild(im.sameLine)
    return btn, btn_disable
end

return M
