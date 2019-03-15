---
--- controller_ui.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---


local TouchKey = require('cc.TouchKey')
local ASSETS_PATH = 'x/assets/'
local tk_bg = 'res/touchkey_bg.png'
local font = ASSETS_PATH .. 'font/WenQuanYiMicroHeiMono.ttf'
local glv = cc.Director:getInstance():getOpenGLView()

local function CreateControllerUI(fatherNode)
    local tex = cc.Director:getInstance():getTextureCache():addImage(tk_bg);

    local scale_pos = screen.scale
    local scale_size = screen.scale * 0.65
    local fontsize = scale_size * 18

    local xx = setting.resx / scale_pos
    local pESCAPE = cc.pMul(cc.p(xx - 135, 135), scale_pos)
    local pSHIFT = cc.pMul(cc.p(xx - 56, 56), scale_pos)
    local pX = cc.pMul(cc.p(xx - 56, 160), scale_pos)
    local pZ = cc.pMul(cc.p(xx - 150, 56), scale_pos)

    local tk_sc = 0.8 * scale_size
    local k5, k6, k7, k8 = KEY.ESCAPE, KEY.SHIFT, KEY.X, KEY.Z
    if setting then
        k5, k6, k7, k8 = setting.keysys.menu, setting.keys.slow, setting.keys.spell, setting.keys.shoot
    end
    local bt5 = cc.SetNode(TouchKey:create(tex, k5), fatherNode, pESCAPE, tk_sc * 0.9)
    local bt6 = cc.SetNode(TouchKey:create(tex, k6), fatherNode, pSHIFT, tk_sc * 1.4)
    local bt7 = cc.SetNode(TouchKey:create(tex, k7), fatherNode, pX, tk_sc * 1.2)
    local bt8 = cc.SetNode(TouchKey:create(tex, k8, true), fatherNode, pZ, tk_sc)

    local color = cc.c3b(255, 255, 0)
    local color_outline = cc.c3b(0, 0, 0)

    local lb5 = cc.Label:createWithTTF("ESC", font, fontsize)
    local lb6 = cc.Label:createWithTTF("SHIFT", font, fontsize * 0.8)
    local lb7 = cc.Label:createWithTTF("X", font, fontsize)
    local lb8 = cc.Label:createWithTTF("Z", font, fontsize)
    cc.SetNode(lb5, fatherNode, pESCAPE, nil, color):enableOutline(color_outline, 1)
    cc.SetNode(lb6, fatherNode, pSHIFT, nil, color):enableOutline(color_outline, 1)
    cc.SetNode(lb7, fatherNode, pX, nil, color):enableOutline(color_outline, 1)
    cc.SetNode(lb8, fatherNode, pZ, nil, color):enableOutline(color_outline, 1)

    local stick = require('platform.controller_stick')
    local keys = { setting.keys.up, setting.keys.right, setting.keys.down, setting.keys.left }
    local pos = cc.pMul(cc.p(106, 106), scale_pos)
    stick = stick:create(keys, pos, scale_size)
    cc.SetNode(stick, fatherNode, pos)
end

return CreateControllerUI
