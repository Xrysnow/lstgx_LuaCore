local base = require('xe.ui.TreeView')
---@class xe.SceneTree:xe.ui.TreeView
local M = class('xe.SceneTree', base)
local Node = require('xe.SceneNode')
local nodeType = require('xe.node_def._def').getNodeType()
local log = require('xe.logger').log
local format = string.format

local function get_prop()
    return require('xe.main').getProperty()
end

function M:ctor(...)
    base.ctor(self, ...)
    require('xe.node_def._def').regist()
    local root = Node('root')
    self:_setRoot(root)
    root:setLabel('Project')
    self._insert_pos = 'child'
end

function M:newNode(type, text, icon, onSel, onUnsel)
    print('newNode', type)
    self:insertDefault(type)
end

function M:setInsertPos(pos)
    assert(pos == 'child' or pos == 'after' or pos == 'before')
    self._insert_pos = pos
end

function M:getInsertPos()
    return self._insert_pos
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

---@param node xe.SceneNode
function M.checkAncestor(node, parent)
    -- NOTE: node may not inserted to parent now
    local ret
    local ty = node:getType()
    local anc = nodeType[ty].needancestor
    local ancStack = table.append(node:getAncestorTypes(), parent:getAncestorTypes())
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
        log(format(
                '%q need ancestor: %s, but got %s',
                ty,
                table.concat(needed, '/'),
                table.concat(ancStack, '/')
        ), "error")
        return false
    end
    anc = nodeType[ty].forbidancestor
    if anc then
        for _, v in ipairs(ancStack) do
            if anc[v] then
                log(format('%q forbid ancestor: %s', ty, v), "error")
                return false
            end
        end
    end
    if node:getChildrenCount() > 0 then
        --table.insert(ancStack, ty)
        for _, child in node:children() do
            ret = ret and M.checkAncestor(child, parent)
        end
        --ancStack[#ancStack] = nil
    end
    return ret
end

---@param parent xe.SceneNode
---@param child xe.SceneNode
function M.insertNode(parent, child, idx)
    if not M.checkAllow(parent, child) then
        log(format('can not insert %q as child of %q',
                   child:getType(), parent:getType()), "Error")
        return false
    end
    if not M.checkAncestor(child, parent) then
        return false
    end
    if idx then
        parent:insertChildAt(idx, child)
    else
        parent:insertChild(child)
    end
    parent:unfold()
    child:select()
    return true
end

---@param node xe.SceneNode
function M:insertCurrent(node_ctor)
    local p = self._insert_pos
    if p == 'child' or self:getCurrent():isRoot() then
        return self:insertToCurrent(node_ctor)
    elseif p == 'after' then
        return self:insertAfterCurrent(node_ctor)
    elseif p == 'before' then
        return self:insertBeforeCurrent(node_ctor)
    else
        error('invalid insert position')
    end
end

local _getCtor

function M:insertDefault(type)
    _getCtor = _getCtor or require('xe.SceneNode').getCtor
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
            if M.insertNode(p, c, idx) then
                self:updateID()
                cid = c:getID()
                pid = p:getID()
                return true
            end
            return false
        end,
        undo = function()
            local c = self:getNodeByID(cid)
            c:delete()
        end
    }
    local ret = op.exe()
    return op, ret
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

---@param node xe.SceneNode
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
                return false
            end
            ctor = node:getClone()
            idx = node:getIndex()
            local p = node:getParentNode()
            node:delete()
            self:updateID()
            pid = p:getIndex()
            return true
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
    local ret = op.exe()
    return op, ret
end

function M:deleteCurrent()
    print('SceneTree:deleteCurrent')
    local cur = self:getCurrent()
    if not cur then
        return
    end
    return self:deleteOp(cur:getID())
end

function M:updateID()
    -- id is dynamic
end

---@return xe.SceneNode
function M:getNodeByID(id)
    local n = self:getRoot()
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

---@param node xe.SceneNode
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
                --print(string.format(
                --        '[%s] changed from %q to %q',
                --        node:getType(), rec_old[i], val[i]))
                changed = true
            end
        end
    end
    if changed then
        node:updateString()
        local id = node:getID()
        local op = {
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
        op.exe()
        return op
    end
end

function M:submitAttrToCurrent()
    print('SceneTree:submitAttrToCurrent')
    local cur = self:getCurrent()
    if M.isValid(cur) then
        local values = get_prop():collectValues()
        return self:submitAttr(self:getCurrent(), values)
    end
end

function M:submitAttrTo(node)
    print('SceneTree:submitAttrTo')
    local values = get_prop():collectValues()
    return self:submitAttr(node, values)
end

function M:editCurrentAttr(idx)
    print('SceneTree:editCurrentAttr', idx)
    self.cur_attr_idx = idx
    local node = self:getCurrent()
    if not node then
        return
    end
    local enum = nodeType[node:getType()][idx][2]
    local picker = M.getPicker(enum, node, idx)
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
        local curProjDir = require('xe.Project').getDir()
        local path = require('platform.FileDialog').open(wildCard, curProjDir)
        if not path or path == '' then
            log('File path not set.', 'error', node:getType())
            -- just leave node unset here
            return
        end
        --TODO: copy file if not in project dir
        local fullpath = path
        local name = string.filename(path)
        local panel = get_prop()
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
                    log(msg, "Error")
                else
                    local s = f:read(1)
                    f:close()
                    panel:setValue(3, 'parimg' .. (string.byte(s, 1) + 1))
                end
            end
        end
        self:submitAttrToCurrent()
    else
        require('xe.input.EditText').show(idx, node)
        --self:addChild(require('xe.input.EditText')('Edit Text', node, idx))
    end
end

---@param next_node xe.SceneNode
function M:onSelChanged(next_node)
    print('SceneTree:onSelChanged')
    --self:submitAttrToCurrent()
    M.submit()
    self:setCurrent(next_node)
    local panel = get_prop()
    if next_node == nil then
        panel:showNode(nil)
        return
    end
    local node = next_node
    if node:isRoot() then
        self:setTypeHint("Node type: Project")
        --TODO: show some info
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
    print('SceneTree:onDelete')
    require('xe.TreeHelper').ClearWatch(node)
end

function M:copyCurrent()
    print('SceneTree:copyCurrent')
    local cur = self:getCurrent()
    if M.isValid(cur) then
        require('platform.ClipBoard').set("\001LuaSTG" .. cur:serialize())
    end
end

function M:cutCurrent()
    print('SceneTree:cutCurrent')
    local cur = self:getCurrent()
    if M.isValid(cur) and not cur:isForbidDelete() then
        self:copyCurrent()
        return self:deleteCurrent()
    end
end

function M:pasteToCurrent()
    print('SceneTree:pasteToCurrent')
    local cur = self:getCurrent()
    if M.isValid(cur) or cur:isRoot() then
        local cp = require('platform.ClipBoard').get()
        if cp and string.sub(cp, 1, 7) == "\001LuaSTG" then
            --M.InsertNode(projectTree, curNode, Tree.DeSerialize(string.sub(cp, 8, -1)))
            return self:insertToCurrent(self:deserialize(string.sub(cp, 8, -1)))
        end
    end
end

function M:setTypeHint(str)
    --TODO: should be shown in property
    str = str or 'N/A'
    --print('current node type: ' .. str)
    return
end

function M:deserialize(str)
    --TODO: give better error message here
    local t = require('xe.TreeHelper').DeSerialize(str)
    for i, v in ipairs(t) do
        self:getRoot():insertChild(require('xe.SceneTree').deserialize(v)())
    end
end

function M:serialize()
    return self:getRoot():serialize()
end

function M:reset()
    print('SceneTree:reset')
    self:getRoot():deleteAllChildren()
    get_prop():showNode(nil)
end

function M.isValid(node)
    return node and node.attr
end

function M.isFocused()
    return true
end

--- submit current with history
function M.submit(self)
    local changed = false
    if not self or self == M then
        self = require('xe.main').getEditor():getTree()
    end
    local op = self:submitAttrToCurrent()
    if op then
        changed = true
        require('xe.history').add(op)
    end
    return changed
end

function M.getPicker(type, node, idx)
end

return M
