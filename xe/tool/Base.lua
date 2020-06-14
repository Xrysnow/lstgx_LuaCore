local base = require('imgui.widgets.ImageButton')
--
---@class xe.tool.Base:im.ImageButton
local M = class('xe.tool.Base', base)

function M:ctor(icon_enable, icon_disable)
    self._sp_enable = cc.Sprite(icon_enable)
    self._sp_disable = cc.Sprite(icon_disable or icon_enable)
    self._sp_enable:setVisible(false):addTo(self)
    self._sp_disable:setVisible(false):addTo(self)
    base.ctor(self, self._sp_enable)
    self:setEnable(true)
end

function M:setEnable(b)
    if b then
        self._enable = true
        self._param[1] = self._sp_enable
    else
        self._enable = false
        self._param[1] = self._sp_disable
    end
end

function M:_onclick()
    print('_onclick() should be overrided')
end

--TODO: tooltip

return M
