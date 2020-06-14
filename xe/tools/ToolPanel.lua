local base = require('imgui.widgets.Window')
---@class xe.ToolPanel:im.Window
local M = class('editor.ToolPanel', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'Tools')
    self:setFlags(
            im.WindowFlags.NoTitleBar,
            im.WindowFlags.HorizontalScrollbar)
    self._panels = {}
    self._tabbar = wi.TabBar('xe.tools.TabBar')
    self:addChild(self._tabbar)
    local data = require('xe.tools.data')
    for _, v in ipairs(data) do
        local tab = self:_createTab(v.label)
        for _, item in ipairs(v.content) do
            local icon = 'xe/node/' .. item.bitmap
            assert(item.name:sub(1, 7) == 'Insert_')
            local name = item.name:sub(8)
            local f = require('xe.ToolMgr').getNodeHandler(name)
            --TODO
            local tooltip = name
            tab:addContent(icon, tooltip, f)
        end
    end
end

function M:_createTab(title)
    local panel = require('xe.tools.TabContent')(title)
    panel:addTo(self._tabbar)
    table.insert(self._panels, panel)
    return panel
end

--function M:_updateButtonLayout()
--end

---@return editor.TabContent
--function M:getPanel(title)
--    return self._panel[title]
--end

function M:getTitleIndex(title)
    for i, v in ipairs(self._title) do
        if v == title then
            return i
        end
    end
end

function M:select(title)
end

return M
