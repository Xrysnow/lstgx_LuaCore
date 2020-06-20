local base = require('xe.input.Base')
---@class xe.input.Path:xe.input.Base
local M = class('xe.input.String', base)
local im = imgui
local wi = require('imgui.Widget')
local log = require('xe.logger').log
local _res = {
    loadsound      = true,
    loadbgm        = true,
    loadimage      = true,
    loadtexture    = true,
    loadimagegroup = true,
    loadani        = true,
    loadparticle   = true,
    loadFX         = true, }

---@param node xe.SceneNode
function M:ctor(node, idx, wildCard, isFolder)
    base.ctor(self, node, idx, 'path')
    local value = node:getAttrValue(idx) or ''
    self._value = value
    local nt = node:getType()

    --TODO: use 'res://' if path in project dir
    --TODO: copy file if not in project dir
    local btn = wi.Button(require('xe.ifont').FolderOpen, function()
        local dir = require('xe.Project').getDir()
        local path
        if isFolder then
            path = require('platform.FileDialog').pickFolder(dir)
        else
            path = require('platform.FileDialog').open(wildCard, dir)
        end
        if not path or path == '' then
            log('File path not set', 'warn', nt)
            return
        end
        self._value = path
        if _res[nt] then
            -- set res name to file name
            local prop = require('xe.main').getProperty()
            prop:setValue(2, string.filename(path))
            if nt == 'loadparticle' then
                local f, msg = io.open_u8(path, 'rb')
                if f == nil then
                    log(msg, "error", nt)
                else
                    local s = f:read(1)
                    f:close()
                    prop:setValue(3, 'parimg' .. (s:byte(1) + 1))
                end
            end
        end
        self:submit()
    end)

    self:addChild(btn):addChild(im.sameLine)
    self:addChild(function()
        local txt = self._value
        local popup
        if #txt > 30 then
            txt = '...' .. txt:sub(-27, -1)
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
