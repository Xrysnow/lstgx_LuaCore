local base = require('xe.input.Base')
---@class xe.input.Const:xe.input.Base
local M = class('xe.input.String', base)
local im = imgui
local wi = base

---@param node xe.SceneNode
function M:ctor(node, idx, value)
    base.ctor(self, node, idx, 'const')
    self._value = value or ''
    --local once
    self:addChild(function()
        im.textWrapped(self._value)
        -- submit once
        --if not once then
        --    once = true
        --    self:submit()
        --end
    end)
end

return M
