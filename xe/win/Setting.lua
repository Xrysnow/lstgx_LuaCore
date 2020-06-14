local base = require('imgui.widgets.Window')
---@class xe.Setting:im.Window
local M = class('xe.Setting', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'Setting')
    self._var = {}
    self._cheat = false
    self._resx = 1280
    self._resy = 960
    self._fullscreen = false
    --
    self:push()
    self:addChild(function()
        local ret
        local tmp = self._tmp
        ret, tmp.cheat = im.checkbox('Cheat', tmp.cheat)
        ret, tmp.fullscreen = im.checkbox('Full screen', tmp.fullscreen)
        if not tmp.fullscreen then
            ret, tmp.resx = im.inputInt('Width', tmp.resx)
            ret, tmp.resy = im.inputInt('Height', stmp.resy)
        end
    end)
    self:addChild(wi.Button('OK', function()
        self:pop()
        self:setVisible(false)
    end))
    self:addChild(im.sameLine)
    self:addChild(wi.Button('Cancel', function()
        self:setVisible(false)
    end))
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

function M:setGameWindowed(v)
    self._fullscreen = not v
end

function M:getGameWindowed()
    return not self._fullscreen
end

local function get_ins()
    return require('xe.main'):getInstance()._setting
end

function M.show(self)
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
