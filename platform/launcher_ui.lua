---
---
--- launcher_ui.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---


local FU = cc.FileUtils:getInstance()
local glv = cc.Director:getInstance():getOpenGLView()
local launcher_reader
---@type cc.Scene
local launcher_scene
local lc

--local ASSETS_PATH = 'src/mod/demo/assets/'
--local px          = ASSETS_PATH .. 'pixel.png'
--local wqy         = ASSETS_PATH .. 'font/WenQuanYiMicroHeiMono.ttf'

local function enumMods(path)
    SystemLog(string.format('enum MODs in %q', path))
    local ret = {}
    local files = plus.EnumFiles(path)
    for i, v in ipairs(files) do
        if v.isDirectory then
            if plus.FileExists(path .. v.name .. '/root.lua') then
                table.insert(ret, v)
            end
        else
            if string.lower(v.name:match(".+%.(%w+)$") or '') == 'zip' then
                v.name = v.name:sub(1, -5)
                assert(v.name ~= '')
                table.insert(ret, v)
            end
        end
    end
    table.sort(ret, function(a, b)
        if a.isDirectory ~= b.isDirectory then
            return a.isDirectory
        end
        return a.name < b.name
    end)
    return ret
end

local function saveSetting()
    lstg.saveSettingFile()
end

local contents = {
    'mod',
    'sound',
    'graph',
    'input',
    'others',
}
local function hideContents()
    if not lc then
        return
    end
    for _, v in ipairs(contents) do
        lc[v]:setVisible(false)
    end
end
local function unsel_btns()
    for _, v in ipairs(contents) do
        lc['btn_' .. v]:setColor(cc.c3b(51, 51, 51))
    end
end

local getChildrenWithName = require('cc.children_helper').getChildrenWithName
--local getChildrenGraph = require('cc.children_helper').getChildrenGraph
local createItem = require('cc.selectable_item').create

local function createModItem()
    return createItem(cc.size(800, 80), nil, nil, 60)
end

local scene_tasks = {}

--

local function setMod(lc)
    local mod_scv = lc.mod_scv
    mod_scv:setLayoutType(ccui.LayoutType.VERTICAL)
    for i, v in ipairs(enumMods(plus.getWritablePath() .. 'mod/')) do
        local item = createModItem()
        item.mod_name = v.name
        item.mod_info = v
        item.lb:setString(v.name or 'UNKNOWEN')
        if v.isDirectory then
            item.lb:setColor(cc.c3b(255, 255, 127))
        end
        item.btn:addTouchEventListener(function(t, e)
            if e == 0 then
                if not item.is_selected then
                    for _, v in ipairs(lc.mod_scv:getChildren()) do
                        if v.setSelected then
                            v:setSelected(false)
                        end
                    end
                    setting.mod = item.mod_name
                    setting.mod_info = item.mod_info
                    --SystemLog('set setting.mod to ' .. setting.mod)
                end
                --item:setSelected(not item.is_selected)
                item:setSelected(true)
                lc.mod_start_btn:setVisible(true)
            end
        end)

        mod_scv:addChild(item)
        local num = mod_scv:getChildrenCount()
        mod_scv:setInnerContainerSize(cc.size(800, num * 80))
    end

    lc.mod_start_btn:setVisible(false)
    lc.mod_start_btn:addClickEventListener(function()
        -- require here, make it can be override
        local scene = require('app.views.GameScene'):create(nil, setting.mod)
        saveSetting()
        lstg.loadMod()
        if lstg._exlauncher then
            SystemLog('use external launcher')
            scene:showWithScene()
        else
            require('platform.launcher2_ui')()
        end
    end)
end

local function setSound(lc)
    lc.mute_content:setVisible(false)--TODO
    lc.bgm_sl:setPercent(math.floor(setting.bgmvolume))
    lc.se_sl:setPercent(math.floor(setting.sevolume))
    lc.bgm_lb:setString(string.format('%d%%', setting.bgmvolume))
    lc.se_lb:setString(string.format('%d%%', setting.sevolume))
    lc.bgm_sl:addEventListener(function(t, e)
        if e == 0 then
            setting.bgmvolume = lc.bgm_sl:getPercent()
            lc.bgm_lb:setString(string.format('%d%%', setting.bgmvolume))
        end
    end)
    lc.se_sl:addEventListener(function(t, e)
        if e == 0 then
            setting.sevolume = lc.se_sl:getPercent()
            lc.se_lb:setString(string.format('%d%%', setting.sevolume))
        end
    end)
end

local function setGraph(lc)
    --note: set selection by togglegroup
    local ratio = setting.res_ratio[1] / setting.res_ratio[2]
    local tgname = 'res_ratio_tg'
    for i, v in ipairs({ { 16, 9 }, { 4, 3 } }) do
        local tg = lc[tgname .. i]
        if ratio == v[1] / v[2] then
            lc[tgname .. 'g']:setSelectedButtonWithoutEvent(tg)
        end
        tg:addEventListener(function(t, e)
            if e == 0 then
                setting.res_ratio = v
                if plus.isDesktop() then
                    --glv:setFrameSize(setting.windowsize_w, setting.windowsize_h)
                    ChangeVideoMode(
                            setting.windowsize_w,
                            setting.windowsize_h,
                            setting.windowed,
                            setting.vsync
                    )
                end
            end
        end)
    end

    tgname = 'res_tg'
    for i, v in ipairs({ 960, 720, 480 }) do
        local tg = lc[tgname .. i]
        if setting.resy == v then
            lc[tgname .. 'g']:setSelectedButtonWithoutEvent(tg)
        end
        tg:addEventListener(function(t, e)
            if e == 0 then
                setting.resy = v
            end
        end)
    end

    lc.pe_tg:setSelected(setting.posteffect == true)
    lc.pe_tg:addEventListener(function(t, e)
        if e == 0 then
            setting.posteffect = true
        elseif e == 1 then
            setting.posteffect = false
        end
    end)
    lc.vsync_tg:setSelected(setting.vsync == true)
    lc.vsync_tg:addEventListener(function(t, e)
        if e == 0 then
            setting.vsync = true
        elseif e == 1 then
            setting.vsync = false
        end
    end)

    lc.fps_tg1:setSelected(setting.render_skip == 0)
    lc.fps_tg1:addEventListener(function(t, e)
        if e == 0 then
            setting.render_skip = 0
            SetFPS(60)
        end
    end)
    lc.fps_tg2:setSelected(setting.render_skip == 1)
    lc.fps_tg2:addEventListener(function(t, e)
        if e == 0 then
            setting.render_skip = 1
            SetFPS(30)
        end
    end)
end

local ctr_btns = {
    'up',
    'down',
    'left',
    'right',
    'shoot',
    'slow',
    'spell',
    'special',
    'menu',
    'repfast',
    'repslow',
    'snapshot',
}
local ctr_labels = {}
local controllerHelper = require('platform.ControllerHelper')

---@type table
local ctr_last, ctr_curr
local function listenCtrStart()
    ctr_last = nil
    ctr_curr = nil
    scene_tasks[1] = function()
        --local k = GetLastControllerKey()
        --if k and k.iKey then
        --    if ctr_labels._set then
        --        ctr_labels._set(k)
        --    end
        --end
        --ctr_last = ctr_curr
        ctr_curr = controllerHelper.getLast()
        if ctr_curr then
            ctr_labels._set(ctr_last, ctr_curr)
        end
        --if ctr_curr and (not ctr_curr.is_axis) then
        --    ctr_last = ctr_curr
        --end
        --if ctr_last and ctr_curr then
        --    local b1 = ctr_last.id == ctr_curr.id
        --    local b2 = ctr_last.key == ctr_curr.key
        --    local b3 = ctr_last.is_axis == ctr_curr.is_axis
        --    --local b4 = ctr_last.isAnalog == ctr_curr.isAnalog
        --    local b = b1 and b2 and b3-- and b4
        --    if ctr_labels._set and b then
        --        ctr_labels._set(ctr_last, ctr_curr)
        --    end
        --end
    end
end
local function listenCtrStop()
    scene_tasks[1] = nil
end

local function unsel_ctr_btns(lc)
    for _, v in ipairs(ctr_btns) do
        lc['btn_ctr_' .. v]:setSelect(false)
    end
    listenCtrStop()
end

local function setInput(lc)
    local kset = controllerHelper.convertSetting()
    for _, v in ipairs(ctr_btns) do
        local btn = lc['btn_ctr_' .. v]
        if not btn then
            error('setInput: cannot find label')
        end
        local str = 'N/A'
        local kc = kset[v] and kset[v][1]
        if kc then
            kc = kc >= 1000 and (kc - 1000) or kc
            local s = 'key %d'
            if kset[v][2] ~= nil then
                s = kset[v][2] and 'axis %d +' or 'axis %d -'
            end
            str = string.format(s, kc)
        end
        local label = cc.Label:createWithSystemFont(str, 'Arial', 36)
        ctr_labels[v] = label
        btn:addChild(label)
        local size = btn:getContentSize()
        label:setPosition(cc.p(size.width / 2, size.height / 2))

        btn._sel = false
        btn.setSelect = function(self, b)
            if b == self._sel then
                return
            end
            if b then
                self:setColor(cc.c3b(127, 127, 0))
                unsel_ctr_btns(lc)
                listenCtrStart()
                ctr_labels._set = function(_last, _curr)
                    --local keyCode = _last.key
                    local keyCode = _curr.key
                    if keyCode < 0 then
                        error('wrong key code')
                    end
                    --local positive = true
                    --if _last.isAnalog then
                    --    positive = _last.value < _curr.value
                    --end
                    controllerHelper.setMapping(v, keyCode, _curr.is_axis, _curr.is_pos)
                    --local k_ = keyCode >= 1000 and (keyCode - 1000) or keyCode
                    local s = 'key %d'
                    --if _last.isAnalog then
                    --    s = positive and 'axis %d +' or 'axis %d -'
                    --end
                    if _curr.is_axis then
                        s = _curr.is_pos and 'axis %d +' or 'axis %d -'
                    end
                    s = string.format(s, keyCode)
                    label:setString(s)
                    self:setSelect(false)
                    listenCtrStop()
                end
            else
                self:setColor(cc.c3b(51, 51, 51))
            end
            self._sel = b
        end
        btn:addClickEventListener(function()
            btn:setSelect(not btn._sel)
        end)
    end
end

local function setOthers(lc)
    if plus.isMobile() then
        local tg = (setting.orientation == 'landscape') and lc.ori_tg1 or lc.ori_tg2
        lc.ori_tgg:setSelectedButtonWithoutEvent(tg)
        lc.ori_tg1:addEventListener(function(t, e)
            if e == 0 then
                setting.orientation = 'portrait'
            end
        end)
        lc.ori_tg2:addEventListener(function(t, e)
            if e == 0 then
                setting.orientation = 'landscape'
            end
        end)

        lc.touchkey_tg:setSelected(setting.touchkey == true)
        lc.touchkey_tg:addEventListener(function(t, e)
            if e == 0 then
                setting.touchkey = true
            elseif e == 1 then
                setting.touchkey = false
            end
        end)

        lc.winsize_content:setVisible(false)
    else
        local tgname = 'winsize_tg'
        --glv:setFrameSize(setting.windowsize_w, setting.windowsize_h)
        ChangeVideoMode(
                setting.windowsize_w,
                setting.windowsize_h,
                setting.windowed,
                setting.vsync
        )
        for i, v in ipairs({ 960, 720, 480 }) do
            local tg = lc[tgname .. i]
            if setting.windowsize_h == v and setting.windowed then
                lc[tgname .. 'g']:setSelectedButtonWithoutEvent(tg)
            end
            tg:addEventListener(function(t, e)
                if e == 0 then
                    setting.windowsize_h = v
                    --glv:setFrameSize(setting.windowsize_w, v)
                    setting.windowed = true
                    ChangeVideoMode(
                            setting.windowsize_w,
                            v,
                            setting.windowed,
                            setting.vsync
                    )
                end
            end)
        end
        local tg = lc['winsize_tg4']
        if not setting.windowed then
            lc[tgname .. 'g']:setSelectedButtonWithoutEvent(tg)
        end
        tg:addEventListener(function(t, e)
            if e == 0 then
                --glv:setFrameSize(setting.windowsize_w, v)
                setting.windowed = false
                ChangeVideoMode(
                        setting.windowsize_w,
                        setting.windowsize_h,
                        setting.windowed,
                        setting.vsync
                )
            end
        end)

        lc.touchkey_content:setVisible(false)
        lc.ori_content:setVisible(false)
    end
    setting.windowsize_h = setting.windowsize_h
    setting.res_ratio = setting.res_ratio
end

local function CreateLauncherUI()
    if launcher_reader then
        return
    end
    assert(setting)
    launcher_reader = creator.CreatorReader:createWithFilename('creator/Scene/launcher.ccreator')
    launcher_reader:setup()
    launcher_scene = launcher_reader:getSceneGraph()
    launcher_scene:setName('launcher_scene')
    lc = getChildrenWithName(launcher_scene)
    --SystemLog(stringify(c))
    --SystemLog(tostring(c.sound.active))
    hideContents()
    unsel_btns()

    local sel_color = cc.c3b(128, 128, 64)
    for _, v in ipairs(contents) do
        local btn = lc['btn_' .. v]
        btn:addClickEventListener(function()
            hideContents()
            unsel_btns()
            lc[v]:setVisible(true)
            btn:setColor(sel_color)

            unsel_ctr_btns(lc)
        end)
    end

    lc.btn_exit:addClickEventListener(function()
        hideContents()
        if GameExit then
            GameExit()
        else
            saveSetting()
            os.exit()
        end
    end)

    setMod(lc)

    setSound(lc)

    setGraph(lc)

    setInput(lc)

    setOthers(lc)

    local inf = 'LuaSTG-x Technical Preview'
    if plus.platform ~= 'unknown' then
        inf = string.format('%s for %s', inf, plus.platform)
    end
    local inf_label = lc._warning:getChildren()[1]
    inf_label:setString(inf)
    --lc._warning:setVisible(false)
    --print('---------------     load     ----------------')
    --local m=cc.Sprite3D:create('mod/obj_bindnode_test/model/out7.c3b')
    --if not m then
    --    error("can't load")
    --end
    --m:setPosition(cc.p(500,100))
    --m:setScale(20)
    --launcher_scene:addChild(m)
    --m:setGlobalZOrder(10)

    --local p=cc.ParticleSystemQuad:create('particle_texture.plist')
    --if not p then
    --    error("can't load")
    --end
    --p:setPosition(cc.p(800,100))
    --launcher_scene:addChild(p)

    -- local font = 'x/assets/font/WenQuanYiMicroHeiMono.ttf'
    -- local debug_lb = cc.Label:createWithTTF('_', font, 24)
    -- launcher_scene:addChild(debug_lb)
    -- debug_lb:setPosition(cc.p(200, 200))
    -- debug_lb:setGlobalZOrder(9)

    --[[
    launcher_scene:removeAllChildren()

    local model = l2d.Model:create('kagerou', 'kagerou.model3.json')
    --local model = l2d.Model:create('Haru', 'Haru.model3.json')
    if not model then
        error('failed')
    end
    --Print(stringify(model:getContentSize()))
    model:setPosition(cc.p(500, 600))
    model:setScale(2)
    model:setGlobalZOrder(10)
    Print(stringify(model:getContentSize()))
    model:setDebugRectEnable(true)

    model:setTouchEnabled(true)
    model:setSwallowTouches(true)
    model:addTouchEventListener(function(sender, e)
        if e == ccui.TouchEventType.began then
            --local pos = model:getTouchBeganPosition()
            --Print(pos.x, pos.y)
            return true
        elseif e == ccui.TouchEventType.moved then
            local pos = model:getTouchMovePosition()
            model:setDragging(pos.x, pos.y)
        elseif e == ccui.TouchEventType.ended then
            local pos = model:convertToWorldSpace(cc.p(0, 0))
            model:setDragging(pos.x, pos.y)
        elseif e == ccui.TouchEventType.canceled then
            local pos = model:convertToWorldSpace(cc.p(0, 0))
            model:setDragging(pos.x, pos.y)
        end
    end)
    model:addClickEventListener(function()
        local pos = model:getTouchEndPosition()
        if model:areaHitTest('Head', pos.x, pos.y) then
            Print('hit at head')
        end
    end)

    --local dsize=cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    --Print(dsize.width,dsize.height)

    --model:setOnHitCallback(function(x, y)
    --    Print('hit', x, y)
    --    if model:hitTest('Head', x, y) then
    --        Print('hit at', x, y)
    --        model:setRandomExpression()
    --    end
    --end)
    --model:setOnDraggingCallback(function(x, y)
    --    model:setDragging(x, y)
    --end)
    --model:startRandomMotion('Idle',1)

    launcher_scene:addChild(model)
    Print(stringify(model:getCanvasRect()))
    ]]

    launcher_scene.update = function(self, dt)
        for i, v in pairs(scene_tasks) do
            v()
        end

        --local last = controllerHelper.getLast()
        --local str = 'nil'
        --if last then
        --    str = string.format('id: %d, key: %d', last.id, last.key)
        --end
        --inf_label:setString(str)

        --if 0 < ts and ts < 0.5 then
        --    model:setParameterValue(param.EyeLOpen,1,1)
        --    model:setParameterValue(param.EyeROpen,0,1)
        --    Print('set param')
        --end
        --model:update(dt)
    end
    launcher_scene:scheduleUpdateWithPriorityLua(function(dt)
        launcher_scene:update(dt)
    end, 100)

    --SystemLog('before pushScene')
    cc.Director:getInstance():pushScene(launcher_scene)
end

return CreateLauncherUI
