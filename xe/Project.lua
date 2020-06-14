--
local M = {}
local logger = require('xe.logger')
local OutputLog = logger.log

local curProjFile
local curProjDir
local auto_save_counter = 1

--
local function getDirFromPath(path)
    return string.filefolder(path)
end
---Returns the name part of the filename (without extension).
local function getNameFromPath(path)
    return string.filename(path, false)
end

function M.getFile()
    return curProjFile
end

function M.getDir()
    if curProjFile then
        return string.filefolder(curProjFile)
    end
    --return curProjFile
end

---@return xe.ui.TreeView
function M.getTree()
    --
end

---@return xe.ui.TreeNode
function M.getRoot()
    --
end

--function M.saveEditorSetting(t)
--end

function M.setCurFile(s)
    curProjFile = s
    if s == nil then
        SetTitle("LuaSTG-x Editor")
        curProjDir = nil
        logger.clear()
    else
        --SetTitle(curProjFile .. " - LuaSTG-x Editor")
        SetTitle(getNameFromPath(curProjFile) .. " - LuaSTG-x Editor")
        curProjDir = getDirFromPath(curProjFile)
        require('xe.win.Setting').setVar('projpath', curProjDir)
        require('xe.win.Setting').save()
        --M.saveEditorSetting(setting)
        --logger.log(string.format("current project file: %s", getNameFromPath(curProjFile)), "Info")
        logger.log(string.format("current project file:   %s", curProjFile), "Info")
        logger.log(string.format("current project folder: %s", M.GetCurProjDir()), "Info")
    end
end

function M.saveToFile(path)
    print('proj saveToFile')
    --
end

function M.loadFromFile(path)
    print('proj loadFromFile')
    --
end

function M.autoSave()
    print('proj autoSave')
    --
end

function M.compileToFile()
    print('proj compileToFile')
    --
end

function M.save(event)
    print('proj save')
    --
end

function M.saveAs(event)
    print('proj saveAs')
    --
end

function M.needSave()
    print('proj needSave')
    --
end

function M.close(onFinish)
    print('proj close')
    --
end

function M.open()
    print('proj open')
end

function M.new()
    print('proj new')
    --
end

function M.pack()
    print('proj pack')
    --
end

function M.compileToString(...)
    local f = { _contents = {} }
    f.write = function(_, str)
        table.insert(f._contents, str)
    end
    f.close = function()
    end
    local msg = M.CompileToFile(f, ...)
    if not msg then
        return table.concat(f._contents)
    else
        OutputLog(msg, 'Error')
    end
end

function M.onQuit()
    M.close(function()
        GameExit()
    end)
end

function M.launchGame()
    print('proj launchGame')
    --
end

function M.addPackRes(path, from_type)
    print('proj addPackRes')
    --
end

return M
