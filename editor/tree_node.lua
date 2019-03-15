---@class editor.TreeNode:ui.TreeNode
local M
M = class('editor.TreeNode', function(type, icon, text)
    --Print(tostring(type))
    --Print(tostring(icon))
    local ret = require('ui.TreeNode'):create(icon, text)
    M.ctor(ret, type)
    for k, v in pairs(M) do
        ret[k] = v
    end
    return ret
end)
local helper = require('editor.TreeHelper')
local nodeType = require('editor.node_def._def').getNodeType()
local enumType = require('editor.enum_type')
local function _get_icon(type)
    return string.format('editor/images/16x16/%s.png', type)
end

function M:ctor(type)
    self.type = type
    self.attr = {}
    self.property = {}
    self._onSelect = function()
        self:getView().tree:onSelChanged(self)
    end
    self:setOnDelete(function()
        self:getView().tree:onDelete(self)
    end)
    --TODO: keyboard event
end

local _ignore = { type = true, attr = true, child = true }
local function _collect_property(t)
    local ret = {}
    for k, v in pairs(t) do
        if not _ignore[k] then
            ret[k] = v
        end
    end
    return ret
end

--local function _get_default_value(type, idx)
--    local def = nodeType[type]
--    if def and def.default then
--        return def.default[idx]
--    end
--end

local function _construct_plain(type, default)
    local nt = nodeType[type]
    if not nt then
        OutputLog('invalid node type: ' .. tostring(type), 'Error')
        return-- error('...')
    end
    local def = default or nt.default
    ---@type editor.TreeNode
    local ret = M:create(
            type,
            _get_icon(type))
    local attr = ret.attr

    for i = 1, #nt do
        attr[i] = { title = nt[i][1], type = nt[i][2] }
    end

    if def and def.attr then
        for i = 1, ret:getAttrCount() do
            ret:setAttrValue(i, def.attr[i])
        end
    end

    for i = 1, #nt do
        if ret:getAttrValue(i) == nil then
            local dft
            if enumType[nt[i][2]] then
                dft = enumType[nt[i][2]][1]
            end
            ret:setAttrValue(i, nt[i][4] or dft or '')
        end
    end

    if nt.watch then
        require('editor.TreeHelper').watch[nt.watch][ret] = true
    end
    if def then
        ret.property = _collect_property(def)
    end
    return ret
end

local function _construct_default(type, default)
    local def = default or nodeType[type].default
    ---@type editor.TreeNode
    local ret = _construct_plain(type, def)
    if not ret then
        return-- error('...')
    end
    if def and def.child then
        for _, c in ipairs(def.child) do
            local ch = _construct_default(c.type, c)
            if ch then
                ret:insertChild(ch)
            end
        end
    end
    ret:updateString()
    return ret
end

function M.getCtor(type, attr, property)
    local attr_ = table.clone(attr or {})
    local property_ = table.clone(property or {})
    return function()
        local ret = _construct_default(type)
        if not ret then
            return
        end
        for i, v in ipairs(attr_) do
            --ret.attr[i] = v
            ret:setAttrValue(i, v)
        end
        for k, v in pairs(property_) do
            --ret.property[k] = v
            ret:setProperty(nil, k, v)
        end
        ret:updateString()
        return ret
    end
end

function M:getType()
    return self.type
end

function M:getProperty(k)
    return self.property[k]
end

function M:setProperty(type, k, v)
    self.property[k] = v
    if type then
        self.property_type[k] = type
    end
end

function M:setAttrType(idx, type)
    self.attr[idx].cur_type = type
end

function M:getAttrType(idx)
    return self.attr[idx].cur_type
end

function M:getAttrValue(idx)
    if not self.attr[idx] then
        return
    end
    return self.attr[idx].value
end

function M:setAttrValue(idx, v)
    if not self.attr[idx] then
        self.attr[idx] = {}
    end
    self.attr[idx].value = v
    --Print(string.format('[%s] set attr %d to %q', self.type, idx, v))
    self:updateString()
end

function M:isAttrValueEqual(idx, v)
    return self.attr[idx].value == v
end

function M:getAttrCount()
    return #self.attr
end

function M:checkAttr(idx)
    assert(1 <= idx and idx <= self:getAttrCount())
    local f = self:getConfig()[idx][3]
    local msg
    if f then
        msg = f(self.attr[idx].value)
    end
    if msg then
        return false, msg
    else
        return true
    end
end

function M:getAttrName(idx)
    return tostring(self:getConfig()[idx][1])
end

function M:collectAttrValues()
    local ret = {}
    for i = 1, self:getAttrCount() do
        table.insert(ret, self:getAttrValue(i))
    end
    return ret
end

function M:getID()
    if self:isRoot() then
        return 'root'
    end
    local p = self:getParentNode()
    if not p then
        error('require parent node')
    else
        local pid
        if p.getID then
            pid = p:getID()
        else
            pid = 'root'
        end
        return string.format('%s %d', pid, self:getIndex())
    end
end

local function _clone(node)
    local type = node.type
    local attr = table.clone(node.attr)
    local property = table.clone(node.property)
    return function()
        local ret = M:create(
                type,
                _get_icon(type))
        ret.attr = attr
        ret.property = property
        --ret:updateString()
        return ret
    end
end

---@return fun():editor.TreeNode
function M:getClone()
    local cl = _clone(self)
    local ccl = {}
    for i = 1, self:getChildrenCount() do
        table.insert(ccl, self:getChildAt(i):getClone())
    end
    return function()
        local ret = cl()
        for _, v in ipairs(ccl) do
            ret:insertChild(v())
        end
        ret:updateString()
        return ret
    end
end

---@param node editor.TreeNode
local function _dump(node)
    local t = table.clone(node.property)
    t.attr = {}
    for i = 1, node:getAttrCount() do
        table.insert(t.attr, node:getAttrValue(i))
    end
    t.child = {}
    for i = 1, node:getChildrenCount() do
        table.insert(t.child, _dump(node:getChildAt(i)))
    end
    t.type = node:getType()
    t.expand = node:isFold()
    if t.type == 'project' then
        return t.child
    else
        return t
    end
end

function M:dump()
    return _dump(self)
end

function M:dumpForNodeDef()
    local ret = { attr = {} }
    setmetatable(ret.attr, {
        __index    = function(t, k)
            return self:getAttrValue(k) or ''
        end,
        __newindex = function(t, k, v)
            self:setAttrValue(k, v)
        end
    })
    setmetatable(ret, {
        __index    = function(t, k)
            return self:getProperty(k)
        end,
        __newindex = function(t, k, v)
            self:setProperty(nil, k, v)
        end
    })
    return ret
end

function M:serialize()
    return helper.Serialize(self:dump())
end

local function _des(t)
    --assert(t, 'got nil')
    local ret = _construct_plain(assert(t.type))
    if not ret then
        return
    end
    --Print(string.format('-- des type %q [%q]', t.type, t.attr and t.attr[1]))
    for i = 1, ret:getAttrCount() do
        ret:setAttrValue(i, t.attr[i])
    end
    ret.property = _collect_property(t)
    if t.child then
        --if #t.child > 0 then
        --    Print(string.format('-- des %d in %q', #t.child, t.type))
        --end
        for _, v in ipairs(t.child) do
            local ch = _des(v)
            if ch then
                ret:insertChild(ch)
            end
        end
    end
    ret:updateString()
    return ret
end

function M.deserialize(s)
    if type(s) == 'string' then
        s = helper.DeSerialize(s)
    end
    return function()
        return _des(s)
    end
end

function M:updateString()
    self:setString(self:toText())
end

---@return string
function M:toText()
    local f = self:getConfig().totext
    if f then
        local ret = f(self:dumpForNodeDef())
        return ret
    end
end

---@return string
function M:toHead()
    local f = self:getConfig().tohead
    if f then
        return f(self:dumpForNodeDef())
    end
end

---@return string
function M:toFoot()
    local f = self:getConfig().tofoot
    if f then
        return f(self:dumpForNodeDef())
    end
end

function M:getDisplayType()
    local t = self:getConfig().disptype
    if not t then
        t = tostring(self:getType())
    end
    return t
end

function M:isForbidDelete()
    if self:isRoot() then
        return true
    end
    return self:getConfig().forbiddelete
end

function M:isEditFirst()
    return self:getConfig().editfirst
end

function M:checkBeforeCompile()
    local f = self:getConfig().check
    local msg = f and f(self:dumpForNodeDef())
    if msg then
        return false, msg
    else
        return true
    end
end

---@return boolean,string
function M:checkAfterCompile()
    local f = self:getConfig().checkafter
    local msg = f and f(self:dumpForNodeDef())
    if msg then
        return false, msg
    else
        return true
    end
end

function M:getCodeIndent()
    if self:isRoot() then
        return 0
    end
    local v = self:getConfig().depth
    return v or 1
end

function M:getAncestors()
    if self:isRoot() then
        return {}
    end
    local p = self:getParentNode()
    local ret = {}
    while p do
        table.insert(ret, p)
        p = p:getParentNode()
    end
    return ret
end

function M:getAncestorTypes()
    if self:isRoot() then
        return {}
    end
    local p = self:getParentNode()
    local ret = {}
    while p do
        table.insert(ret, p:getType())
        p = p:getParentNode()
    end
    return ret
end

function M:getConfig()
    if self:isRoot() then
        return {}
    end
    return assert(nodeType[self:getType()], 'invalid type: ' .. tostring(self:getType()))
end

return M
