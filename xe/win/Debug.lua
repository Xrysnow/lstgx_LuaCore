local base = require('imgui.widgets.Window')
---@class xe.Debug:im.Window
local M = class('xe.Debug', base)

function M:ctor()
    base.ctor(self, 'Debug')
end

return M
