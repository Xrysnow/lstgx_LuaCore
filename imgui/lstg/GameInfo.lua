local base = require('imgui.widgets.Window')

---@class im.lstg.GameInfo:im.Window
local M = class('im.lstg.GameInfo', base)
local im = imgui

function M:ctor(...)
    base.ctor(self, ...)
    local wi = require('imgui.Widget')
    self:addChildChain(
            wi.TreeNode('Game Resource'),
            require('imgui.lstg.GameResInfo')())
    self:addChildChain(
            wi.TreeNode('THlib Info'),
            require('imgui.lstg.THlibInfo')())
    self:addChildChain(
            wi.TreeNode('Performance'),
            require('imgui.lstg.PerformanceInfo')())
    self:setFlags(im.WindowFlags.HorizontalScrollbar)
end

return M
