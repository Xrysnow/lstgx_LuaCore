---
--- native.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

local native = {}
local luaj = require('cocos.cocos2d.luaj')
local call = luaj.callStaticMethod
local osname = ex.GetOSName()

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
function native.getAssetsPath()
    local methodName = 'getAssetsPath'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---@return string
function native.getCocos2dxPackageName()
    local methodName = 'getCocos2dxPackageName'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---vibrate
---@param duration number @duration in seconds
---@return void
function native.vibrate(duration)
    local methodName = 'vibrate'
    local sig = '(F)V'
    return jCall(andHelper, methodName, { duration }, sig)
end

---@return string
function native.getVersion()
    local methodName = 'getVersion'
    local sig = '()Ljava/lang/String;'
    return jCall(andHelper, methodName, {}, sig)
end

---@param url string
---@return boolean
function native.openURL(url)
    local methodName = 'openURL'
    local sig = '(Ljava/lang/String;)Z'
    assert(type(url) == 'string')
    return jCall(andHelper, methodName, { url }, sig)
end

---@return number
function native.getDPI()
    local methodName = 'getDPI'
    local sig = '()I'
    return jCall(andHelper, methodName, {}, sig)
end

---@return string
function native.getSDCardPath()
    local methodName = 'getSDCardPath'
    local sig = '()Ljava/lang/String;'
    local ret = jCall(andApp, methodName, {}, sig)
    if not ret or ret == '' then
        SystemLog('getSDCardPath: failed')
    end
    return ret
end

local ActivityInfo = require('platform.android.ActivityInfo')

function native.setOrientation(ori)
    local methodName = 'setActivityOrientation'
    local sig = '(I)V'
    if type(ori) == 'string' then
        ori = ActivityInfo['SCREEN_ORIENTATION_' .. string.upper(ori)]
    end
    assert(type(ori) == 'number' and -1 <= ori and ori <= 14, 'wrong param')
    SystemLog('setOrientation: set to ' .. ori)
    return jCall(andApp, methodName, { ori }, sig)
end

function native.getOrientation()
    local methodName = 'getActivityOrientation'
    local sig = '()I'
    return jCall(andApp, methodName, {}, sig)
end

---@return table
function native.GetNativeInfo()
    local ret = {}
    if osname == 'android' then
        ret['AssetsPath'] = native.getAssetsPath()
        ret['PackageName'] = native.getCocos2dxPackageName()
        ret['Version'] = native.getVersion()
        ret['DPI'] = native.getDPI()
        ret['SDCardPath'] = native.getSDCardPath()
    end
    return ret
end

return native
