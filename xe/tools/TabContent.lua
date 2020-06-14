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
    sp:setVisible(false):addTo(btn)
    self:addChild(btn):addChild(im.sameLine)
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
end

return M
