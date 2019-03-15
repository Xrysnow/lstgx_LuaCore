---@class GameScene:cc.Node
local Scene = class("GameScene", cc.load("mvc").ViewBase)

local director = cc.Director:getInstance()
local glv = cc.Director:getInstance():getOpenGLView()
local game_util = require('game.util')

function Scene:onCreate()

    lstg.loadSetting()

    self:scheduleUpdateWithPriorityLua(function(dt)
        self:update(dt)
    end, 0)

    if setting.touchkey and plus.isMobile() then
        self:addTouchKey()
    end
    --self:addTouchKey()

    local scale = glv:getDesignResolutionSize().height / 480
    SystemLog(string.format(
            'ui scale = %.3f, screen.scale = %.3f', scale, screen.scale))
end

local profiler = profiler
function Scene:onEnter()
    --ex.Test('test2.mp4')
    stage.next_stage = stage_menu

    --local e = cc.EventListenerCustom:create('director_after_visit', function()
    --    profiler.tic('FrameFunc')
    --    FrameFunc()
    --    profiler.toc('FrameFunc')
    --
    --    profiler.tic('RenderFunc')
    --    RenderFunc()
    --    profiler.toc('RenderFunc')
    --end)
    --cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(e, 1)
end

function Scene:showWithScene(transition, time, more)
    --SystemLog('[GameScene] showWithScene')
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    if director:getRunningScene() then
        if transition then
            scene = display.wrapScene(scene, transition, time, more)
        end
        --SystemLog('[GameScene] before pushScene')
        director:pushScene(scene)
    else
        director:runWithScene(scene)
    end
    return self
end

function Scene:addTouchKey()
    if not lstg.tmpvar.disableTouchKey then
        --SystemLog('[GameScene] add TouchKey')
        local ui_layer = cc.Layer:create()
        ui_layer:setAnchorPoint(0, 0)
        self:addChild(ui_layer)
        require('platform.controller_ui')(ui_layer)
        --SystemLog('[GameScene] TouchKey added')
    end
end

function Scene:update(dt)
    profiler.tic('FrameFunc')
    FrameFunc()
    profiler.toc('FrameFunc')

    profiler.tic('RenderFunc')
    RenderFunc()
    profiler.toc('RenderFunc')
end

stage_init = stage.New('init', true, true)
function stage_init:init()
end
function stage_init:frame()
    stage.Set('none', 'menu')
end
function stage_init:render()
    SetViewMode('ui')
    RenderText('menu', 'stage_init', 320, 240, 1)
end

local inited = false
stage_menu = stage.New('menu', false, true)
function stage_menu:init()
    --SetResourceStatus('global')
    --SystemLog('stage_menu:init')
    local returnToLauncher = function()
        -- return to launcher2
        --SystemLog('pop scene')
        inited = false
        stage.current_stage = nil
        lstg.practice = nil
        game_util.stopAudios()
        glv:setDesignResolutionSize(
                1706, 960, cc.ResolutionPolicy.SHOW_ALL)
        cc.Director:getInstance():popScene()
    end
    if inited then
        if self.save_replay then
            --SystemLog('stage_menu =\n'..stringify(self))
            local menu_replay_saver
            menu_replay_saver = New(replay_saver, self.save_replay, self.finish, function()
                menu.FlyOut(menu_replay_saver, 'right')
                task.New(stage_menu, function()
                    task.Wait(30)
                    task.New(stage_menu, returnToLauncher)
                end)
            end)
            menu.FlyIn(menu_replay_saver, 'left')
        else
            --returnToLauncher()
            task.New(stage_menu, returnToLauncher)
        end
    else
        inited = true
        --SystemLog('before enterStage')
        --_test()
        --_test()
        --jit.off()
        --jit.flush()
        --_test()
        game_util.enterStage(stage_menu, false)
    end
end
function stage_menu:frame()
end
function stage_menu:render()
    --SetViewMode('ui')
    --RenderText('menu', 'stage_menu', 320, 240, 1)
    --local size = glv:getDesignResolutionSize()
    --local str=string.format('D res: (%d, %d)', size.width, size.height)
    --RenderText('menu', str, 320, 200, 1)
    --ui.DrawMenuBG()
end

return Scene
