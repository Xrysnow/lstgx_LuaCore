---@class ui.FilePicker:ccui.Layout
local M = class('ui.FilePicker', ccui.Layout)
local margin = 6

function M:ctor(filter, default_path, is_save, input_size, btn_size)
    input_size = input_size or cc.size(100, 22)
    btn_size = btn_size or cc.size(72, 22)
    local sz = cc.size(
            input_size.width + btn_size.width + margin * 3,
            math.max(input_size.height, btn_size.height) + margin * 2
    )
    self:setContentSize(sz)
    --self:setBackGroundColorType(1):setBackGroundColor(cc.c3b(2555, 200, 200))

    local input = require('cc.ui.prefab.EditBox').String(input_size)
    input:addTo(self):alignLeft(margin):alignVCenter()
    self._eb = input

    local fd = require('platform.FileDialog')
    local func = is_save and fd.save or fd.open
    local btn = require('cc.ui.button').Button1(btn_size, function()
        local path = func(filter, default_path)
        if path then
            self._eb:setString(0, path)
        end
    end, 'Browse')
    btn:addTo(self):alignRight(margin):alignVCenter()
    self._btn = btn
end

function M:getEditBox()
    return self._eb
end

function M:getButton()
    return self._btn
end

return M
