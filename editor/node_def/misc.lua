local M = require('editor.node_def._checker')
local CalcParamNum = M.CalcParamNum
local CheckName = M.CheckName
local CheckVName = M.CheckVName
local CheckExpr = M.CheckExpr
local CheckPos = M.CheckPos
local CheckExprOmit = M.CheckExprOmit
local CheckCode = M.CheckCode
local CheckParam = M.CheckParam
local CheckNonBlank = M.CheckNonBlank
local CheckClassName = M.CheckClassName
local IsBlank = M.IsBlank
local CheckResFileInPack = M.CheckResFileInPack
local CheckAnonymous = M.CheckAnonymous
local MakeFullPath = M.MakeFullPath

local shakescreen = {
    { 'time', 'any', CheckExpr },
    { 'amplitude', 'any', CheckExpr },
    disptype     = 'shake screen',
    forbidparent = { 'root', 'folder' },
    allowchild   = {},
    default      = { ["type"] = 'shakescreen', attr = { '240', '3' } },
    totext       = function(nodedata)
        return "Shake screen " .. nodedata.attr[1] .. " frames, amplitude of " .. nodedata.attr[2]
    end,
    tohead       = function(nodedata)
        return "misc.ShakeScreen(" .. nodedata.attr[1] .. ", " .. nodedata.attr[2] .. ")\n"
    end
}
local setfps = {
    { 'FPS', 'any', CheckExpr },
    disptype     = 'Set FPS',
    forbidparent = { 'root', 'folder' },
    allowchild   = {},
    default      = { ["type"] = 'setfps', attr = { '60' } },
    totext       = function(nodedata)
        return "Set FPS to " .. nodedata.attr[1]
    end,
    tohead       = function(nodedata)
        return "SetFPS(" .. nodedata.attr[1] .. ")\n"
    end
}
local smear = {
    { "Master", "any", CheckExpr },
    { "Interval (floating number)", "any", CheckExpr },
    default      = { ["type"] = "smear", attr = { "self", "1" } },
    forbidparent = { "root", "folder" },
    allowchild   = {},
    totext       = function(nodedata)
        return string.format("make a smear of %s, interval = %s", nodedata.attr[1], nodedata.attr[2])
    end,
    tohead       = function(nodedata)
        return string.format("last = New(smear, %s)\n", table.concat(nodedata.attr, ", "))
    end
}
local dropitem = {
    { 'Item', 'item' },
    { 'Number', 'any', CheckExpr },
    { 'Position', 'any', CheckPos },
    disptype     = 'drop item',
    forbidparent = { 'root', 'folder' },
    allowchild   = {},
    default      = { ["type"] = 'dropitem', attr = { 'item_extend', '1', 'self.x,self.y' } },
    totext       = function(nodedata)
        if nodedata.attr[2] == '0' then
            return "drop nothing"
        end
        local ret = "drop "
        if nodedata.attr[2] ~= '1' then
            ret = ret .. nodedata.attr[2] .. " "
        end
        return ret .. nodedata.attr[1] .. " at (" .. nodedata.attr[3] .. ")"
    end,
    tohead       = function(nodedata)
        return string.format("_drop_item(%s)\n", table.concat(nodedata.attr, ", "))
    end
}
local _def = {
    shakescreen = shakescreen,
    setfps      = setfps,

    smear       = smear,
    dropitem    = dropitem,
}
for k, v in pairs(_def) do
    require('editor.node_def._def').DefineNode(k, v)
end
