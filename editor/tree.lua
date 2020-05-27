---@class editor.Tree:ccui.Widget
local M = class('editor.tree', ccui.Widget)
local nodeType = require('editor.node_def._def').getNodeType()
local log = require('editor.Logger').log
local Tree = require('editor.TreeHelper')
local _insert_pos = 'child'

function M:ctor(param)
    require('editor.node_def._def').regist()
    table.deploy(self, param, {
        size = cc.size(500, 600),
    })
    ---@type ui.TreeView
    local view = require('cc.ui.TreeView'):create()
    view:addTo(self):setContentSize(self.size)
    local root = require('editor.tree_node'):create('root', 'editor/images/16x16/folder.png', 'project')
    view:_setRoot(root)
    view:updatePosition()
    view:requestDoLayout()
    self.view = view
    ---@type editor.TreeNode
    self.root = view.root
    self.view.tree = self
    --self:onUpdate(function()
    --    Print(string.format('%d, %d',view.root:getPosition()))
    --end)
    --local root = view.root
    self:setContentSize(self.size)
end

function M:setContentSize(size)
    self.super.setContentSize(self, size)
    self.view:setContentSize(size):alignCenter()
    return self
end

---@return editor.TreeNode
function M.createNode(ico, text, props, onSeclect, onUnselect)
    props = props or {}
    assert(type(ico) == 'string')
    local ret = require('editor.tree_node'):create(
            ico,
            string.format('editor/images/16x16/%s.png', ico))
    return ret
end

function M:getRoot()
    return self.root
end

---@return editor.TreeNode
function M:getCurrent()
    return self.view:getCurrent()
end

function M:setCurrent(node)
    --node:select()
    return self.view:setCurrent(node)
end

function M.setInsertPos(pos)
    assert(pos == 'child' or pos == 'after' or pos == 'before')
    _insert_pos = pos
end

function M.getInsertPos()
    return _insert_pos
end

function M.checkAllow(parent, child)
    assert(parent and child)
    local ctype = child:getType()
    local ptype = parent:getType()
    --Print(string.format('check for %q => %q', ctype, ptype))
    local ct = nodeType[ctype]
    local pt = nodeType[ptype]
    if ptype == 'root' then
        pt = {}
    end
    if not child:isRoot() then
        if pt.allowchild and not pt.allowchild[ctype] then
            return false
        end
        if pt.forbidchild and pt.forbidchild[ctype] then
            return false
        end
    end
    if ct.allowparent and not ct.allowparent[ptype] then
        return false
    end
    if ct.forbidparent and ct.forbidparent[ptype] then
        return false
    end
    return true
end

---@param node editor.TreeNode
function M.checkAncestor(node)
    local ret
    local ty = node:getType()
    local anc = nodeType[ty].needancestor
    local ancStack = node:getAncestorTypes()
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
        log(string.format('%q need ancestor: %s', ty, table.concat(needed, '/')), "error")
        return false
    end
    local anc = nodeType[ty].forbidancestor
    if anc then
        for _, v in ipairs(ancStack) do
            if anc[v] then
                log(string.format('%q forbid ancestor: %s', ty, v), "error")
                return false
            end
        end
    end
    if node:getChildrenCount() > 0 then
        table.insert(ancStack, ty)
        for _, child in node:children() do
            ret = (ret and M.checkAncestor(child))
        end
        ancStack[#ancStack] = nil
    end
    return ret
end

---@param parent editor.TreeNode
---@param child editor.TreeNode
function M.insertNode(parent, child, idx)
    if not M.checkAllow(parent, child) then
        log(string.format('can not insert %q as child of %q',
                          child:getType(), parent:getType()), "Error")
        return
    end
    if not M.checkAncestor(child) then
        return
    end
    if idx then
        parent:insertChildAt(idx, child)
    else
        parent:insertChild(child)
    end
    parent:unfold()
    child:select()
end

---@param node editor.TreeNode
function M:insertCurrent(node_ctor)
    local p = _insert_pos
    if p == 'child' then
        return self:insertToCurrent(node_ctor)
    elseif p == 'after' then
        return self:insertAfterCurrent(node_ctor)
    elseif p == 'before' then
        return self:insertBeforeCurrent(node_ctor)
    else
        error('invalid insert position')
    end
    --self.view:setHighlighted(true)
end

local _getCtor

function M:insertDefault(type)
    _getCtor = _getCtor or require('editor.tree_node').getCtor
    return self:insertCurrent(_getCtor(type))
end

function M:insertOp(parent_id, child_ctor, idx)
    local pid = parent_id
    local cid
    local op = {
        exe  = function()
            local p = self:getNodeByID(pid)
            local c = child_ctor()
            assert(p and c)
            M.insertNode(p, c, idx)
            self:updateID()
            cid = c:getID()
            pid = p:getID()
        end,
        undo = function()
            local c = self:getNodeByID(cid)
            c:delete()
        end
    }
    op.exe()
    return op
end

function M:insertToCurrent(node_ctor)
    local cur = self:getCurrent()
    if not cur then
        return
    end
    return self:insertOp(cur:getID(), node_ctor)
end

function M:insertBeforeCurrent(node_ctor)
    local cur = self:getCurrent()
    if (not cur) or cur:isRoot() or (not cur:getParentNode()) then
        return
    end
    return self:insertOp(cur:getParentNode():getID(), node_ctor, cur:getIndex())
end

function M:insertAfterCurrent(node_ctor)
    local cur = self:getCurrent()
    if (not cur) or cur:isRoot() or (not cur:getParentNode()) then
        return
    end
    return self:insertOp(cur:getParentNode():getID(), node_ctor, cur:getIndex() + 1)
end

---@param node editor.TreeNode
function M.checkDelete(node)
    return M.isValid(node) and not nodeType[node:getType()].forbiddelete
end

function M:deleteOp(node_id)
    local id = node_id
    local ctor, idx, pid
    local op = {
        exe  = function()
            local node = self:getNodeByID(id)
            if not M.checkDelete(node) then
                log("can't delete node", 'Error')
                return
            end
            ctor = node:getClone()
            idx = node:getIndex()
            local p = node:getParentNode()
            node:delete()
            self:updateID()
            pid = p:getIndex()
        end,
        undo = function()
            local p = self:getNodeByID(pid)
            if not p then
                log("can't find parent", 'Error')
                return
            end
            local node = ctor()
            M.insertNode(p, node, idx)
            self:updateID()
            pid = p:getIndex()
            id = node:getID()
        end
    }
    op.exe()
    return op
end

function M:deleteCurrent()
    local cur = self:getCurrent()
    if not cur then
        return
    end
    return self:deleteOp(cur:getID())
end

function M:updateID()
    -- id is dynamic now
end

---@return editor.TreeNode
function M:getNodeByID(id)
    local n = self.view.root
    if id == n:getID() then
        return n
    end
    local idx = string.split(id, ' ')
    assert(#idx >= 2)
    for i = 2, #idx do
        local index = assert(tonumber(idx[i]))
        n = assert(n:getChildAt(index))
    end
    return n
end

---@param node editor.TreeNode
function M:submitAttr(node, values)
    local changed = false
    local val = table.clone(values)
    local rec_old = {}
    local rec_new = {}
    if M.isValid(node) then
        for i = 1, node:getAttrCount() do
            if not node:isAttrValueEqual(i, val[i]) then
                rec_old[i] = table.clone(node:getAttrValue(i))
                node:setAttrValue(i, val[i])
                rec_new[i] = table.clone(node:getAttrValue(i))
                --Print(string.format(
                --        '[%s] changed from %q to %q',
                --        node:getType(), rec_old[i], val[i]))
                changed = true
            end
        end
    end
    if changed then
        node:updateString()
        local id = node:getID()
        return {
            exe  = function()
                local n = self:getNodeByID(id)
                for k, v in pairs(rec_new) do
                    n:setAttrValue(k, v)
                end
                n:updateString()
            end,
            undo = function()
                local n = self:getNodeByID(id)
                for k, v in pairs(rec_old) do
                    n:setAttrValue(k, v)
                end
                n:updateString()
            end
        }
    end
end

function M:submitAttrToCurrent()
    local values = require('editor.main').getPropertyPanel():collectValues()
    return self:submitAttr(self:getCurrent(), values)
end

function M:submitAttrTo(node)
    local values = require('editor.main').getPropertyPanel():collectValues()
    return self:submitAttr(node, values)
end

function M:editCurrentAttr(idx)
    self.cur_attr_idx = idx
    local node = self:getCurrent()
    if not node then
        return
    end
    local enum = nodeType[node:getType()][idx][2]
    local picker = require('editor.TreeMgr').GetPicker(enum, node, idx)
    if picker then
        picker()
    elseif enum == 'resfile' then
        local type = node:getType()
        local wildCard
        if type == 'loadsound' or type == 'loadbgm' then
            wildCard = { "wav", "ogg" }
        elseif type == 'loadimage' or type == 'loadani' or type == 'bossdefine' then
            wildCard = { "png", "jpg", "bmp" }
        elseif type == 'loadparticle' then
            wildCard = "psi"
        elseif type == 'patch' then
            wildCard = "lua"
        elseif type == 'loadFX' then
            wildCard = "fx"
        else
            wildCard = ""
        end
        local curProjDir = require('editor.ProjectMgr').GetCurProjDir()
        local path = require('platform.FileDialog').open(wildCard, curProjDir)
        if not path then
            return
        end
        local fullpath = path
        local name = string.filename(path)
        local panel = require('editor.main').getPropertyPanel()
        if type == 'bossdefine' then
            panel:setValue(5, fullpath)
        elseif type == 'patch' then
            panel:setValue(1, fullpath)
        else
            panel:setValue(1, fullpath)
            panel:setValue(2, name)
            if type == 'loadparticle' then
                local f, msg = io.open(fullpath, 'rb')
                if f == nil then
                    OutputLog(msg, "Error")
                else
                    local s = f:read(1)
                    f:close()
                    panel:setValue(3, 'parimg' .. (string.byte(s, 1) + 1))
                end
            end
        end
        self:submitAttrToCurrent()
    else
        require('editor.dialog.EditText').show(idx, node)
    end
end

---@param next_node editor.TreeNode
function M:onSelChanged(next_node)
    self:submitAttrToCurrent()
    self:setCurrent(next_node)
    local node = next_node
    local panel = require('editor.main').getPropertyPanel()
    if node:isRoot() then
        self:setTypeHint("Node type: project")
        panel:showNode(nil)
    else
        self:setTypeHint("Node type: " .. node:getDisplayType())
        panel:showNode(node)
        if node:getAttrValue(1) == "" and node:getConfig().editfirst then
            self:editCurrentAttr(1)
        end
    end
end

function M:onDelete(node)
    Tree.ClearWatch(node)
end

function M:copyCurrent()
    local cur = self:getCurrent()
    if M.isValid(cur) then
        require('platform.ClipBoard').set("\001LuaSTG" .. cur:serialize())
    end
end

function M:cutCurrent()
    local cur = self:getCurrent()
    if M.isValid(cur) and not cur:isForbidDelete() then
        self:copyCurrent()
        return self:deleteCurrent()
    end
end

function M:pasteToCurrent()
    local cur = self:getCurrent()
    if M.isValid(cur) or cur:isRoot() then
        local cp = require('platform.ClipBoard').get()
        if cp and string.sub(cp, 1, 7) == "\001LuaSTG" then
            --M.InsertNode(projectTree, curNode, Tree.DeSerialize(string.sub(cp, 8, -1)))
            self:insertToCurrent(self:deserialize(string.sub(cp, 8, -1)))
        end
    end
end

function M:setTypeHint(str)
    str = str or 'N/A'
    Print('current node type: ' .. str)
    return
end

function M:deserialize(str)
    local t = require('editor.TreeHelper').DeSerialize(str)
    for i, v in ipairs(t) do
        self:getRoot():insertChild(require('editor.tree_node').deserialize(v)())
    end
end

function M:serialize()
    return self.root:serialize()
end

function M:reset()
    self:getRoot():deleteAllChildren()
    require('editor.main').getPropertyPanel():showNode(nil)
end

function M.isValid(node)
    return node and node.attr
end

function M.isFocused()
    return true
end

return M
