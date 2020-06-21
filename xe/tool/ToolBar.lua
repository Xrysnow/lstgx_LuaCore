local base = require('imgui.widgets.Window')
---@class xe.ToolBar:im.Window
local M = class('xe.ToolBar', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'xe.ToolBar')
    self:setFlags(im.WindowFlags.HorizontalScrollbar, im.WindowFlags.NoTitleBar)
    local style = wi.styleVars({ [im.StyleVar.ItemSpacing] = im.vec2(2, 2) })
    self:addChild(style)

    local toolbar_data = require('xe.tool.data')
    for i, v in ipairs(toolbar_data) do
        local btn = require('xe.tool.Base')('xe/tool/' .. v.bitmap)
        style:addChild(btn):addChild(im.sameLine)
        local fname = v.name:sub(1, 1):lower() .. v.name:sub(2)
        btn:setOnClick(function()
            print(string.format('[TOOL] %s', fname))
            require('xe.ToolMgr')[fname]()
        end)

        local tip = v.tooltip or v.name
        style:addChild(function()
            if im.isItemHovered() then
                im.setTooltip(tip)
            end
        end)
    end
end

return M

