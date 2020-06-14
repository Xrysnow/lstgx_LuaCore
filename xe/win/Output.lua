local base = require('imgui.widgets.Window')
---@class xe.Output:im.Window
local M = class('xe.Output', base)
local im = imgui
local wi = require('imgui.Widget')

function M:ctor()
    base.ctor(self, 'Output')
    self._lines = {}
    self._max = 100

    local ifont = require('xe.ifont')
    local map = {
        Info    = { ifont.InfoCircle, im.color(77, 144, 255) },
        Warning = { ifont.ExclamationCircle, im.color(255, 200, 0) },
        Error   = { ifont.TimesCircle, im.color(233, 66, 66) },
    }
    map.info = map.Info
    map.warning = map.Warning
    map.warn = map.Warning
    map.error = map.Error
    map.erro = map.Error

    local fsize = im.getFontSize()
    local btn_clear = wi.Button(ifont.TrashAlt, function()
        self:clear()
    end, im.vec2(fsize, fsize))
    self:addChild(btn_clear)
    self:addChild(function()
        if im.listBoxHeader('##', im.vec2(-1, -1)) then
            local lines = self._lines
            local n = #lines
            for i = 1, n do
                local str, typ = lines[i][1], lines[i][2]
                if typ then
                    if map[typ] then
                        im.textColored(map[typ][2], map[typ][1])
                        im.sameLine()
                        str = ' ' .. str
                    else
                        str = ('[%s] %s'):format(typ, str)
                    end
                end
                im.text(str)
            end
            im.listBoxFooter()
        end
    end)
    --TODO: trace
end

function M:addLine(str, typ)
    table.insert(self._lines, { str or '', typ })
    if #self._lines > self._max then
        table.remove(self._lines, 1)
    end
end

function M:clear()
    self._lines = {}
end

return M
