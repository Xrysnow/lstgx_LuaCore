local M = {}
--require('cocos.controller.ControllerConstants')
--local _KEY = cc.ControllerKey

-- key and axis may have same code
local status_button = {}
local status_axis = {}
local status_axis_pos = {}
local status_axis_neg = {}
function M.getInnerStatus()
    return status_button, status_axis
end

local mapping = { button = {}, axis = { pos = {}, neg = {} } }
local mapping_inv = {}

--

---@param c cc.Controller
local function onConnect(c)
    local name = c:getDeviceName()
    local id = c:getDeviceId()
    Print(string.format('controller connected: name: %q, id: %d', name, id))
    status_button[c] = {}
    status_axis[c] = {}
    status_axis_pos[c] = {}
    status_axis_neg[c] = {}
    --local keys = {}
    --for i = 0, 15 do
    --    keys[i] = false
    --end
    --mapping[c] = {}
    --if plus.os == 'android' then
    --    -- receive back key
    --    c:receiveExternalKeyEvent(4, true)
    --    -- receive menu key
    --    c:receiveExternalKeyEvent(82, true)
    --end
end

---@param c cc.Controller
local function onDisonnect(c)
    local name = c:getDeviceName()
    local id = c:getDeviceId()
    Print(string.format('controller disconnected: name: %q, id: %d', name, id))
    status_button[c] = nil
    status_axis[c] = nil
    status_axis_pos[c] = nil
    status_axis_neg[c] = nil
    --mapping[c] = nil
end

local function _check(c)
    if not status_button[c] then
        onConnect(c)
    end
end

local _last

local function _is_last(id, keyCode, is_axis, is_pos)
    if _last then
        return _last.id == id and _last.key == keyCode and _last.is_axis == is_axis and _last.is_pos == is_pos
    end
end

---@param c cc.Controller
---@param keyCode cc.Controller
---@param value cc.Controller
---@param isPressed cc.Controller
---@param isAnalog cc.Controller
local function onKeyDown(c, keyCode, value, isPressed, isAnalog)
    if keyCode >= 1000 then
        keyCode = keyCode - 1000
    end
    _check(c)
    status_button[c][keyCode] = true
    --local code = -1
    --for k, v in pairs(mapping_inv) do
    --    if v.key == keyCode and not v.is_axis then
    --        code = k
    --        break
    --    end
    --end
    --Print(string.format('[CTR] %d down: %02d => %d', c:getDeviceId(), keyCode, code))
    _last = {
        id  = c:getDeviceId(),
        key = keyCode,
    }
end
local function onKeyUp(c, keyCode, value, isPressed, isAnalog)
    if keyCode >= 1000 then
        keyCode = keyCode - 1000
    end
    --Print(string.format('[CTR] %d   up: %02d', c:getDeviceId(), keyCode))
    _check(c)
    status_button[c][keyCode] = false
    if _is_last(c:getDeviceId(), keyCode, nil, nil) then
        _last = nil
    end
end

local _threshold = 0.6
local _axis_t = {
    { nil, { nil, true }, { false, true }, },
    { { nil, false }, nil, { false, nil }, },
    { { true, false }, { true, nil }, nil, },
}
local function _set_axis(c, keyCode, posVal, negVal)
    if posVal ~= nil then
        status_axis_pos[c][keyCode] = posVal
        if posVal then
            _last = {
                id      = c:getDeviceId(),
                key     = keyCode,
                is_axis = true,
                is_pos  = true,
            }
        else
            if _is_last(c:getDeviceId(), keyCode, true, true) then
                _last = nil
            end
        end
    end
    if negVal ~= nil then
        status_axis_neg[c][keyCode] = negVal
        if negVal then
            _last = {
                id      = c:getDeviceId(),
                key     = keyCode,
                is_axis = true,
                is_pos  = false,
            }
        else
            if _is_last(c:getDeviceId(), keyCode, true, false) then
                _last = nil
            end
        end
    end
end

local function onAxisEvent(c, keyCode, value, isPressed, isAnalog)
    if keyCode >= 1000 then
        keyCode = keyCode - 1000
    end
    _check(c)
    local last = status_axis[c][keyCode]
    if not last then
        status_axis[c][keyCode] = value
        last = value
    end
    --if math.abs(last - value) < 0.1 then
    --    return
    --end
    status_axis[c][keyCode] = value
    local i1, i2
    if value < -_threshold then
        i1 = 1
    elseif value > _threshold then
        i1 = 3
    else
        i1 = 2
    end
    if last < -_threshold then
        i2 = 1
    elseif last > _threshold then
        i2 = 3
    else
        i2 = 2
    end
    local val = _axis_t[i1][i2]
    if val then
        _set_axis(c, keyCode, val[1], val[2])
        --Print('set_axis', keyCode, string.format('%.3f', last), string.format('%.3f', value), val[1], val[2])
    end
end

function M.init()
    for _, v in ipairs(GetAllControllers()) do
        onConnect(v)
    end
    SetOnControllerConnect(onConnect)
    SetOnControllerDisconnect(onDisonnect)
    SetOnControllerKeyDown(onKeyDown)
    SetOnControllerKeyUp(onKeyUp)
    SetOnControllerAxisEvent(onAxisEvent)

    cc.Director:getInstance():getEventDispatcher():addCustomEventListener(
            "director_after_update",
            function()
                _last = nil
            end
    )
    lstg.eventDispatcher:addListener('onFocusLose', function()
        _last = nil
    end, 100, 'controller.last.clear')

    M.loadFromSetting()
end

function M.getStatus(code)
    local m = mapping_inv[code]
    if not m then
        return
    end
    local target
    if m.is_axis then
        if m.is_pos then
            target = status_axis_pos
        else
            target = status_axis_neg
        end
    else
        target = status_button
    end
    --Print(m.key, m.is_axis, m.is_pos)
    for k, v in pairs(target) do
        return v[m.key]
    end
end

function M.getLast()
    return _last
end

function M.getLastKey()
    local ret
    if _last then
        local key = _last.key
        if _last.is_axis then
            if _last.is_pos then
                ret = mapping.axis.pos[key]
            else
                ret = mapping.axis.neg[key]
            end
        else
            ret = mapping.button[key]
        end
    end
    return ret or 0
end

function M.loadFromSetting()
    if setting.controller_map then
        local keys = setting.controller_map.keys or {}
        local keysys = setting.controller_map.keysys or {}
        mapping = { button = {}, axis = { pos = {}, neg = {} } }
        for k, v in pairs(keys) do
            local ik = setting.keys[k]
            local keyCode = v[1] or -1
            mapping_inv[ik] = { key = keyCode }
            if #v > 1 then
                mapping_inv[ik].is_axis = true
                if v[2] then
                    mapping.axis.pos[keyCode] = ik
                    mapping_inv[ik].is_pos = true
                else
                    mapping.axis.neg[keyCode] = ik
                    mapping_inv[ik].is_pos = false
                end
            else
                mapping.button[keyCode] = ik
            end
        end
        for k, v in pairs(keysys) do
            local ik = setting.keysys[k]
            local keyCode = v[1] or -1
            mapping_inv[ik] = { key = keyCode }
            if #v > 1 then
                mapping_inv[ik].is_axis = true
                if v[2] then
                    mapping.axis.pos[keyCode] = ik
                    mapping_inv[ik].is_pos = true
                else
                    mapping.axis.neg[keyCode] = ik
                    mapping_inv[ik].is_pos = false
                end
            else
                mapping.button[keyCode] = ik
            end
        end
        --Print(stringify(mapping))
        --Print(stringify(mapping_inv))
    end
end

function M.convertSetting()
    local ret = {}
    if setting.controller_map then
        local keys = setting.controller_map.keys or {}
        local keysys = setting.controller_map.keysys or {}
        for k, v in pairs(keys) do
            ret[k] = { v[1], v[2] }
        end
        for k, v in pairs(keysys) do
            ret[k] = { v[1], v[2] }
        end
    end
    return ret
end

function M.setMapping(name, key, is_axis, is_pos)
    if not setting.controller_map then
        setting.controller_map = table.clone(default_setting.controller_map)
    end
    local k1 = setting.controller_map.keys[name]
    local k2 = setting.controller_map.keysys[name]
    local s = is_axis and { key, is_pos } or { key }
    local ik
    if k1 then
        setting.controller_map.keys[name] = s
        ik = setting.keys[name]
    elseif k2 then
        setting.controller_map.keysys[name] = s
        ik = setting.keysys[name]
    end
    mapping_inv[ik] = { key = key }
    if is_axis then
        mapping_inv[ik].is_axis = true
        if is_pos then
            mapping.axis.pos[key] = ik
            mapping_inv[ik].is_pos = true
        else
            mapping.axis.neg[key] = ik
            mapping_inv[ik].is_pos = false
        end
    else
        mapping.button[key] = ik
    end
end

return M
