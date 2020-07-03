--
local M = {}

M.checkSoundName = {}
M.checkImageName = {}
M.checkAniName = {}
M.checkParName = {}
M.checkBgmName = {}
M.checkAnonymous = {}
M.checkResFile = {}
M.checkClassName = {}
M.watchDict = {}
M.paramNumDict = {}

M.className = nil
M.difficulty = nil
M.parimg = {}
for i = 1, 16 do
    M.parimg['parimg' .. i] = true
end

function M.reset()
    M.checkSoundName = {}
    M.checkImageName = {}
    M.checkAniName = {}
    M.checkParName = {}
    M.checkBgmName = {}
    M.checkAnonymous = {}
    M.checkResFile = {}
    M.checkClassName = {}
    M.watchDict = {}
    M.paramNumDict = {}
    M.className = nil
    M.difficulty = nil
end

function M.CalcParamNum(s)
    if string.match(s, "^[%s]*$") then
        return 0
    end
    local b1 = 0
    local b2 = 0
    local ret = 1
    for i = 1, #s do
        local c = string.byte(s, i)
        if b1 == 0 and b2 == 0 and c == 44 then
            -- ','
            ret = ret + 1
        elseif c == 40 then
            -- '('
            b1 = b1 + 1
        elseif c == 41 then
            -- ')'
            b1 = b1 - 1
        elseif c == 123 then
            -- '{'
            b2 = b2 + 1
        elseif c == 125 then
            -- '}'
            b2 = b2 - 1
        end
    end
    return ret
end
local CalcParamNum = M.CalcParamNum

function M.CheckName(s)
    if string.match(s, "^[%w_][%w_ ]*$") == nil then
        return "must be a string of letters, digits, spaces, and underscores, not beginning with a space"
    end
end
function M.CheckVName(s)
    if string.match(s, "^[%a_][%w_]*$") == nil then
        return "must be a string of letters, digits, and underscores, not beginning with a digit"
    end
end
function M.CheckExpr(s)
    if string.match(s, "^[%s]*$") then
        return "can not be omitted"
    end
    local _, msg = loadstring("return " .. s)
    if msg ~= nil then
        return msg
    end
end
function M.CheckPos(s)
    if string.match(s, "^[%s]*$") then
        return "can not be omitted"
    end
    local _, msg = loadstring("return " .. s)
    if msg ~= nil then
        return msg
    end
    if CalcParamNum(s) ~= 2 then
        return "invalid expression of position"
    end
end
function M.CheckExprOmit(s)
    local _, msg = loadstring("return " .. s)
    if msg ~= nil then
        return msg
    end
end
function M.CheckCode(s)
    local _, msg = loadstring(s)
    if msg ~= nil then
        return msg
    end
end
function M.CheckParam(s)
    local _, msg = loadstring("return function(" .. s .. ") end")
    if msg ~= nil then
        return msg
    end
end
function M.CheckNonBlank(s)
    if string.match(s, "^[%s]*$") then
        return "can not be blank"
    end
end
function M.CheckClassName(s)
    if string.match(s, "^[%s]*$") then
        return "can not be blank"
    else
        if M.checkClassName[s] then
            return string.format("duplicated type name %q", s)
        else
            M.checkClassName[s] = true
        end
    end
end
function M.IsBlank(s)
    if not s then
        return true
    end
    if string.match(s, "^[%s]*$") then
        return true
    else
        return false
    end
end
--- if name is not already saved in `checkResFile`, save it and return true, otherwise return false
function M.CheckResFileInPack(name)
    if M.checkResFile[name] == nil then
        M.checkResFile[name] = true
        return true
    else
        return false
    end
end
function M.CheckAnonymous(name, fullname)
    if M.checkResFile[name] == nil then
        M.checkResFile[name] = true
        M.checkAnonymous[name] = fullname
        return true
    else
        if M.checkAnonymous[name] == fullname then
            return true
        else
            return false
        end
    end
end

function M.MakeFullPath(path)
    return cc.FileUtils:getInstance():fullPathForFilename(path)
end

function M.AddPackRes(path, name, check, from_type)
    if check[name] == nil then
        check[name] = true
    else
        return string.format("Repeated resource name %q", name)
    end
    local absfn = M.MakeFullPath(path)
    if not absfn or absfn == '' then
        return string.format("Resource file %q does not exist", path)
    end
    local fn = string.filename(path, true)
    if not M.CheckResFileInPack(fn) then
        return string.format("Repeated resource file name %q", fn)
    end
    require('xe.Project').addPackRes(absfn, 'loadbgm')
end

function M.AddPackBgm(path, name, from_type)
    local absfn = M.MakeFullPath(path)
    if not absfn or absfn == '' then
        return string.format("Resource file %q does not exist", path)
    end
    if M.checkBgmName[name] == nil then
        M.checkBgmName[name] = path
        --local fn = wx.wxFileName(nodedata.attr[1]):GetFullName()
        local fn = string.filename(path, true)
        if not M.CheckResFileInPack(fn) then
            return string.format("Repeated resource file name %q", fn)
        end
        require('xe.Project').addPackRes(absfn, 'loadbgm')
    else
        if M.checkBgmName[name] ~= path then
            return string.format("Repeated resource name %q", name)
        end
    end
end

local _sound = {}
local _load = 'LoadSound'
local _old = _G[_load]
_G[_load] = function(name, path)
    _sound[name] = path
end
DoFile('THlib/se/se.lua')
_G[_load] = _old
function M.getSoundList()
    return _sound
end

return M
