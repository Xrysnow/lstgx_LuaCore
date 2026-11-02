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
    self:enableNodeEvents()
    local weak = setmetatable({ self }, { __mode = 'v' })
    local btn = require('cc.ui.button').Button1(btn_size, function()
        if lstg.GetPlatform() == 'android' then
            if self._request then return end
            local function completed(result)
                local owner = weak[1]
                if not owner or not owner._request or owner._request ~= result.requestId then return end
                owner._request = nil
                if result.status == 'success' and not is_save then
                    owner._eb:setString(0, result.path)
                elseif result.status ~= 'cancelled' then
                    print(('document %s: %s'):format(result.status, result.message or ''))
                end
            end
            local id, err
            if is_save then
                -- A mobile export copies the existing source shown in the field.
                local source = self._eb:getString(0)
                id, err = fd.exportAsync(source, source:match('[^/\\]+$') or '', nil, completed)
            else
                id, err = fd.importAsync('*/*', completed)
            end
            self._request = id
            if not id then print(err) end
        else
            local path = func(filter, default_path)
            if path then
                self._eb:setString(0, path)
            end
        end
    end, 'Browse')
    btn:addTo(self):alignRight(margin):alignVCenter()
    self._btn = btn
end

function M:onExit()
    local id = self._request
    self._request = nil
    if id then require('platform.FileDialog').cancel(id) end
end

function M:getEditBox()
    return self._eb
end

function M:getButton()
    return self._btn
end

return M
