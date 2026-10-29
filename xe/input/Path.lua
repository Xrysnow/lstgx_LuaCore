local base = require('xe.input.Base')
---@class xe.input.Path:xe.input.Base
local M = class('xe.input.Path', base)
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

    local btn = wi.Button(require('xe.ifont').FolderOpen, function()
        self:_open(wildCard, isFolder)
    end)

    self:addChild(btn):addChild(im.sameLine)

    local nt = node:getType()
    if nt == 'loadimage' then
        self:addChild(wi.Button(require('xe.ifont').FolderOpen, function()
            local path = self._value
            require('xe.image.util').create(path:filename(), path)
        end))
    end

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

function M:_open(wildCard, isFolder)
    local nt = self._node:getType()

    local dir = require('xe.Project').getDir()
    local path = ''
    if isFolder then
        path = require('platform.FileDialog').pickFolder(dir)
    else
        path = require('platform.FileDialog').open(wildCard, dir)
    end
    if not path or path == '' then
        log('file path not set', 'warn', nt)
        return
    end

    if dir:sub(-1) ~= '/' then
        dir = dir .. '/'
    end
    local fu = cc.FileUtils:getInstance()
    if not path:starts_with(dir) then
        -- need copy
        local target = dir .. path:filename(true)
        if fu:isFileExist(target) then
            log(('file %s already exists'):format(path:filename(true)), 'warn')
        else
            if jit.os == 'Windows' then
                os.execute(('copy /Y "%s" "%s"'):format(
                        fu:getSuitableFOpen(path):gsub('/', '\\'),
                        fu:getSuitableFOpen(dir)))
            else
                os.execute(('cp "%s" "%s"'):format(path, target))
            end
        end
        path = target
    end
    if path:starts_with(dir) then
        path = path:sub(#dir + 1)
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
end

return M
