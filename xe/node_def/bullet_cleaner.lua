local M = require('xe.node_def._checker')
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

local bulletcleanrange = {
    { 'Position', 'any', CheckPos },
    { 'Radius of Range', 'any', CheckExpr },
    { 'Time of Spreading out', 'any', CheckExpr },
    { 'Duration', 'any', CheckExpr },
    { 'Convert bullet into faith', 'bool', CheckExpr },
    { 'Clean the indestroyable bullet', 'bool', CheckExpr },
    { 'floating velocity', 'any', CheckExpr },
    disptype     = 'make a floating bullet-cleaning range',
    forbidparent = { 'root', 'folder' },
    allowchild   = {},
    default      = {
        ['type'] = 'bulletcleanrange',
        ['attr'] = { 'player.x, player.y', '48', '15', '45', 'true', 'true', '0' }
    },
    totext       = function(nodedata)
        return string.format('make a floating(v=%s) bullet-cleaning range(%s) in (%s), last (%s+%s) frames.',
                             nodedata.attr[7], nodedata.attr[2], nodedata.attr[1], nodedata.attr[3], nodedata.attr[4])
    end,
    tohead       = function(nodedata)
        return string.format('New(bullet_cleaner, %s)\n', table.concat(nodedata.attr, ", "))
    end
}
local _def = {
    bulletcleanrange = bulletcleanrange,
}
for k, v in pairs(_def) do
    require('xe.node_def._def').DefineNode(k, v)
end
