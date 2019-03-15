--
local M = {}
local Tree = require('editor.TreeHelper')
local projMgr = require('editor.ProjectMgr')
local his = require('editor.History')

M.treeShot = {}
M.treeShotPos = 0
local insertPos = "after"
local savedPos = 0
local curNode

local function OutputLog()
end

function M.IsValid(node)
    --if node and Tree.data[node:GetValue()] then
    if node and node:getView() then
        return true
    else
        return false
    end
end
local IsValid = M.IsValid

function M.IsRoot(node)
    if node == nil then
        return false
    else
        local rootNode = projMgr.GetRootNode()
        --return node:GetValue() == rootNode:GetValue()
        return node == rootNode
    end
end

function M.IsFocused()
    return true
end

local function GetProjectTree()
    return require('editor.ProjectMgr').GetProjectTree()
end

local function GetRootNode()
    return require('editor.ProjectMgr').GetProjectTree():getRoot()
end

function M.GetInsertPos()
    return insertPos
end
function M.SetInsertPos(pos)
    insertPos = pos
end
function M.ResetTreeShot()
    M.treeShot = {}
    M.treeShotPos = 0
end
---@return editor.TreeNode
function M.GetCurNode()
    return GetProjectTree():getCurrent()
end
function M.GetNodeType()
    return require('editor.node_def._def').getNodeType()
end

function M.CheckAnc(data, ancStack)
    local ret
    local nodeType = M.GetNodeType()
    local anc = nodeType[data.type].needancestor
    if anc then
        ret = false
        for _, v in ipairs(ancStack) do
            if anc[v] then
                ret = true
            end
        end
    else
        ret = true
    end
    if not ret then
        local needed = {}
        for k, v in pairs(anc) do
            if type(k) == 'string' then
                table.insert(needed, k)
            end
        end
        OutputLog(string.format('%q need ancestor: %s', data.type, table.concat(needed, '/')), "error")
        return false
    end
    local anc = nodeType[data.type].forbidancestor
    if anc then
        for _, v in ipairs(ancStack) do
            if anc[v] then
                OutputLog(string.format('%q forbid ancestor: %s', data.type, v), "error")
                return false
            end
        end
    end
    if data.child then
        table.insert(ancStack, data.type)
        for _, child in ipairs(data.child) do
            ret = (ret and M.CheckAnc(child))
        end
        ancStack[#ancStack] = nil
    end
    return ret
end

function M.TreeShotUpdate()
    --local projectTree = projMgr.GetProjectTree()
    --local rootNode = projMgr.GetRootNode()
    --local tmp = {}
    --for node in Tree.Children(projectTree, rootNode) do
    --    table.insert(tmp, Tree.Ctrl2Data(projectTree, node))
    --end
    --M.treeShotPos = M.treeShotPos + 1
    --M.treeShot[M.treeShotPos] = tmp
    --for i = M.treeShotPos + 1, #M.treeShot do
    --    M.treeShot[i] = nil
    --end
end

---@param curNode editor.TreeNode
function M.SubmitAttr()
    local changed = false
    local tree = GetProjectTree()
    if IsValid(tree:getCurrent()) then
        local op = tree:submitAttrToCurrent()
        if op then
            changed = true
            op.exe()
            his.add(op)
        end
    end
    return changed
end

--[[
---@param node editor.TreeNode
function M.InsertNode(tree, node, data)
    if not require('editor.ProjectMgr').GetCurProjFile() then
        return
    end
    --tree:SetFocus()
    local parent, pos, ret
    if insertPos == "child" or node:isRoot() then
        parent = node
        pos = -1
    elseif insertPos == "after" then
        --parent = tree:GetItemParent(node)
        parent = node:getParentNode()
        pos = node
    else
        --parent = tree:GetItemParent(node)
        parent = node:getParentNode()
        pos = tree:GetPrevSibling(node)--TODO
    end
    --
    local ptype
    if IsValid(parent) then
        --ptype = Tree.data[parent:GetValue()]["type"]
        ptype = parent:getType()
    else
        ptype = "root"
    end
    --local ctype = data.type
    local ctype = node:getType()
    local nodeType = M.GetNodeType()
    if ptype ~= "root" then
        if nodeType[ptype].allowchild and not nodeType[ptype].allowchild[ctype] then
            OutputLog(string.format('can not insert %q as child of %q', ctype, ptype), "Error")
            return
        end
        if nodeType[ptype].forbidchild and nodeType[ptype].forbidchild[ctype] then
            OutputLog(string.format('can not insert %q as child of %q', ctype, ptype), "Error")
            return
        end
    end
    if nodeType[ctype].allowparent and not nodeType[ctype].allowparent[ptype] then
        OutputLog(string.format('can not insert %q as child of %q', ctype, ptype), "Error")
        return
    end
    if nodeType[ctype].forbidparent and nodeType[ctype].forbidparent[ptype] then
        OutputLog(string.format('can not insert %q as child of %q', ctype, ptype), "Error")
        return
    end
    --
    local ancStack = {}
    local pnode = parent
    while IsValid(pnode) do
        table.insert(ancStack, Tree.data[pnode:GetValue()]["type"])
        pnode = tree:GetItemParent(pnode)
    end
    if not M.CheckAnc(data, ancStack) then
        return
    end
    --
    ret = Tree.Data2Ctrl(tree, parent, pos, data)
    --tree:Expand(parent)
    --tree:SelectItem(ret)
    parent:unfold()
    ret:select()
    --M.TreeShotUpdate()
    projMgr.AutoSave()
    --TreeShotUpdate()
    --AutoSave()
    --
    return ret
end
]]

--local _picker

---@param node editor.TreeNode
function M.GetPicker(type, node, idx)
    --local panel = require('editor.main').getPropertyPanel()
    local _picker = {
        sound            = function()
            require('editor.dialog.SelectSoundEffect').show(idx, node)
        end,
        image            = function()
            require('editor.dialog.SelectImage').show(idx, node)
        end,
        selecttype       = function()
            require('editor.dialog.SelectObjectClass').show(idx, node)
        end,
        param            = function()
            require('editor.dialog.InputParameter').show(idx, node)
        end,
        typename         = function()
            require('editor.dialog.InputTypeName').show(idx, node)
        end,
        selectenemystyle = function()
            require('editor.dialog.EnemyStyleEnumPicker').show(idx, node)
        end,
        bulletstyle      = function()
            require('editor.dialog.BulletStyleEnumPicker').show(idx, node)
        end,
        color            = function()
            require('editor.dialog.ColorEnumPicker').show(idx, node)
        end,
    }
    return _picker[type]
end
--[[
function M.EditAttr(attrIndex)
    local curNode = M.GetCurNode()
    if not IsValid(curNode) then
        return
    end
    local type = curNode:getType()
    --_G['attrIndex'] = attrIndex
    local enum = curNode:getConfig()[attrIndex][2]
    local picker = M.GetPicker(enum, curNode, attrIndex)
    if picker then
        picker()
    elseif enum == "resfile" then
        local wildCard
        if type == 'loadsound' or type == 'loadbgm' then
            --wildCard = "Audio file (*.wav;*.ogg)|*.wav;*.ogg"
            wildCard = { "wav", "ogg" }
        elseif type == 'loadimage' or type == 'loadani' or type == 'bossdefine' then
            --wildCard = "Image file (*.png;*.jpg;*.bmp)|*.png;*.jpg;*.bmp"
            wildCard = { "png", "jpg", "bmp" }
        elseif type == 'loadparticle' then
            --wildCard = "Particle system info file (*.psi)|*.psi"
            wildCard = "psi"
        elseif type == 'patch' then
            --wildCard = "Lua file (*.lua)|*.lua"
            wildCard = "lua"
        elseif type == 'loadFX' then
            --wildCard = "FX file (*.fx)|*.fx"
            wildCard = "fx"
        else
            --wildCard = "All types (*.*)|*.*"
            wildCard = ""
        end
        local curProjDir = require('editor.ProjectMgr').GetCurProjDir()
        local path = require('platform.FileDialog').open(wildCard, curProjDir)
        if path and path ~= '' then
            local panel = require('editor.main').getPropertyPanel()
            --local fn = wx.wxFileName(path)
            --if not fn:MakeRelativeTo(curProjDir) then
            --    OutputLog("It is recommended that resource file path is relative to project path.", "Warning")
            --end
            local fp = cc.FileUtils:getInstance():fullPathForFilename(path)
            if type == 'bossdefine' then
                --attrCombo[5]:SetValue(fp)
                panel:setValue(5, fp)
            elseif type == 'patch' then
                --attrCombo[1]:SetValue(fp)
                panel:setValue(1, fp)
            else
                panel:setValue(1, fp)
                panel:setValue(2, string.filename(fp))
                if type == 'loadparticle' then
                    local f, msg = io.open(path, 'rb')
                    if f == nil then
                        OutputLog(msg, "Error")
                    else
                        local s = f:read(1)
                        f:close()
                        local val = 'parimg' .. (string.byte(s, 1) + 1)
                        --attrCombo[3]:SetValue(val)
                        panel:setValue(3, val)
                    end
                end
            end
            M.SubmitAttr()
        end
    else
        require('editor.dialog.EditText').show(attrIndex, curNode)
    end
end

function M.OnSelChanged()
    M.SubmitAttr()
    local curNode = M.GetCurNode()
    if curNode and not curNode:isRoot() then
        require('editor.main').getPropertyPanel():showNode(curNode)
        if curNode:getAttrValue(1) == "" and curNode:getConfig().editfirst then
            --attrIndex = 1
            M.EditAttr(1)
        end
    else
        require('editor.main').getPropertyPanel():showNode(nil)
        --typeNameLabel:SetLabel("Node type: project")
    end
end

---@param node editor.TreeNode
function M.OnDeleteItem(node)
    --local item_id = node:getID()
    --local nodeType = M.GetNodeType()
    if node:getConfig().watch then
        Tree.watch[node:getConfig().watch][node] = nil
    end
    Tree.data[node] = nil
end

function M.OnKeyDown(event)
    --if event:GetKeyCode() == wx.WXK_RETURN and IsValid(curNode) then
    --    if #(Tree.data[curNode:GetValue()].attr) ~= 0 then
    --        --attrIndex = 1
    --        EditAttr(event, 1)
    --    end
    --end
    ----event:Skip()
end

function M.OnItemRightClick(event)
    --projectTree:SelectItem(event:GetItem())
    --if IsValid(curNode) then
    --    if #(Tree.data[curNode:GetValue()].attr) ~= 0 then
    --        --attrIndex = 1
    --        EditAttr(event, 1)
    --    end
    --end
    --event:Skip()
end
]]

--[[
function M.Delete(node)
    local nodeType = M.GetNodeType()
    if M.IsValid(curNode) and not nodeType[curNode:getType()].forbiddelete then
        local clone = curNode:getClone()
        local id = curNode:getID()
        local idx = curNode:getIndex()
        local pid = curNode:getParentNode():getID()
        local op = {
            exe  = function()
                local node = GetProjectTree():getNodeByID(id)
                if node then
                    node:delete()
                end
            end,
            undo = function()
                local p = GetProjectTree():getNodeByID(pid)
                if p then
                    p:insertChildAt(idx, clone())
                end
            end
        }
        op.exe()
        his.add(op)
    end
end
]]
function M.DeleteCurrent()
    local nodeType = M.GetNodeType()
    if M.IsValid(curNode) and not nodeType[curNode:getType()].forbiddelete then
        local clone = curNode:getClone()
        local id = curNode:getID()
        local idx = curNode:getIndex()
        local pid = curNode:getParentNode():getID()
        local op = {
            exe  = function()
                local node = GetProjectTree():getNodeByID(id)
                if node then
                    node:delete()
                end
            end,
            undo = function()
                local p = GetProjectTree():getNodeByID(pid)
                if p then
                    p:insertChildAt(idx, clone())
                end
            end
        }
        op.exe()
        his.add(op)
    end
end

function M.CopyCurrent()
    local curNode = GetProjectTree():getCurrent()
    if M.IsValid(curNode) then
        require('platform.ClipBoard').set("\001LuaSTG" .. curNode:serialize())
    end
end

function M.CutCurrent()
    local curNode = GetProjectTree():getCurrent()
    if M.IsValid(curNode) and not curNode:getConfig().forbiddelete then
        require('platform.ClipBoard').set("\001LuaSTG" .. curNode:serialize())
        M.DeleteCurrent()
    end
end

function M.PasteToCurrent()
    local curNode = GetProjectTree():getCurrent()
    if M.IsValid(curNode) or curNode:isRoot() then
        local cp = require('platform.ClipBoard').get()
        if cp and string.sub(cp, 1, 7) == "\001LuaSTG" then
            local str = string.sub(cp, 8, -1)
            local ctor = require('editor.tree_node').deserialize(str)
            local op = GetProjectTree():insertCurrent(ctor)
            if op then
                op.exe()
                his.add(op)
            end
            --M.InsertNode(projectTree, curNode, Tree.DeSerialize(string.sub(cp, 8, -1)))
        end
    end
end

return M
