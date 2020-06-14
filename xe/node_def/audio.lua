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

local playsound = {
    { 'Sound name', 'sound', CheckNonBlank },
    { 'Volume', 'number', CheckExpr },
    { 'Pan', 'audio_pan', CheckExpr },
    { 'not use default vol', 'bool' },
    disptype     = 'play sound',
    default      = { ["type"] = "playsound", attr = { 'tan00', '0.1', 'self.x/256', false } },
    allowchild   = {},
    forbidparent = { 'root', 'folder' },
    totext       = function(nodedata)
        return string.format("play sound %q volume %s", nodedata.attr[1], nodedata.attr[2])
    end,
    tohead       = function(nodedata)
        if IsBlank(nodedata.attr[4]) then
            nodedata.attr[4] = false
        end
        return string.format("PlaySound(%q,%s,%s,%s)\n", nodedata.attr[1], nodedata.attr[2], nodedata.attr[3], nodedata.attr[4])
    end,
    check        = function(nodedata)
        local _snd = M.getSoundList()
        if not (M.watchDict.sound[nodedata.attr[1]] or _snd[nodedata.attr[1]]) then
            return string.format('sound %q does not exist', nodedata.attr[1])
        end
    end,
}
local loadsound = {
    { 'File path', 'resfile', CheckNonBlank },
    { 'Resource name', 'string', CheckNonBlank },
    disptype    = 'load sound',
    editfirst   = true,
    watch       = 'sound',
    allowchild  = {},
    allowparent = { 'root', 'folder' },
    totext      = function(nodedata)
        return string.format("load sound %q from %q", nodedata.attr[2], nodedata.attr[1])
    end,
    tohead      = function(nodedata)
        local path = string.filename(nodedata.attr[1], true)
        return string.format("LoadSound(%q, %q)\n", nodedata.attr[2], path)
    end,
    check       = function(nodedata)
        local _snd = M.getSoundList()
        if _snd[nodedata.attr[2]] then
            return string.format("Duplicated resource name %q (name already exists in THlib)", nodedata.attr[2])
        end
        if M.checkSoundName[nodedata.attr[2]] == nil then
            M.checkSoundName[nodedata.attr[2]] = true
        else
            return string.format("Duplicated resource name %q", nodedata.attr[2])
        end
        local absfn = MakeFullPath(nodedata.attr[1])
        if not absfn or absfn == '' then
            return string.format("Resource file %q does not exist", nodedata.attr[1])
        end
        --local fn = wx.wxFileName(nodedata.attr[1]):GetFullName()
        local fn = string.filename(nodedata.attr[1], true)
        if not CheckResFileInPack(fn) then
            return string.format("Duplicated resource file name %q", fn)
        end
        --local f, msg = io.open("editor\\tmp\\_pack_res.bat", "a")
        --if msg then
        --    return msg
        --end
        --f:write(string.format('..\\tools\\7z\\7z u -tzip -mcu=on "..\\game\\mod\\%s.zip" "%s"\n', outputName, absfn))
        --f:close()
        require('xe.Project').addPackRes(absfn, 'loadsound')
    end
}
local playbgm = {
    { 'Music name', 'string', CheckNonBlank },
    disptype     = 'play background music',
    allowchild   = {},
    forbidparent = { 'root', 'folder' },
    totext       = function(nodedata)
        return string.format("play background music %q", nodedata.attr[1])
    end,
    tohead       = function(nodedata)
        return string.format("LoadMusicRecord(%q) _play_music(%q)\n", nodedata.attr[1], nodedata.attr[1])
    end,
}
local pausebgm = {
    disptype     = 'pause background music',
    allowchild   = {},
    forbidparent = { 'root', 'folder' },
    totext       = function(nodedata)
        return "pause background music"
    end,
    tohead       = function(nodedata)
        return "_pause_music()\n"
    end,
}
local resumebgm = {
    disptype     = 'resume background music',
    allowchild   = {},
    forbidparent = { 'root', 'folder' },
    totext       = function(nodedata)
        return "resume background music"
    end,
    tohead       = function(nodedata)
        return "_resume_music()\n"
    end,
}
local stopbgm = {
    disptype     = 'stop background music',
    allowchild   = {},
    forbidparent = { 'root', 'folder' },
    totext       = function(nodedata)
        return "stop background music"
    end,
    tohead       = function(nodedata)
        return "_stop_music()\n"
    end,
}
local _def = {
    playsound = playsound,
    loadsound = loadsound,
    playbgm   = playbgm,
    pausebgm  = pausebgm,
    resumebgm = resumebgm,
    stopbgm   = stopbgm,
}
for k, v in pairs(_def) do
    require('xe.node_def._def').DefineNode(k, v)
end
