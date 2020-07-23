--
local M = {}
local im = imgui

local docking_window_flags = 0
if im then
    docking_window_flags = bit.bor(
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
end

function M.load(target, docking, no_tool, no_font)
    if not im then
        return
    end
    require('imgui.__init__')
    local la = im.on(target or cc.Director:getInstance():getRunningScene())
    if docking then
        im.clear()
        local wi = require('imgui.Widget')
        local dock
        dock = wi.Widget(function()
            local viewport = im.getMainViewport()
            im.setNextWindowPos(viewport.Pos)
            im.setNextWindowSize(viewport.Size)
            im.setNextWindowViewport(viewport.ID)
            im.pushStyleVar(im.StyleVar.WindowRounding, 0)
            im.pushStyleVar(im.StyleVar.WindowBorderSize, 0)
            im.pushStyleVar(im.StyleVar.WindowPadding, im.p(0, 0))
            im.begin('Dock Space', nil, docking_window_flags)
            im.popStyleVar(3)
            im.dockSpace(im.getID(tostring(docking)), im.p(0, 0), im.DockNodeFlags.PassthruCentralNode)
            wi._handler(dock)
            im.endToLua()
        end)
        la:addChild(dock)
    end
    if not no_font then
        im.addFontTTF('font/WenQuanYiMicroHeiMono.ttf', 16)
    end
    if not no_tool then
        --la:addChild(im.showDemoWindow)
        la:addChild(require('imgui.ui.Console').createWindow('Console'):setContentSize(cc.size(500, 500)))
        la:addChild(require('imgui.ui.LogWindow').createWindow('Log'):setContentSize(cc.size(500, 500)))
        la:addChild(require('imgui.ui.StyleSetting')('Setting'):setContentSize(cc.size(500, 500)))
        la:addChild(require('imgui.ui.VariableWatch').createWindow('Watch'):setContentSize(cc.size(500, 500)))
        la:addChild(require('imgui.lstg.GameInfo')('Game Info'):setContentSize(cc.size(500, 500)))
        la:addChild(require('imgui.ui.About').createWindow('About'):setContentSize(cc.size(500, 500)))
    end
    -- disable navigation
    im.configFlagDisable(im.ConfigFlags.NavEnableKeyboard, im.ConfigFlags.NavEnableGamepad)
    --im.setVisible(setting.imgui_visible)
    la:setVisible(setting.imgui_visible)
end

function M.loadFont()
    if not im then
        return
    end
    local cfg = im.ImFontConfig()
    cfg.OversampleH = 1
    cfg.PixelSnapH = true
    im.addFontTTF('font/WenQuanYiMicroHeiMono.ttf', 14, cfg, {
        --0x0080, 0x00FF, -- Basic Latin + Latin Supplement
        0x2000, 0x206F, -- General Punctuation
        0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
        0x31F0, 0x31FF, -- Katakana Phonetic Extensions
        0xFF00, 0xFFEF, -- Half-width characters
        0x4e00, 0x9FAF, -- CJK Ideograms
        0,
    })
    cfg.MergeMode = true
    im.addFontTTF('font/NotoSansDisplay-Regular.ttf', 18, cfg, im.GlyphRanges.Default)
end

return M
