local base = require('imgui.Widget')
---@class xe.Setting:im.Widget
local M = class('xe.Setting', base)
local im = imgui
local wi = base

function M:ctor()
    base.ctor(self)
    self._var = {}
    self._cheat = false
    self._resx = 1280
    self._resy = 960
    self._fullscreen = false
    --
    self:push()
    self:addChild(function()
        local sz = im.vec2(-1, -im.getFrameHeightWithSpacing())
        if im.beginChildFrame(im.getID('xe.setting.content'), sz) then
            local ret
            local tmp = self._tmp
            ret, tmp.cheat = im.checkbox('Cheat', tmp.cheat)
            ret, tmp.fullscreen = im.checkbox('Full screen', tmp.fullscreen)
            if not tmp.fullscreen then
                ret, tmp.resx = im.inputInt('Width', tmp.resx)
                ret, tmp.resy = im.inputInt('Height', tmp.resy)
            end
            im.endChildFrame()
        end
    end)

    local ok = wi.Button('OK', std.bind(self._ok, self))
    local cancel = wi.Button('Cancel', std.bind(self._cancel, self))
    self:addChildren(ok, im.sameLine, cancel)
end

function M:_ok()
    self:pop()
    self:setVisible(false)
end

function M:_cancel()
    self:setVisible(false)
end

function M:push()
    -- push temp values
    self._tmp = {
        cheat      = self._cheat,
        resx       = self._resx,
        resy       = self._resy,
        fullscreen = self._fullscreen,
    }
end

function M:pop()
    -- pop temp values
    local tmp = self._tmp
    self._cheat = tmp.cheat
    self._resx = tmp.resx
    self._resy = tmp.resy
    self._fullscreen = tmp.fullscreen
end

function M:setCheat(v)
    self._cheat = v
end

function M:getCheat()
    return self._cheat
end

function M:setGameRes(x, y)
    self._resx = x
    self._resy = y
end

function M:getGameRes()
    return self._resx, self._resy
end

function M:isFullscreen()
    return self._fullscreen
end

local _id = 'Setting'
function M:_handler()
    im.setNextWindowSize(im.vec2(200, 200), im.Cond.Once)
    im.openPopup(_id)
    if im.beginPopupModal(_id) then
        wi._handler(self)
        im.endPopup()
    end
end

local function get_ins()
    return require('xe.main'):getInstance()._setting
end

function M:show()
    if self == nil or self == M then
        self = get_ins()
    end
    self:push()
    self:setVisible(true)
    return self
end

function M.setVar(k, v)
    local ins = get_ins()
    ins._var[k] = v
end

function M.getVar(k)
    local ins = get_ins()
    return ins._var[k]
end

function M.save()
    local path = require('xe.Project').getDir()
    if not path then
        return
    end
    --TODO: save to json
    local ins = get_ins()
end

return M
