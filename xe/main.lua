---@class xe.main:ViewBase
local M = class('xe.main', cc.load('mvc').ViewBase)
local glv = cc.Director:getInstance():getOpenGLView()
local im = imgui
local wi = require('imgui.Widget')
---@type xe.main
local _instance

--function M:ctor()
--end

function M:onCreate()
    _instance = self
end

---@return xe.main
function M:getInstance()
    return _instance
end

function M:onEnter()
    if self._editor then
        return
    end
    cc.Director:getInstance():getRunningScene():addChild(assert(cc.Sprite('null.png')))
    cc.Director:getInstance():setDisplayStats(false)
    --cc.Director:getInstance():setDisplayStats(true)
    lstg.loadData()
    SetResourceStatus('global')
    --Include('THlib.lua')
    --DoFile('core/score.lua')
    --RegistClasses()

    local la = im.get()
    im.show()
    im.clear()
    im.styleColorsLight()
    im.getStyle().FrameBorderSize = 1
    local cfg = im.ImFontConfig()
    cfg.OversampleH = 2
    cfg.OversampleV = 2
    im.addFontTTF('font/WenQuanYiMicroHeiMono.ttf', 14, cfg, {
        --0x0080, 0x00FF, -- Basic Latin + Latin Supplement
        0x2000, 0x206F, -- General Punctuation
        0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
        0x31F0, 0x31FF, -- Katakana Phonetic Extensions
        0xFF00, 0xFFEF, -- Half-width characters
        0x4e00, 0x9FAF, -- CJK Ideograms
        0,
    })
    --
    cfg = im.ImFontConfig()
    cfg.OversampleH = 3
    cfg.OversampleV = 3
    cfg.MergeMode = true
    im.addFontTTF('font/NotoSansDisplay-Regular.ttf', 18, cfg, im.GlyphRanges.Default)
    --
    local fa = require('xe.ifont')
    cfg = im.ImFontConfig()
    cfg.OversampleH = 2
    cfg.OversampleV = 2
    cfg.MergeMode = true
    cfg.GlyphMinAdvanceX = 12
    cfg.GlyphMaxAdvanceX = 12
    im.addFontTTF('font/' .. fa.FontIconFileName, 14, cfg, {
        fa.IconMin, fa.IconMax, 0
    })
    --
    local window_flags = bit.bor(
            im.WindowFlags.MenuBar,
            im.WindowFlags.NoDocking,
            im.WindowFlags.NoTitleBar,
            im.WindowFlags.NoCollapse,
            im.WindowFlags.NoResize,
            im.WindowFlags.NoMove,
            im.WindowFlags.NoBringToFrontOnFocus,
            im.WindowFlags.NoNavFocus,
            im.WindowFlags.NoBackground
    )
    local dock = wi.wrapper(function()
        local viewport = im.getMainViewport()
        im.setNextWindowPos(viewport.Pos)
        im.setNextWindowSize(viewport.Size)
        im.setNextWindowViewport(viewport.ID)
        im.pushStyleVar(im.StyleVar.WindowRounding, 0)
        im.pushStyleVar(im.StyleVar.WindowBorderSize, 0)
        im.pushStyleVar(im.StyleVar.WindowPadding, im.p(0, 0))
        im.begin('Dock Space', nil, window_flags)
        im.popStyleVar(3)
        im.dockSpace(im.getID('xe.dock_space'), im.p(0, 0), im.DockNodeFlags.PassthruCentralNode)
    end, function()
        im.endToLua()
    end)
    dock:addTo(la)
    local menu_bar = wi.MenuBar()
    local menu = wi._begin_end_wrapper(im.beginMenu, im.endMenu, { 'File' })
    dock:addChildChain(menu_bar, menu, function()
        im.menuItem('1')
        im.menuItem('22')
    end)

    self._editor = require('xe.win.SceneEditor')()
    la:addChild(self._editor)

    self._property = require('xe.win.NodeProperty')()
    la:addChild(self._property)

    self._output = require('xe.win.Output')()
    la:addChild(self._output)

    self._watch = require('imgui.ui.VariableWatch').createWindow('Watch')
    la:addChild(self._watch)

    self._console = require('imgui.ui.Console').createWindow('Console')
    la:addChild(self._console)

    --la:addChild(im.showDemoWindow)

    -- dialogs

    self._edit_txt = require('xe.input.EditText')()
    self:_addDialog(self._edit_txt)
    self._setting = require('xe.win.Setting')()
    self:_addDialog(self._setting)
    self._newproj = require('xe.win.NewProject')()
    self:_addDialog(self._newproj)

    self._game_log = require('imgui.ui.LogWindow')()
    local win = require('imgui.widgets.Window')('Log')
    la:addChild(win:addChild(self._game_log))
end

function M:_addDialog(v)
    v:setVisible(false):addTo(im.get())
end

function M.hideProperty()
    M:getInstance()._property:clear()
end

function M.getEditor()
    return M:getInstance()._editor
end

function M.getProperty()
    return M:getInstance()._property
end

---@return xe.SceneTree
function M.getTree()
    return M:getInstance()._editor:getTree()
end

function M.getToolBar()
    return M:getInstance()._editor._toolbar
end

function M.getToolPanel()
    return M:getInstance()._editor._toolpanel
end

function M.getGameLog()
    return M:getInstance()._game_log
end

--

function M.getSetting(k)
    return require('xe.win.Setting').getVar(k)
end

function M.setSetting(k, v)
    return require('xe.win.Setting').setVar(k, v)
end

function M:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene('xe.main')
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    im.on(scene)
    return self
end

return M
