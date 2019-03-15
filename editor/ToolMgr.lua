--
local M = {}
local treeMgr = require('editor.TreeMgr')
local projMgr = require('editor.ProjectMgr')
local Tree = require('editor.TreeHelper')
local his = require('editor.History')

local function get_tree()
    local ret = require('editor.main').getMainTree()
    assert(ret)
    return ret
end

local function check_return(msg)
    if msg then
        OutputLog(msg, "Error")
        return msg
    end
end

function M.ToolNew()
    return check_return(require('editor.ProjectMgr').NewProj())
end

function M.ToolOpen()
    return check_return(require('editor.ProjectMgr').OpenProj())
end

function M.ToolSave()
    if not projMgr.GetCurProjFile() then
        Print('[ToolSave] no project')
        return
    end
    return check_return(require('editor.ProjectMgr').SaveProj())
end

function M.ToolClose()
    if not projMgr.GetCurProjFile() then
        Print('[ToolClose] no project')
        return
    end
    return require('editor.ProjectMgr').CloseProj(function(closed)
        if closed then
            OutputLog('project closed', 'Info')
        end
    end)
end

function M.ToolMerge()
    if not projMgr.GetCurProjFile() then
        return
    end
    local fileName, err = require('platform.FileDialog').open('luastg', setting.projpath)
    if fileName and fileName ~= '' then
        --local fileName = fd:GetPath()
        local msg = projMgr.LoadFromFile(fileName, true)
        if msg == nil then
            -- record history
            --treeMgr.TreeShotUpdate()
            --projectTree:SetFocus()
            his.clear()
        else
            OutputLog(msg, "Error")
            return msg
        end
    else
        OutputLog(err, "Info")
    end
end

function M.ToolUndo()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        his.undo(function(op)
            op.undo()
        end)
    end
end

function M.ToolRedo()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        his.redo(function(op)
            op.exe()
        end)
    end
end

function M.ToolDelete()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        treeMgr.DeleteCurrent()
    end
end

function M.ToolCopy()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        treeMgr.CopyCurrent()
    end
end

function M.ToolCut()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        treeMgr.CutCurrent()
    end
end

function M.ToolPaste()
    if not projMgr.GetCurProjFile() then
        return
    end
    if treeMgr.IsFocused() then
        treeMgr.PasteToCurrent()
    end
end

function M.ToolSetting()
    if not projMgr.GetCurProjFile() then
        return
    end
    local di = require('editor.dialog.Setting')()
    local setting = require('editor.setting')
    local x, y = setting:getGameRes()
    di:setCheat(setting:getCheat())
    di:setWindowed(setting:getGameWindowed())
    di:setResX(x)
    di:setResY(y)
    di:setOnConfirm(function()
        setting:setCheat(di:isCheat())
        setting:setGameRes(di:getResX(), di:getResY())
        setting:setGameWindowed(di:isWindowed())
    end)
end

function M.ToolPack()
    if not projMgr.GetCurProjFile() then
        return
    end
    local s = projMgr.CompileToString(projMgr.GetRootNode(), 0)
    if s then
        cc.FileUtils:getInstance():writeStringToFile(s, '_output.lua')
    end
    --local msg = projMgr.PackProj(false, nil, nil)
    --if msg then
    --    OutputLog(msg, "Error")
    --end
end

function M.ToolDebugStage()
    if not projMgr.GetCurProjFile() then
        return
    end
    if check_return(projMgr.PackProj(true, nil, nil)) == nil then
        projMgr.LaunchGame()
    end
end

function M.ToolDebugSC()
    if not projMgr.GetCurProjFile() then
        return
    end
    local scDebugNode = get_tree():getCurrent()
    if not scDebugNode then
        return
    end
    if scDebugNode:getType() ~= 'bossspellcard' then
        OutputLog('current node is not a spell card node', "Error")
    else
        if check_return(projMgr.PackProj(false, nil, scDebugNode)) == nil then
            projMgr.LaunchGame()
        end
    end
end

function M.ToolRun()
    if not projMgr.GetCurProjFile() then
        return
    end
    if check_return(projMgr.PackProj(false, nil, nil)) == nil then
        projMgr.LaunchGame()
    end
end

function M.ToolInsertAfter()
    require('editor.tree').setInsertPos('after')
end
function M.ToolInsertBefore()
    require('editor.tree').setInsertPos('before')
end
function M.ToolInsertChild()
    require('editor.tree').setInsertPos('child')
end

local lineNum = 0
local function count_line(s)
    local _, n = string.gsub(s, "\n", "\n")
    lineNum = lineNum - n
end

---@param node editor.TreeNode
local function FindNode(node)
    local head = node:toHead()
    local foot = node:toFoot()
    if head then
        count_line(head)
    end
    if lineNum <= 0 then
        node:select()
        return true
    end
    for i = 1, node:getChildrenCount() do
        if FindNode(node:getChildAt(i)) then
            return true
        end
    end
    if foot then
        count_line(foot)
    end
    if lineNum <= 0 then
        node:select()
        return true
    end
end
local function GoToLineNum()
    local curProjFile = require('editor.ProjectMgr').GetCurProjFile()
    if curProjFile then
        lineNum = tonumber(lineNumText:GetValue())
        if lineNum == nil then
            require('ui.MessageBox').OK('Error', "Must input an integer")
            --lineNumText:SetValue("")
            return
        end
        --local projectTree = projMgr.GetProjectTree()
        local rootNode = projMgr.GetRootNode()
        --for child in Tree.Children(projectTree, rootNode) do
        --    if FindNode(child) then
        --        projectTree:SetFocus()
        --        return
        --    end
        --end
        for i = 1, rootNode:getChildrenCount() do
            if FindNode(rootNode:getChildAt(i)) then
                --projectTree:SetFocus()
                return
            end
        end
        require('ui.MessageBox').OK('Info', "End of project is reached")
    end
end

function M.ToolFind()
    if not projMgr.GetCurProjFile() then
        return
    end
    GoToLineNum()
end
--lineNumText:Connect(wx.wxEVT_COMMAND_TEXT_ENTER, function(event)
--    GoToLineNum()
--end)

function M.ToolMoveDown()
    if not projMgr.GetCurProjFile() then
        return
    end
    local cur = projMgr.GetProjectTree():getCurrent()
    if cur then
        cur:moveDown()
    end
end

function M.ToolMoveUp()
    if not projMgr.GetCurProjFile() then
        return
    end
    local cur = projMgr.GetProjectTree():getCurrent()
    if cur then
        cur:moveUp()
    end
end

return M
