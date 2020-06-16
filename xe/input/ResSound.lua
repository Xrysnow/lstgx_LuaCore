local base = require('xe.input.Base')
---@class xe.input.SoundEffect:xe.input.Base
local M = class('xe.input.SoundEffect', base)
local im = imgui
local wi = require('imgui.Widget')
local se_list

---@param node xe.SceneNode
function M:ctor(node, idx)
    base.ctor(self, node, idx, 'sound_effect')
    -- init se_list
    if not se_list then
        se_list = {}
        local sound = require('xe.node_def._checker').getSoundList()
        for k, v in pairs(sound) do
            table.insert(se_list, k)
        end
        table.sort(se_list)
        for i = 1, #se_list do
            se_list[i] = { se_list[i], sound[se_list[i]] }
        end
    end

    local list = table.clone(se_list)
    local watch = require('xe.TreeHelper').watch.sound
    for k, _ in pairs(watch) do
        local name = k:getAttrValue(2)
        local path = k:getAttrValue(1)
        table.insert(list, { name, path })
    end
    table.sort(list, function(a, b)
        return a[1] < b[1]
    end)
    self._list = list

    local map = {}
    for i, v in ipairs(list) do
        map[v[1]] = { i, v[2] }
    end
    local value = self:getEditValue()
    if not map[value] then
        value = node:getDefaultAttrValue(idx)
    end
    if not map[value] then
        value = se_list[1][1]
    end
    self._value = value
    self._sel = map[value][1]
    self._path = map[value][2]

    self._nameFilter = require('imgui.TextFilter')()
    self._curPage = 1
    self._perPage = 10

    local btn, selector
    btn = wi.Button('', function()
        if btn:getDir() == im.Dir.Down then
            btn:setDir(im.Dir.Up)
            selector:setVisible(true)
        else
            btn:setDir(im.Dir.Down)
            selector:setVisible(false)
        end
    end, im.Dir.Down, 'arrow')
    selector = wi.Widget(function()
        self:_render()
    end)
    selector:setVisible(false)
    self:addChild(btn):addChild(im.sameLine):addChild(function()
        im.text(self._value)
    end):addChild(selector)
end

function M:_render()
    local ret, filter_changed
    local last = self._sel

    ret = self._nameFilter:inputText('Filter')
    if ret then
        filter_changed = true
    end

    if filter_changed then
        self._curPage = 1
    end

    local list = self._list
    local filtered = {}
    for i, v in ipairs(list) do
        if self._nameFilter:filter(v[1]) then
            table.insert(filtered, v)
        end
    end
    local npage = 1
    if #filtered > 0 then
        npage = math.ceil(#filtered / self._perPage)
    end
    if self._curPage > npage then
        self._curPage = npage
    end
    local lo = (self._curPage - 1) * self._perPage + 1
    local hi = lo + self._perPage - 1

    local hh = im.getTextLineHeightWithSpacing() * self._perPage + im.getStyle().ItemSpacing.y
    im.beginChildFrame(im.getID(tostring(self)), im.vec2(0, hh))

    for i = lo, math.min(#filtered, hi) do
        local v = filtered[i]
        im.pushID(i)
        if im.selectable(v[1],
                         self._sel == i,
                         im.SelectableFlags.SpanAllColumns) then
            self._sel = i
        end
        im.popID()
    end
    for i = #filtered + 1, hi do
        im.selectable('', false, im.SelectableFlags.Disabled)
    end

    im.endChildFrame()

    local sel = self._sel
    if sel ~= last then
        self._value = list[sel][1]
        self._path = list[sel][2]
        self:submit()
        --TODO: play on select
    end

    --im.separator()
    -- page slider
    if npage > 1 then
        im.setNextItemWidth(-1)
        ret, self._curPage = im.sliderInt('##', self._curPage, 1, npage)
    end
end

return M
