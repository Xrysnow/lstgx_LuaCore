--TODO
---@class x.launcher:ViewBase
local M = class("MainScene", require('cc.ViewBase'))
local im = imgui
local wi = require('imgui.Widget')

local function createLabel(str, size)
    local lb = cc.Label:createWithSystemFont(str, 'Arial', size or 32)
    local sz = lb:getContentSize()
    local n = cc.Node:create()
    n:setContentSize(cc.p(sz.x, sz.y * 2))
    lb:addTo(n):alignCenter()
    return n
    --return cc.Label:createWithSystemFont(str, 'Arial', size or 32)
end
---
---@param label cc.Label
---@param onClick function
local function createButton(label, onClick)
    local h_pad = 8
    local btn = wi.Widget()
    local node = cc.Node:create()
    node:addChild(label)
    btn:addChild(node)
    btn:setHandler(function()
        local w = im.getWindowWidth() - im.getStyle().WindowPadding.x * 2
        local sz = label:getContentSize()
        local h = sz.y + h_pad
        node:setContentSize(cc.p(w, h))
        label:setPosition(w / 2, h / 2)
        if im.ccNodeButton(node, 0) then
            if onClick then
                onClick()
            end
        end
    end)
    return btn
end

local function getDocking()
    local docking_window_flags = bit.bor(
    --im.WindowFlags.MenuBar,
            im.WindowFlags.NoDocking,
            im.WindowFlags.NoTitleBar,
            im.WindowFlags.NoCollapse,
            im.WindowFlags.NoResize,
            im.WindowFlags.NoMove,
            im.WindowFlags.NoBringToFrontOnFocus,
            im.WindowFlags.NoNavFocus,
            im.WindowFlags.NoBackground
    )
    local id = 0xaaa
    local function f()
        local viewport = im.getMainViewport()
        im.setNextWindowPos(viewport.Pos)
        im.setNextWindowSize(viewport.Size)
        im.setNextWindowViewport(viewport.ID)
        im.pushStyleVar(im.StyleVar.WindowRounding, 0)
        im.pushStyleVar(im.StyleVar.WindowBorderSize, 0)
        im.pushStyleVar(im.StyleVar.WindowPadding, im.p(0, 0))
        im.begin('Dock Space', nil, docking_window_flags)
        im.popStyleVar(3)
        im.dockSpace(id, im.p(0, 0), im.DockNodeFlags.PassthruCentralNode)
        im.endToLua()
    end
    return f, id
end

function M:onCreate()
    local dock_id = 'launcher.dock'
    require('imgui.lstg.util').load(nil, dock_id, true)
    local la = im.get()
    im.show()

    la:addChild(function()
        --im.setNextWindowDockID(im.getID('Dock Space'), im.Cond.Always)
        im.setNextWindowDockID(0x9F5F9276, im.Cond.Always)
    end)

    --la:addChild(im.showDemoWindow)

    local wrapper = wi.styleVar(im.StyleVar.WindowPadding, im.p(0, 0))
    wrapper:addTo(la)

    --wrapper:addChild(function()
    --    local sz = im.getWindowSize()
    --    print(sz.x, sz.y)
    --    --im.setNextWindowSize(sz, im.Cond.Always)
    --    --im.setNextWindowSize(im.vec2(-1, -1), im.Cond.Always)
    --end)

    local win = wi.Window('Launcher')
    win:addTo(wrapper)
    win:setFlags(im.WindowFlags.NoMove, im.WindowFlags.NoTitleBar, im.WindowFlags.NoDecoration)

    --

    --im.getStyle():scaleAllSizes(3)
    win:addChild(function()
        --local sp = im.getStyle().ItemSpacing
        im.pushStyleVar(im.StyleVar.ItemSpacing, im.p(0, 0))
        im.pushStyleVar(im.StyleVar.FramePadding, im.p(0, 0))
    end)

    local c1
    c1 = wi.Widget(function()
        --local w = im.getWindowContentRegionWidth()
        local w = im.getContentRegionAvail().x
        local id = im.getID(tostring(self) .. 'c1')
        local width = w / 3
        if im.beginChildFrame(id, im.p(width, 0), 0) then
            local col = im.getStyleColorVec4(im.Col.WindowBg)
            col.w = 1
            im.pushStyleColor(im.Col.Header, col)
            wi._handler(c1)
            im.popStyleColor()
        end
        im.endChildFrame()
    end)
    local sel = require('imgui.cc.SelectableGroup')()
    sel:setOnSelect(function(_, idx)
        self:_onSel1(idx)
    end)

    self._sel1 = sel

    c1:addChild(sel)
    win:addChild(c1)

    win:addChild(im.sameLine)

    local c2
    c2 = wi.Widget(function()
        --local w = im.getWindowContentRegionWidth()
        local w = im.getContentRegionAvail().x
        local col = im.getStyleColorVec4(im.Col.WindowBg)
        col.w = 1
        im.pushStyleColor(im.Col.FrameBg, col)
        local id = im.getID(tostring(self) .. 'c2')
        local width = w / 3 * 2
        if im.beginChildFrame(id, im.p(width, 0), 0) then
            wi._handler(c2)
        end
        im.endChildFrame()
        im.popStyleColor()
    end)
    local sel2 = require('imgui.cc.SelectableGroup')()
    sel2:setOnSelect(function(_, idx)
        self:_onSel2(idx)
    end)
    self._sel2 = sel2
    c2:addChild(sel2)
    win:addChild(c2)

    win:addChild(function()
        im.popStyleVar(2)
    end)

    self._page_types={ 'mod', 'input', 'sound', 'graph', 'others', 'exit' }
    local title_data = require('platform.launcher_ui_data').title
    for _, v in ipairs(self._page_types) do
        self:_addSel1(i18n(title_data[v]))
    end
    self._label_data = require('platform.launcher_ui_data').label
    self._labels = {}
    local label_holder = cc.Node:create()
    label_holder:addTo(win):setVisible(false)
    for k, v in pairs(self._label_data) do
        local lb = createLabel(i18n(v))
        lb:addTo(label_holder)
        self._labels[k] = lb
    end

    win:addChild(std.bind(self._renderPage, self))

    SystemLog(string.format('will enum mods in %q', plus.getWritablePath() .. 'mod/'))
    self._page_type='mod'
    self:_setMod()
end

--function M:_initData()
--    self._data = {}
--end

function M:_addSel1(text)
    self._sel1:addNode(createLabel(text))
end

function M:_addSel2(text)
    self._sel2:addNode(createLabel(text))
end

function M:_onSel1(idx)
    if idx == #self._page_types then
        -- exit
        --GameExit()
    end
    self._page_type = self._page_types[idx]
    self._sel2:setVisible(idx == 1)
    print(self._page_type)
end

function M:_onSel2(idx)
    if self._page_type == 'mod' then
        --
    end
    print(idx)
end

function M:_setMod()
    self._sel2:setVisible(true)
    local mods = M.enumMods(plus.getWritablePath() .. 'mod/')
    local mod_sel = self._modsel or 0
    for i, v in ipairs(mods) do
        self:_addSel2(v.name)
    end
end

function M:_renderPage()
    local ty = self._page_type
    if ty == 'sound' then
        self:_renderSoundPage()
    end
end

function M:_renderSoundPage()
    im.ccNode(self._labels.volume_bgm)
    local ret, v1, v2 = nil, math.floor(setting.bgmvolume), math.floor(setting.sevolume)
    ret, v1 = im.sliderInt('', v1, 0, 100)
    if ret then
        setting.bgmvolume = v1
    end
    im.ccNode(self._labels.volume_se)
    ret, v2 = im.sliderInt('', v2, 0, 100)
    if ret then
        setting.sevolume = v2
    end
end

function M.enumMods(path)
    return require('platform.util').enumMods(path)
end

function M.saveSetting()
    lstg.saveSettingFile()
end

return M
