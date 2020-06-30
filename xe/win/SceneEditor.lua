local base = require('imgui.widgets.Window')
---@class xe.SceneEditor:im.Window
local M = class('xe.SceneEditor', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'Scene Editor')
    --self:addChild(function()
    --    im.setWindowFontScale(1.25)
    --end)

    self._toolbar = require('xe.tools.ToolBar')()
    self:addChild(self._toolbar)

    self._toolpanel = require('xe.tools.ToolPanel')()
    self:addChild(self._toolpanel)
    self._toolpanel:disableAll()

    local win = wi.ChildWindow('xe.scene.tree', im.vec2(-1, -1), true)
    self:addChild(win)--:addChild(im.separator)
    self._treewin = win

    local setting = setting.xe
    local style = wi.style(nil, {
        [im.StyleVar.FramePadding] = function()
            local v = setting.editor_tree_padding or 0
            return im.vec2(v, v)
        end
    })
    style:addTo(win)

    self._tree = require('xe.SceneTree')()
    self._tree:addTo(style)

    self._game = require('xe.win.GameView')()
    self._game:addTo(self):setVisible(false)
end

---@return xe.SceneTree
function M:getTree()
    return self._tree
end

function M:setEditor()
    self._toolbar:setVisible(true)
    self._toolpanel:setVisible(true)
    self._treewin:setVisible(true)
    self._game:setVisible(false)
end

function M:setGame()
    self._toolbar:setVisible(false)
    self._toolpanel:setVisible(false)
    self._treewin:setVisible(false)
    self._game:setVisible(true)
end

return M
