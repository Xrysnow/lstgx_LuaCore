local M = {}
local Tree = require('editor.TreeHelper')
--local require('editor.TreeMgr') = require('editor.TreeMgr')
--local NodeConfig = require('editor.NodeConfig')
local his = require('editor.History')

local frame = {}

--
local function getDirFromPath(path)
    return string.filefolder(path)
end
---Returns the name part of the filename (without extension).
local function getNameFromPath(path)
    return string.filename(path, false)
end
--TODO
local function writeFile(path, str)
    --cc.FileUtils:getInstance():writeStringToFile()
    local f, msg = io.open(path, "w")
    if f == nil then
        return msg
    end
    f:write(str)
    f:close()
end

local setting = {}
function OutputLog(msg, icon)
    --logHtml = string.format('%s<p><img src="editor/images/%s.png">%s</p>\n', logHtml, icon, msg)
    --logWindow:SetPage(logHtml)
    --logWindow:Scroll(-1, 65536)
    Print(string.format('[%s] %s', icon, msg))
end
local function ClearLog()
end

---@type editor.Tree
local projectTree
---@type editor.TreeNode
local rootNode

local curProjFile
local curProjDir
local _luastg_version = 0x1000

local savedPos = 0

function M.GetCurProjFile()
    return curProjFile
end

function M.GetCurProjDir()
    if curProjFile then
        return string.filefolder(curProjFile)
    end
    --return curProjFile
end

function M.GetProjectTree()
    return projectTree
end

---@return editor.TreeNode
function M.GetRootNode()
    return rootNode
end

--TODO
function M.SaveEditorSetting(t)
    writeFile("editor/EditorSetting.lua", "setting=" .. Tree.Serialize(t))
end

function M.SetCurProjFile(s)
    curProjFile = s
    if s == nil then
        SetTitle("LuaSTG-x Editor")
        curProjDir = nil
        ClearLog()
    else
        --SetTitle(curProjFile .. " - LuaSTG-x Editor")
        SetTitle(getNameFromPath(curProjFile) .. " - LuaSTG-x Editor")
        curProjDir = getDirFromPath(curProjFile)
        setting.projpath = curProjDir
        M.SaveEditorSetting(setting)
        --OutputLog(string.format("current project file: %s", getNameFromPath(curProjFile)), "Info")
        OutputLog(string.format("current project file:   %s", curProjFile), "Info")
        OutputLog(string.format("current project folder: %s", M.GetCurProjDir()), "Info")
    end
end

function M.SaveToFile(path)
    --local tmp = {}
    --for node in Tree.Children(projectTree, rootNode) do
    --    table.insert(tmp, Tree.Ctrl2Data(projectTree, node))
    --end
    --tmp._proj_version = _luastg_version
    writeFile(path, projectTree:serialize())
end

function M.LoadFromFile(path, ignore_setting)
    --local f, msg = io.open(path, "r")
    --if f == nil then
    --    return msg
    --end
    --local content = f:read("*a")
    --f:close()

    local fu = cc.FileUtils:getInstance()
    if not fu:isFileExist(path) then
        return string.format('%s: %s', i18n('file not exist'), path)
    end

    local content = cc.FileUtils:getInstance():getStringFromFile(path)
    assert(content)
    Print(string.format('read from %s: %dbytes', path, #content))
    --local tmp = Tree.DeSerialize(content)
    --if tmp._proj_version and tmp._proj_version > _luastg_version then
    --    return 'LuaSTG version is too low.'
    --end
    if not projectTree then
        projectTree = require('editor.main').getMainTree()
        rootNode = projectTree:getRoot()
    end
    projectTree:reset()
    projectTree:deserialize(content)
    --for i = 1, #tmp do
    --    if not ignore_setting or tmp[i]["type"] ~= "setting" then
    --        Tree.Data2Ctrl(projectTree, rootNode, -1, tmp[i])
    --    end
    --end
end

local auto_save_counter = 1
function M.AutoSave()
    if curProjFile then
        local msg = M.SaveToFile(curProjFile .. ".bak." .. (auto_save_counter % 4))
        if msg ~= nil then
            OutputLog(msg, "Error")
            return msg
        end
        auto_save_counter = auto_save_counter + 1
    end
end

local function ApplyDepth(s, depth)
    local ret = string.gsub(s, "\n", "\n" .. string.rep(' ', depth * 4))
    if string.sub(s, -1) == "\n" then
        ret = string.sub(ret, 1, -1 - depth * 4)
    end
    return string.rep(' ', depth * 4) .. ret
end

---@param node editor.TreeNode
---@param scDebugNode editor.TreeNode
function M.CompileToFile(f, node, depth, attrCombo, debugNode, scDebugNode)
    --local data = Tree.data[node:GetValue()]
    local check, checkafter, msg
    -- check for every attr
    for i = 1, node:getAttrCount() do
        local ret
        ret, msg = node:checkAttr(i)
        if not ret then
            node:select()
            --attrCombo[i]:SetFocus()
            return string.format(
                    "Attribute %q is invalid: %s",
                    node:getAttrName(i), msg or '???')
        end
    end
    -- check for whole node
    check, msg = node:checkBeforeCompile()
    if not check then
        node:select()
        return msg or '???'
    end
    -- debug
    if debugNode and debugNode[2] == node then
        f:write('end ')
    end
    -- head
    local head = node:toHead()
    if head then
        f:write(ApplyDepth(head, depth))
    end
    -- child
    for i = 1, node:getChildrenCount() do
        local child = node:getChildAt(i)
        msg = M.CompileToFile(f, child, depth + node:getCodeIndent())
        if msg ~= nil then
            return msg
        end
    end
    -- foot
    local foot = node:toFoot()
    if foot then
        f:write(ApplyDepth(foot, depth))
    end
    -- debug
    if debugNode and debugNode[1] == node then
        f:write('if false then ')
    end
    local NodeConfig = require('editor.node_def._checker')
    if scDebugNode and scDebugNode == node then
        NodeConfig.className = scDebugNode:getParentNode():getAttrValue(1)
        f:write(string.format(
                "_boss_class_name = %q ",
                NodeConfig.className))
        f:write(string.format(
                "_editor_class[%q].cards = {boss.move.New(0,144,60,MOVE_NORMAL), _tmp_sc} ",
                NodeConfig.className))
    end
    -- after check
    checkafter, msg = node:checkAfterCompile()
    if not checkafter then
        node:select()
        return msg or '???'
    end
end

function M.SaveProj(event)
    require('editor.TreeMgr').SubmitAttr()
    if curProjFile then
        local msg = M.SaveToFile(curProjFile)
        if msg ~= nil then
            OutputLog(msg, "Error")
            return msg
        end
        --savedPos = require('editor.TreeMgr').treeShotPos
    end
end

function M.SaveProjAs(event)
    require('editor.TreeMgr').SubmitAttr()
    if curProjFile then
        --local fd = wx.wxFileDialog(
        --        frame, "Save project",
        --        setting.projpath,
        --        "",
        --        "LuaSTG project (*.luastg)|*.luastg|All files (*.*)|*.*",
        --        wx.wxFD_SAVE + wx.wxFD_OVERWRITE_PROMPT)
        local fd, msg = require('platform.FileDialog').save('luastg', setting.projpath)
        if fd then
            local fileName = fd--:GetPath()
            local msg = M.SaveToFile(fileName)
            if msg == nil then
                M.SetCurProjFile(fileName)
                --savedPos = require('editor.TreeMgr').treeShotPos
            else
                OutputLog(msg, "Error")
                return msg
            end
        end
    end
end

function M.IsNeedSave()
    --return savedPos ~= require('editor.TreeMgr').treeShotPos
    return true
end

function M.CloseProj(onFinish)
    onFinish = onFinish or function()
    end
    if curProjFile then
        local onConfirm = function()
            local msg = M.SaveProj()
            if msg == nil then
                projectTree:reset()
                Tree.data = {}
                his.clear()
                M.SetCurProjFile(nil)
                onFinish(true)
            else
                OutputLog(msg, 'Error')
            end
        end
        local onReject = function()
            projectTree:reset()
            Tree.data = {}
            his.clear()
            M.SetCurProjFile(nil)
            onFinish(true)
        end
        local onCancel = function()
            --OutputLog('close project cancelled', 'Info')
            onFinish()
        end
        if M.IsNeedSave() then
            --local msg = 'Save file "' .. curProjFile .. '" ?'
            local msg = string.format('%s "%s" ?', i18n('Save file'), curProjFile)
            require('cc.ui.MessageBox').Yes_No_Cancel('', msg, onConfirm, onReject, onCancel)
        else
            onReject()
        end
    else
        onFinish()
    end
end

function M.OpenProj()
    M.CloseProj(function()
        local path, msg = require('platform.FileDialog').open('luastg', setting.projpath)
        if path then
            local fileName = path
            msg = M.LoadFromFile(fileName)
            if msg == nil then
                M.SetCurProjFile(fileName)
                M.GetRootNode():unfold()
                --treeMgr.TreeShotUpdate()
                --savedPos = 1
                --projectTree:SetFocus()
                his.clear()
                return
            end
        end
        OutputLog(msg, "Error")
    end)
end

function M.NewProj()
    M.CloseProj(function()
        local di = require('editor.dialog.NewProject')()
        di:setOnConfirm(function()
            local fileName = di:getPath()
            if fileName == "" then
                --require('ui.MessageBox').OK('Error', "Please specify file path!")
                require('cc.ui.MessageBox').OK('Error', string.format('%s!', i18n('Please specify file path')))
                return
            end
            local templates = { 'empty', 'singlestage', 'spellcard', 'touhou' }
            local msg = M.LoadFromFile(
                    "editor/templates/" .. templates[di:getMode() + 1] .. '.luastg')
            if msg == nil then
                local msg2 = M.SaveToFile(fileName)
                if msg2 == nil then
                    --projectTree:Expand(rootNode)
                    projectTree:getRoot():unfold()
                    M.SetCurProjFile(fileName)
                    --M.TreeShotUpdate()
                    --savedPos = 1
                    his.clear()
                else
                    --Tree.data = {}
                    --projectTree:DeleteChildren(rootNode)
                    projectTree:reset()
                    OutputLog(msg2, "Error")
                end
            else
                OutputLog(msg, "Error")
            end
        end)
    end)
end

local _def_node_type = {
    enemydefine = true, bulletdefine = true, objectdefine = true,
    laserdefine = true, laserbentdefine = true, rebounderdefine = true }
local _init_node_type = {
    enemyinit = true, bulletinit = true, objectinit = true,
    laserinit = true, laserbentinit = true, rebounderinit = true }

---@param node editor.TreeNode
local function CalcParamNumAll(node)
    if _def_node_type[node:getType()] then
        local NodeConfig = require('editor.node_def._checker')
        for _, v in node:children() do
            if _init_node_type[v:getType()] then
                NodeConfig.paramNumDict[node:getAttrValue(1)] = NodeConfig.CalcParamNum(v:getAttrValue(1))
                break
            end
        end
    elseif node:getType() == 'folder' then
        for _, v in node:children() do
            CalcParamNumAll(v)
        end
    end
end

local outputName = ''

function M.PackProj(isDebug, debugNode, scDebugNode)
    if not curProjFile then
        return
    end
    require('editor.TreeMgr').SubmitAttr()
    local cfg = require('editor.node_def._checker')
    cfg.reset()

    local watchDict = cfg.watchDict
    --for k, v in pairs(require('editor.TreeMgr').treeShot[require('editor.TreeMgr').treeShotPos]) do
    --    CalcParamNumAll(v)
    --end
    for i = 1, rootNode:getChildrenCount() do
        local child = rootNode:getChildAt(i)
        CalcParamNumAll(child)
    end
    for key, wdata in pairs(Tree.watch) do
        watchDict[key] = {}
        if key == "sound" then
            for item, _ in pairs(wdata) do
                --watchDict[key][Tree.data[item].attr[2]] = true
                watchDict[key][item:getAttrValue(2)] = true
            end
        elseif key ~= 'image' then
            for item, _ in pairs(wdata) do
                --watchDict[key][Tree.data[item].attr[1]] = true
                watchDict[key][item:getAttrValue(1)] = true
            end
        end
    end
    watchDict.imageonly = {}
    --for k, v in pairs(Tree.watch.image) do
    --    if Tree.data[k]["type"] == 'loadimage' then
    --        watchDict.image['image:' .. Tree.data[k].attr[2]] = true
    --        watchDict.imageonly['image:' .. Tree.data[k].attr[2]] = true
    --    elseif Tree.data[k]["type"] == 'loadani' then
    --        watchDict.image['ani:' .. Tree.data[k].attr[2]] = true
    --    elseif Tree.data[k]["type"] == 'loadparticle' then
    --        watchDict.image['particle:' .. Tree.data[k].attr[2]] = true
    --    end
    --end
    for k, _ in pairs(Tree.watch.image) do
        local ty = k:getType()
        if ty == 'loadimage' then
            local name = k:getAttrValue(2)
            watchDict.image['image:' .. name] = true
            watchDict.imageonly['image:' .. name] = true
        elseif ty == 'loadani' then
            local name = k:getAttrValue(2)
            watchDict.image['ani:' .. name] = true
        elseif ty == 'loadparticle' then
            local name = k:getAttrValue(2)
            watchDict.image['particle:' .. name] = true
        end
    end
    for i = 1, rootNode:getChildrenCount() do
        local child = rootNode:getChildAt(i)
        if child:getType() == 'setting' then
            outputName = child:getAttrValue(1)
            break
        end
    end
    if outputName == 'unnamed' then
        --outputName = wx.wxFileName(curProjFile):GetName()
        outputName = string.filename(curProjFile)
    end
    local f, msg = io.open("editor\\tmp\\_pack_res.bat", "w")
    if f == nil then
        OutputLog(msg, "Error")
        return msg
    end
    f:write('del "..\\game\\mod\\' .. outputName .. '.zip"\n')
    f:write('..\\tools\\toutf8\\toutf8 .\\editor\\tmp\\_editor_output.lua\n')
    f:write('..\\tools\\7z\\7z u -tzip -mcu=on "..\\game\\mod\\' .. outputName .. '.zip" .\\editor\\root.lua .\\editor\\tmp\\_editor_output.lua\n')
    f:close()
    local f, msg = io.open("editor/tmp/_editor_output.lua", "w")
    if f == nil then
        OutputLog(msg, "Error")
        return msg
    end
    local debugCode
    local curNode = require('editor.TreeMgr').GetCurNode()
    if isDebug and curNode then
        local taskNode = curNode:getParentNode()
        if taskNode:getType() == 'stagetask' then
            local stageNode = taskNode:getParentNode()
            local groupNode = stageNode:getParentNode()
            debugCode = string.format(
                    "_debug_stage_name = '%s@%s'\nInclude 'THlib/UI/debugger.lua'\n",
                    stageNode:getAttrValue(1),
                    groupNode:getAttrValue(1))
            local firstNode = taskNode:getChildAt(1)
            if firstNode:getID() ~= curNode:getID() then
                debugNode = { firstNode, curNode }
            end
        else
            f:close()
            return "must debug from direct child node of stagetask node"
        end
    end
    for child in Tree.Children(projectTree, rootNode) do
        msg = M.CompileToFile(f, child, 0)
        if msg then
            f:close()
            projectTree:SetFocus()
            return msg
        end
    end
    if debugCode then
        f:write(debugCode)
    end
    if scDebugNode then
        f:write("Include 'THlib/UI/scdebugger.lua'\n")
    end
    f:close()
    os.execute()
    os.execute('editor/tmp/_pack_res.bat > pack_log.txt')
end

function M.CompileToString(...)
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

function M.OnQuit()
    M.CloseProj(function()
        GameExit()
    end)
    --if msg == nil then
    --    event:Skip()
    --    wx.wxExit()
    --end
end

function M.LaunchGame()
    start_game = true
    is_debug = true
    --setting.nosplash = true
    cheat = setting.cheat
    updatelib = setting.updatelib
    _G['setting'].mod = outputName
    for _, v in ipairs({ 'windowed', 'resx', 'resy' }) do
        _G['setting'][v] = setting[v]
    end
end

function M.addPackRes(path, from_type)

end

return M
