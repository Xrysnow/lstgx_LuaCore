local base = require('imgui.Widget')
---@class xe.GameView:im.Widget
local M = class('xe.GameView', base)
local im = imgui
local wi = base

function M:ctor()
    base.ctor(self)
    self._scale = 0
    ---@type table<string,im.Widget[]>
    self._btns = {}

    self._pos1 = im.vec2(0, 0)
    self:addChild(function()
        local pos = im.getCursorPos()
        self._pos1 = pos
    end)

    local ifont = require('xe.ifont')
    local create = require('xe.util').createTextButton
    local padding = im.vec2(8, 8)
    local col_run = im.color(54, 160, 82, 255)
    local col_stop = im.color(216, 30, 6, 255)
    local col_pause = im.color(224, 110, 6, 255)
    local col_step = im.color(34, 136, 230, 255)
    local col_step_over = im.color(34, 136, 230, 255)

    local _vars = {
        [im.StyleVar.FramePadding] = padding,
    }
    local _trans = im.vec4(0, 0, 0, 0)
    local _colors = {
        [im.Col.Button]        = _trans,
        [im.Col.ButtonActive]  = _trans,
        [im.Col.ButtonHovered] = _trans,
        [im.Col.Text]          = _trans,
        [im.Col.Border]        = _trans,
    }
    local invisible = wi.style(_colors, _vars)
    invisible:addChild(wi.Button(ifont.Play))
    self:addChild(invisible):addChild(im.sameLine)

    self:addChild(function()
        local pos = im.getCursorPos()
        local ww = im.getWindowWidth()
        local dx = math.max(pos.x - self._pos1.x, 0)
        local dw = math.max((ww - dx * 5) / 2, 0)
        local p = im.vec2(self._pos1.x + dw, pos.y)
        im.setCursorPos(p)
    end)

    self._btns.run = { create(ifont.Play, padding, std.bind(self._run, self), col_run) }
    self._btns.stop = { create(ifont.Stop, padding, std.bind(self._stop, self), col_stop) }
    self._btns.pause = { create(ifont.Pause, padding, std.bind(self._pause, self), col_pause) }
    self._btns.step = { create(ifont.StepForward, padding, std.bind(self._step, self), col_step) }
    self._btns.step_over = { create(ifont.FastForward, padding, std.bind(self._step_over, self), col_step_over) }

    local names = { 'run', 'stop', 'pause', 'step', 'step_over' }
    for i, v in ipairs(names) do
        self._btns[v][1]:addTo(self):addChild(im.sameLine)
        self._btns[v][2]:addTo(self):addChild(im.sameLine)
    end
    self:_setEnable(false, true, true, false, false)

    self:addChild(function()
        im.text('')
        -- note: visible state should set after render
        self:_applyEnable()
    end)

    SetOffscreen(true)
    local cw = wi.ChildWindow('xe.gameview'):addTo(self)
    cw:addChild(function()
        self:_render()
    end)
end

function M:_run()
    self:_setEnable(false, true, true, false, false)
    require('xe.game').resume()
end

function M:_stop()
    self:_setEnable(true, true, true, false, false)
    require('xe.game').stop()
end

function M:_pause()
    self:_setEnable(true, true, false, true, true)
    require('xe.game').pause()
end

function M:_step()
    self:_setEnable(false, false, false, false, false)
    require('xe.game').step(1, function()
        self:_setEnable(true, true, false, true, true)
    end)
end

function M:_step_over()
    self:_setEnable(false, false, false, false, false)
    require('xe.game').step(10, function()
        self:_setEnable(true, true, false, true, true)
    end)
end

function M:_setEnable(run, stop, pause, step, step_over)
    self._states = { run, stop, pause, step, step_over }
end

function M:_applyEnable()
    local states = self._states
    local names = { 'run', 'stop', 'pause', 'step', 'step_over' }
    for i = 1, #names do
        local v = self._btns[names[i]]
        if v then
            local enable = states[i]
            v[1]:setVisible(enable)
            v[2]:setVisible(not enable)
        end
    end
end

function M:_render()
    local rt = GetFrameBuffer()
    if not rt then
        return
    end
    local sz = im.getWindowSize()
    local sp = rt:getSprite()
    local spsz = sp:getContentSize()
    spsz = cc.p(spsz.width, spsz.height)
    local scale
    if sz.x / sz.y > spsz.x / spsz.y then
        scale = sz.y / spsz.y
    else
        scale = sz.x / spsz.x
    end
    scale = math.floor(scale * 16) / 16
    self._scale = scale

    local size = cc.pMul(spsz, scale)
    local dx = (sz.x - size.x) / 2
    local dy = (sz.y - size.y) / 2
    local p = im.getCursorScreenPos()
    local a = cc.pAdd(p, cc.p(dx, dy))
    local b = cc.pAdd(a, size)
    local dl = im.getWindowDrawList()
    dl:addRectFilled(a, b, im.colorConvertFloat4ToU32(im.vec4(0, 0, 0, 1)))
    -- flip verticle
    a, b = cc.p(a.x, b.y), cc.p(b.x, a.y)
    dl:addImage(sp, a, b)
end

return M
