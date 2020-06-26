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

    local ifont = require('xe.ifont')
    local create = require('xe.util').createTextButton
    local padding = im.vec2(8, 8)
    local col_run = im.color(54, 160, 82, 255)
    local col_stop = im.color(216, 30, 6, 255)
    local col_pause = im.color(224, 110, 6, 255)
    local col_step = im.color(34, 136, 230, 255)
    local col_step_over = im.color(34, 136, 230, 255)

    self._btns.run = { create(ifont.Play, padding, nil, col_run) }
    self._btns.stop = { create(ifont.Stop, padding, nil, col_stop) }
    self._btns.pause = { create(ifont.Pause, padding, nil, col_pause) }
    self._btns.step = { create(ifont.StepForward, padding, nil, col_step) }
    self._btns.step_over = { create(ifont.FastForward, padding, nil, col_step_over) }

    local names = { 'run', 'stop', 'pause', 'step', 'step_over' }
    for i, v in ipairs(names) do
        self._btns[v][1]:addTo(self)
        self._btns[v][2]:addTo(self)
        if i < #names then
            self:addChild(im.sameLine)
        end
    end
    --TODO

    SetOffscreen(true)
    local cw = wi.ChildWindow('xe.gameview'):addTo(self)
    cw:addChild(function()
        self:_render()
    end)
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

function M:_renderButtons()

end

return M
