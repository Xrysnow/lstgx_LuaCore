---
--- native.lua
---
--- Copyright (C) 2018-2020 Xrysnow. All rights reserved.
---

local M = {}
local luaj = require('cocos.cocos2d.luaj')
local call = luaj.callStaticMethod
local osname = lstg.GetPlatform()

local function jCall(...)
    if osname == 'android' then
        local ok, ret = call(...)
        if not ok then
            error("luaj error: " .. tostring(ret))
        else
            return ret
        end
    end
end
local andHelper = 'org/cocos2dx/lib/Cocos2dxHelper'
local andApp = 'org/cocos2dx/lua/AppActivity'

---@return string
function M.getAssetsPath()
    local methodName = 'getAssetsPath'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---@return string
function M.getCocos2dxPackageName()
    local methodName = 'getCocos2dxPackageName'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---vibrate
---@param duration number @duration in seconds
---@return void
function M.vibrate(duration)
    local methodName = 'vibrate'
    local sig = '(F)V'
    return jCall(andHelper, methodName, { duration }, sig)
end

---@return string
function M.getVersion()
    local methodName = 'getVersion'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---@param url string
---@return boolean
function M.openURL(url)
    local methodName = 'openURL'
    local sig = '(Ljava/lang/String;)Z'
    assert(type(url) == 'string')
    return jCall(andHelper, methodName, { url }, sig)
end

---@return number
function M.getDPI()
    local methodName = 'getDPI'
    local sig = '()I'
    return jCall(andHelper, methodName, {}, sig)
end

---@return string
function M.getSDCardPath()
    local methodName = 'getSDCardPath'
    local sig = '()Ljava/lang/String;'
    local ret = jCall(andApp, methodName, {}, sig)
    if not ret or ret == '' then
        lstg.SystemLog('getSDCardPath: failed')
    end
    return ret
end

---@return string
function M.messageBox(title, msg)
    local methodName = 'showDialog'
    local sig = '(Ljava/lang/String;Ljava/lang/String;)V'
    return jCall(andHelper, methodName, { title, msg }, sig)
end

local ActivityInfo = require('platform.android.ActivityInfo')

function M.setOrientation(ori)
    local methodName = 'setActivityOrientation'
    local sig = '(I)V'
    if type(ori) == 'string' then
        ori = ActivityInfo['SCREEN_ORIENTATION_' .. string.upper(ori)]
    end
    assert(type(ori) == 'number' and -1 <= ori and ori <= 14, 'wrong param')
    lstg.SystemLog('setOrientation: set to ' .. ori)
    return jCall(andApp, methodName, { ori }, sig)
end

function M.setOrientationLandscape()
    local glv = cc.Director:getInstance():getOpenGLView()
    local sz = glv:getFrameSize()
    M.setOrientation('SENSOR_LANDSCAPE')
    glv:setFrameSize(math.max(sz.width, sz.height), math.min(sz.width, sz.height))
end

function M.setOrientationPortrait()
    local glv = cc.Director:getInstance():getOpenGLView()
    local sz = glv:getFrameSize()
    M.setOrientation('PORTRAIT')
    glv:setFrameSize(math.min(sz.width, sz.height), math.max(sz.width, sz.height))
end

---@return number
function M.getOrientation()
    local methodName = 'getActivityOrientation'
    local sig = '()I'
    return jCall(andApp, methodName, {}, sig)
end

---@return table
function M.getNativeInfo()
    local ret = {}
    if osname == 'android' then
        ret['AssetsPath'] = M.getAssetsPath()
        ret['PackageName'] = M.getCocos2dxPackageName()
        ret['Version'] = M.getVersion()
        ret['DPI'] = M.getDPI()
        ret['SDCardPath'] = M.getSDCardPath()
    end
    return ret
end

return M
