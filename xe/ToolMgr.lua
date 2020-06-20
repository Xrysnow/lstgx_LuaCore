--
local M = {}
local proj = require('xe.Project')
local his = require('xe.history')
local logger = require('xe.logger')

---@return xe.SceneTree
local function get_tree()
    return assert(require('xe.main').getEditor():getTree())
end

local function check_return(msg)
    if type(msg) == 'string' then
        logger.log(msg, "Error")
        return msg
    end
end

--

function M.new()
    return check_return(proj.new())
end

function M.open()
    return check_return(proj.open())
end

function M.save()
    return check_return(proj.save())
end

function M.close()
    return check_return(proj.close())
end

--

function M.merge()
    if not proj.getFile() then
        return
    end
    local path = require('xe.Project').getDir()
    local fileName, err = require('platform.FileDialog').open('lstgxproj,luastg', path)
    if fileName and fileName ~= '' then
        --local fileName = fd:GetPath()
        local msg = proj.loadFromFile(fileName, true)
        if msg == nil then
            -- record history
            his.clear()
        else
            logger.log(msg, "Error")
            return msg
        end
    else
        logger.log(err, "Info")
    end
end

--

function M.undo()
    if not proj.getFile() then
        return
    end
    if true then
        his.undo(function(op)
            op.undo()
        end)
    end
end

function M.redo()
    if not proj.getFile() then
        return
    end
    if true then
        his.redo(function(op)
            op.exe()
        end)
    end
end

function M.delete()
    if not proj.getFile() then
        return
    end
    local op, ok = get_tree():deleteCurrent()
    if op and ok then
        his.add(op)
    end
end

function M.copy()
    if not proj.getFile() then
        return
    end
    get_tree():copyCurrent()
end

function M.cut()
    if not proj.getFile() then
        return
    end
    local op, ok = get_tree():cutCurrent()
    if op and ok then
        his.add(op)
    end
end

function M.paste()
    if not proj.getFile() then
        return
    end
    local op, ok = get_tree():pasteToCurrent()
    if op and ok then
        his.add(op)
    end
end

function M.setting()
    if not proj.getFile() then
        return
    end
    require('xe.win.Setting').show()
end

function M.pack()
    if not proj.getFile() then
        return
    end
    local s = proj.compileToString(proj.getRoot(), 0)
    --TODO
    if s then
        cc.FileUtils:getInstance():writeStringToFile(s, '_output.lua')
    end
    --local msg = proj.pack(false, nil, nil)
    --if msg then
    --    logger.log(msg, "Error")
    --end
end

function M.debugStage()
    if not proj.getFile() then
        return
    end
    if check_return(proj.pack(true, nil, nil)) == nil then
        proj.launchGame()
    end
end

function M.debugSC()
    if not proj.getFile() then
        return
    end
    local scDebugNode = get_tree():getCurrent()
    if not scDebugNode then
        return
    end
    if scDebugNode:getType() ~= 'bossspellcard' then
        logger.log('current node is not a spell card node', "Error")
    else
        if check_return(proj.pack(false, nil, scDebugNode)) == nil then
            proj.launchGame()
        end
    end
end

function M.run()
    if not proj.getFile() then
        return
    end
    if check_return(proj.pack(false, nil, nil)) == nil then
        proj.launchGame()
    end
end

function M.insertAfter()
    print('setInsertPos after')
    get_tree():setInsertPos('after')
end
function M.insertBefore()
    print('setInsertPos before')
    get_tree:setInsertPos('before')
end
function M.insertChild()
    print('setInsertPos child')
    get_tree:setInsertPos('child')
end

local lineNum = 0
local function count_line(s)
    local _, n = s:gsub("\n", "\n")
    lineNum = lineNum - n
end

---@param node xe.ui.TreeNode
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
    local curProjFile = require('xe.Project').getFile()
    if curProjFile then
        lineNum = tonumber(lineNumText:GetValue())
        if lineNum == nil then
            require('xe.ui.MessageBox').OK('Error', "Must input an integer")
            --lineNumText:SetValue("")
            return
        end
        --local projectTree = projMgr.getTree()
        local rootNode = proj.getRoot()
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
        require('xe.ui.MessageBox').OK('Info', "End of project is reached")
    end
end

function M.find()
    if not proj.getFile() then
        return
    end
    GoToLineNum()
    --TODO
end

function M.moveDown()
    if not proj.getFile() then
        return
    end
    local cur = proj.getTree():getCurrent()
    if cur then
        cur:moveDown()
    end
end

function M.moveUp()
    if not proj.getFile() then
        return
    end
    local cur = proj.getTree():getCurrent()
    if cur then
        cur:moveUp()
    end
end

function M.getNodeHandler(name)
    --TODO
    return function()
        require('xe.main').getEditor():getTree():newNode(name)
    end
end

return M
