---@class TouchKey:cc.Sprite
local TouchKey = class("TouchKey", function(texture)
    return cc.Sprite:createWithTexture(texture)
end)

TouchKey.__index = TouchKey

local StateGrabbed = 0
local StateUngrabbed = 1

TouchKey._state = StateGrabbed

function TouchKey:rect()
    local s = self:getTexture():getContentSize()
    return cc.rect(-s.width / 2, -s.height / 2, s.width, s.height)
end

function TouchKey:containsTouchLocation(x, y)
    local position = cc.p(self:getPosition())
    --local s         = self:getTexture():getContentSize()
    local s = self:getBoundingBox()
    local touchRect = cc.rect(-s.width / 2 + position.x, -s.height / 2 + position.y, s.width, s.height)
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

---@param aTexture cc.Texture2D
---@param keyCode number
---@return TouchKey
function TouchKey:create(aTexture, keyCode, isLock)
    local tk = TouchKey(aTexture)
    tk._state = StateUngrabbed
    tk._keyCode = keyCode
    tk._isLock = isLock
    tk.__isLock = isLock
    tk:registerScriptHandler(function(tag)
        if "enter" == tag then
            tk:onEnter()
        elseif "exit" == tag then
        end
    end)
    return tk
end

local director = cc.Director:getInstance()
local function sendKeyEvent(keyCode, isPressed)
    local e = cc.EventKeyboard:new(keyCode, isPressed)
    director:getRunningScene():getEventDispatcher():dispatchEvent(e);
end

local _color_inactive = cc.c3b(255, 255, 255)
local _color_active = cc.c3b(255, 255, 0)

function TouchKey:onEnter()
    --self:setOpacity(127)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    local setActive = function()
        self._state = StateGrabbed
        sendKeyEvent(self._keyCode, true)
        self:setColor(_color_active)
        --print('TouchKey: sendKeyEvent true.')
    end
    local setInactive = function()
        self._state = StateUngrabbed
        sendKeyEvent(self._keyCode, false)
        self:setColor(_color_inactive)
        --print('TouchKey: sendKeyEvent true.')
    end
    setInactive()
    self._setActive = setActive
    self._setInactive = setInactive
    listener:registerScriptHandler(function(touch, event)
        local loc = touch:getLocation()
        if self._isLock then
            if not self:containsTouchLocation(loc.x, loc.y) then
                return false
            end
            if self._state == StateUngrabbed then
                setActive()
            else
                setInactive()
            end
        else
            if (self._state ~= StateUngrabbed) then
                return false
            end
            if not self:containsTouchLocation(loc.x, loc.y) then
                return false
            end
            setActive()
        end
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        if not self._isLock then
            setInactive()
        end
        return true
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    if self._isLock then
        self:scheduleUpdateWithPriorityLua(function()
            self:update()
        end, 0)
    end
end

function TouchKey:setLockMode(isLock)
    self._isLock = isLock
end

function TouchKey:update()
    if not ext then
        return
    end
    if ext.pause_menu and self._isLock then
        self._isLock = false
        self._setInactive()
    elseif (not ext.pause_menu) and (not self._isLock) then
        self._isLock = true
    end
end

return TouchKey
