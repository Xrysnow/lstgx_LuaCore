local base = require('xe.input.Base')
---@class xe.input.Path:xe.input.Base
local M = class('xe.input.String', base)
local im = imgui
local wi = require('imgui.Widget')

---@param node xe.SceneNode
function M:ctor(node, idx, wildCard, isFolder)
    base.ctor(self, node, idx, 'path')
    local value = node:getAttrValue(idx) or ''
    self._value = value

    --TODO: use 'res://' if path in project dir
    local btn = wi.Button(require('xe.ifont').FolderOpen, function()
        local dir = require('xe.Project').getDir()
        local path
        if isFolder then
            path = require('platform.FileDialog').pickFolder(dir)
        else
            path = require('platform.FileDialog').open(wildCard, dir)
        end
        if not path or path == '' then
            require('xe.logger').log('File path not set.', 'warn', node:getType())
            return
        end
        self._value = path
        self:submit()
    end)

    self:addChild(btn):addChild(im.sameLine)
    self:addChild(function()
        local txt = self._value
        local popup
        if #txt > 30 then
            txt = txt:sub(1, 27) .. '...'
            popup = true
        end
        im.textWrapped(txt)
        --im.text(txt)
        if popup and im.isItemHovered() then
            im.setTooltip(self._value)
        end
    end)
end

return M
