local base = require('imgui.widgets.Window')
---@class xe.ui.SceneManager:im.Window
local M = class('xe.ui.SceneManager', base)
local main = require('xe.main')
local im = imgui
--local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'Scene Editor')
    --self:addChild(function()
    --    im.setWindowFontScale(1.25)
    --end)

    self._tree = require('xe.SceneTree')()
    self._tree:addTo(self)

end

function M:getTree()
    return self._tree
end

return M
