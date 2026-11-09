-- The mobile launcher uses the standard ccui bindings and needs no scene assets.
local function createLauncher(alreadyLoaded)
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local scene = cc.Scene:create()
    scene:setName('android_launcher')
    local root = cc.Node:create()
    scene:addChild(root)
    root:addChild(cc.LayerColor:create(cc.c4b(24, 29, 39, 255), 960, 540), -10)

    local font = 'font/WenQuanYiMicroHeiMono.ttf'
    local hasFont = cc.FileUtils:getInstance():isFileExist(font)
    local function label(parent, text, x, y, width, height, size)
        local node
        if hasFont then
            node = cc.Label:createWithTTF(text, font, size or 20)
        else
            node = cc.Label:createWithSystemFont(text, 'sans-serif', size or 20)
        end
        node:setAnchorPoint(cc.p(0, 0))
        node:setPosition(x, y)
        node:setDimensions(width, height)
        node:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        parent:addChild(node)
        return node
    end

    local function button(parent, text, x, y, width, height, callback)
        local node = ccui.Button:create()
        node:ignoreContentAdaptWithSize(false)
        node:setContentSize(cc.size(width, height))
        node:setAnchorPoint(cc.p(0, 0))
        node:setPosition(x, y)
        node:setPropagateTouchEvents(true)
        local background = ccui.Layout:create()
        background:setContentSize(cc.size(width, height))
        background:setBackGroundColorType(1)
        background:setBackGroundColor(cc.c3b(53, 65, 84))
        node:addChild(background)
        local caption = label(node, text, 12, 0, width - 24, height)
        node:addClickEventListener(callback)
        parent:addChild(node)
        return node, caption, background
    end

    local function scroll(parent, name, x, width)
        local node = ccui.ScrollView:create()
        node:setName(name)
        node:setAnchorPoint(cc.p(0, 0))
        node:setPosition(x, 172)
        node:setContentSize(cc.size(width, 248))
        node:setDirection(1) -- ccui::ScrollView::Direction::VERTICAL
        -- A rectangular list needs only scissor clipping, not a stencil pass.
        node:setClippingType(1) -- ccui::Layout::ClippingType::SCISSOR
        node:setClippingEnabled(true)
        node:setTouchEnabled(true)
        parent:addChild(node)
        return node
    end

    label(root, 'LuaSTG-x', 28, 490, 904, 44, 30)
    local status = label(root, '', 28, 4, 904, 48, 17)
    status:setName('launcher_status')
    local function message(text)
        status:setString(tostring(text))
    end
    local function run(action)
        local ok, err = pcall(action)
        if not ok then
            SystemLog('Android launcher: ' .. tostring(err))
            message(err)
        end
        return ok
    end
    local function save()
        assert(lstg.saveSettingFile(), '保存设置失败')
    end

    local touchButton, touchLabel
    touchButton, touchLabel = button(root, '', 28, 60, 276, 40, function()
        run(function()
            setting.touchkey = not setting.touchkey
            touchLabel:setString(setting.touchkey and '触控按键：开启' or '触控按键：关闭')
            save()
            message('触控设置已保存，下次进入游戏时生效。')
        end)
    end)
    touchButton:setName('touch_toggle')
    touchLabel:setString(setting.touchkey and '触控按键：开启' or '触控按键：关闭')

    local orientationButton, orientationLabel
    orientationButton, orientationLabel = button(root, '', 318, 60, 276, 40, function()
        run(function()
            setting.orientation = setting.orientation == 'portrait' and 'landscape' or 'portrait'
            local native = require('platform.android.native')
            if setting.orientation == 'portrait' then
                native.setOrientationPortrait()
            else
                native.setOrientationLandscape()
            end
            orientationLabel:setString(setting.orientation == 'portrait' and '方向：竖屏' or '方向：横屏')
            save()
            message('屏幕方向已应用并保存。')
        end)
    end)
    orientationButton:setName('orientation_toggle')
    orientationLabel:setString(setting.orientation == 'portrait' and '方向：竖屏' or '方向：横屏')
    button(root, '保存设置', 608, 60, 324, 40, function()
        run(function()
            save()
            message('设置已保存。')
        end)
    end):setName('settings_save')

    -- Keep one mod loaded per process: loading another root.lua cannot undo its globals.
    local modPage = cc.Node:create()
    local gamePage = cc.Node:create()
    root:addChild(modPage)
    root:addChild(gamePage)
    gamePage:setVisible(false)
    local selectedMod, selectedRank, selectedPlayer
    local modButtons = {}
    local attempted = alreadyLoaded
    local startButton

    local function fillList(list, entries, text, select, preferred)
        local width = list:getContentSize().x
        local height = math.max(248, #entries * 56)
        list:setInnerContainerSize(cc.size(width, height))
        local backgrounds = {}
        local function choose(index)
            select(entries[index], index)
            for i, background in ipairs(backgrounds) do
                background:setBackGroundColor(i == index and cc.c3b(58, 110, 120) or cc.c3b(53, 65, 84))
            end
        end
        for i, entry in ipairs(entries) do
            local row, _, background = button(list, text(entry), 0, height - i * 56,
                    width, 52, function() run(function() choose(i) end) end)
            backgrounds[i] = background
            if list:getName() == 'mod_list' then
                modButtons[#modButtons + 1] = row
            end
        end
        if #entries > 0 then choose(preferred or 1) end
        list:jumpToTop()
    end

    local function showGameSelection()
        modPage:setVisible(false)
        gamePage:setVisible(true)
        label(gamePage, 'MOD：' .. tostring(setting.mod) .. '  /  选择难度与玩家', 28, 438, 904, 44)
        local content = require('game.content')
        local ranks, names = {}, {}
        if stage and stage.groups then ranks, names = content.enumRanks() end
        local players = player_list and content.enumPlayers() or {}
        local rankList = scroll(gamePage, 'rank_list', 28, 440)
        local playerList = scroll(gamePage, 'player_list', 492, 440)
        fillList(rankList, ranks, function(rank) return tostring(names[rank]) end,
                function(rank) selectedRank = rank end)
        fillList(playerList, players, function(player) return tostring(player[1]) end,
                function(_, index) selectedPlayer = index end)
        startButton = button(gamePage, '开始游戏', 28, 112, 904, 48, function()
            run(function()
                assert(selectedRank and selectedPlayer, '请先选择难度与玩家')
                local ok, err = content.setRank(selectedRank)
                assert(ok, err or '无法设置难度')
                ok, err = content.setPlayer(selectedPlayer)
                assert(ok, err or '无法设置玩家')
                lstg.practice = nil
                save()
                local game = require('app.views.GameScene'):create(nil, setting.mod)
                game:showWithScene()
            end)
        end)
        startButton:setName('game_start')
        startButton:setEnabled(#ranks > 0 and #players > 0)
        message((#ranks > 0 and #players > 0)
                and '选择难度与玩家，然后开始一轮游戏。切换 MOD 请重新启动应用。'
                or '此 MOD 没有可用的难度或玩家，无法开始一轮游戏；请检查 MOD 内容。')
    end

    label(modPage, '选择 MOD，然后加载游戏内容', 28, 438, 904, 44)
    local modList = scroll(modPage, 'mod_list', 28, 904)
    local loadButton = button(modPage, '加载所选 MOD', 28, 112, 904, 48, function()
        if attempted or not selectedMod then return end
        run(function()
            setting.mod, setting.mod_info = selectedMod.name, selectedMod
            save()
            attempted = true
            for _, row in ipairs(modButtons) do row:setEnabled(false) end
            -- Register the standard stage menu before a mod can override it.
            require('app.views.GameScene')
            local ok, err = pcall(lstg.loadMod)
            assert(ok, 'MOD 加载失败，请重新启动应用：' .. tostring(err))
            if lstg._exlauncher then
                local game = require('app.views.GameScene'):create(nil, setting.mod)
                game:showWithScene()
            else
                showGameSelection()
            end
        end)
    end)
    loadButton:setName('mod_load')
    if alreadyLoaded then
        run(showGameSelection)
    else
        run(function()
            local mods = require('platform.util').enumAvailableMods()
            local preferred = 1
            for i, mod in ipairs(mods) do
                if mod.name == setting.mod then preferred = i; break end
            end
            fillList(modList, mods, function(mod)
                return mod.name .. (mod.bundled and '（内置）' or '')
            end, function(mod) selectedMod = mod end, preferred)
            loadButton:setEnabled(#mods > 0)
            message(#mods > 0 and '上下滑动查看 MOD，选中后点击加载。'
                    or '未找到可用 MOD。请安装包含 MOD 的资源，或将 MOD 放入应用专属 mod 目录。')
        end)
    end

    local function layout()
        local size = view:getDesignResolutionSize()
        local scale = math.min(size.x / 960, size.y / 540)
        root:setScale(scale)
        root:setPosition((size.x - 960 * scale) / 2, (size.y - 540 * scale) / 2)
    end
    scene:registerScriptHandler(function(tag)
        if tag == 'enter' then layout() end
    end)
    director:getEventDispatcher():addEventListenerWithSceneGraphPriority(
            cc.EventListenerCustom:create(cc.Director.EVENT_PROJECTION_CHANGED, layout), scene)
    layout()
    director:pushScene(scene)
    return scene
end

return createLauncher
