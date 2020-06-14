local base = require('imgui.widgets.TreeNode')
---@class xe.ui.TreeNode:im.TreeNode
local M = class('xe.ui.TreeNode', base)
local im = imgui
local tree = require('cc.ui.TreeNode')
local wi = require('imgui.Widget')
local _flags = bit.bor(im.TreeNodeFlags.OpenOnArrow, im.TreeNodeFlags.OpenOnDoubleClick)

function M:ctor(text)
    base.ctor(self, text or '...')
    self._select = false
    self._onSelect = std.fvoid
    self._onUnselect = std.fvoid
    self._children = std.list()
    ---@type xe.ui.TreeNode
    self._parent = nil
    self._level = 0
    self._index = 1
    if not self:getString() then
        self:setString('-')
    end
end

function M:getIndex()
    return self._index
end
--- for_each iterator
function M:children()
    return self._children:iter()
end
---@return ui.TreeNode
function M:getChildAt(idx)
    return self._children:at(idx)
end
function M:getChildrenCount()
    return self._children:size()
end
--- get count of all descendants
function M:getDescendantsCount()
    return tree.getDescendantsCount(self)
end
function M:getLastDescendant(canBeThis)
    return tree.getLastDescendant(self, canBeThis)
end

function M:setString(str)
    self:setLabel(str)
end

function M:getString()
    return self:getLabel()
end

function M:insertChild(child)
    assert(iskindof(child, M.__cname), tostring(getclassname(child)))
    self:unfold()
    self._children:push_back(child)
    child._index = self._children:size()
    child:_setParentNode(self)
    self:addChild(child)
end

function M:insertChildAt(idx, child)
    assert(iskindof(child, M.__cname), tostring(getclassname(child)))
    self:unfold()
    if idx < 1 or idx > self._children:size() + 1 then
        error('invalid index ' .. idx)
    end
    self._children:insert_at(idx, child)
    child:_setParentNode(self)
    self:_updateChildrenIndex()
    self:addChild(child)
end

function M:insertBefore(child)
    tree.insertBefore(self, child)
end
function M:insertAfter(child)
    tree.insertAfter(self, child)
end
function M:deleteChild(child)
    tree.deleteChild(self, child)
end
function M:deleteChildAt(idx)
    tree.deleteChildAt(self, idx)
end
function M:deleteAllChildren()
    tree.deleteAllChildren(self)
end
function M:delete()
    tree.delete(self)
end

function M:setOnDelete(cb)
    self._onDelete = cb
end

function M:toggle_fold()
    print('TreeNode:toggle_fold()', self)
    if self:isOpen() then
        self:unfold()
    else
        self:fold()
    end
end

function M:fold()
    print('TreeNode:fold()', self:getType())
    self:setOpen(false)
end

function M:unfold()
    print('TreeNode:unfold()', self:getType())
    self:setOpen(true)
end

function M:unfoldToThis()
    print('TreeNode:unfoldToThis()', self)
    tree.unfoldToThis(self)
end

function M:isFold()
    return not self:isOpen()
end

function M:toggle_select()
    print('TreeNode:toggle_select()', self)
    tree.toggle_select(self)
end

function M:select()
    if self._select then
        return
    end
    print('TreeNode:select()', self:getType())
    self._select = true
    if self._onSelect then
        self:_onSelect()
    end
end

function M:unselect()
    if not self._select then
        return
    end
    print('TreeNode:unselect()', self:getType())
    self._select = false
    if self._onUnselect then
        self:_onUnselect()
    end
end

function M:isSelected()
    return self._select
end
function M:setOnSelect(cb)
    self._onSelect = cb
end
function M:setOnUnselect(cb)
    self._onUnselect = cb
end
function M:getParentNode()
    if self:isRoot() then
        return
    end
    return self._parent
end
function M:_setParentNode(node)
    assert(node)
    if node == self._parent then
        return
    end
    assert(not self._parent, ('%s already has parent %s, try to set %s'):format(self, self._parent, node))
    self._parent = node
    self._level = node._level + 1
end
function M:_updateChildrenIndex()
    tree._updateChildrenIndex(self)
end
function M:hasChild(node)
    return tree.hasChild(self, node)
end
function M:_checkChildIndex(idx)
    return tree._checkChildIndex(self, idx)
end
---@return xe.ui.TreeView
function M:getView()
    return tree.getView(self)
end
---@return xe.ui.TreeNode
function M:getRoot()
    return tree.getRoot(self)
end
---@return boolean
function M:isRoot()
    return self._isroot
end
function M:isLeaf()
    return self:getChildrenCount() == 0
end
function M:getTreeNext()
    return tree.getTreeNext(self)
end
function M:getBrotherPrev()
    return tree.getBrotherPrev(self)
end
function M:getBrotherNext()
    return tree.getBrotherNext(self)
end
function M:moveUp()
    tree.moveUp(self)
end
function M:moveDown()
    tree.moveDown(self)
end
function M:_updatePos()
end
function M:updatePosition()
end

function M:_handler()
    if self._needopen ~= nil then
        im.setNextItemOpen(self._needopen)
        self._needopen = nil
    end
    local flags = _flags
    if self:isSelected() then
        flags = bit.bor(flags, im.TreeNodeFlags.Selected)
    end
    local is_leaf = self:isLeaf()
    if is_leaf then
        flags = bit.bor(flags, im.TreeNodeFlags.Leaf, im.TreeNodeFlags.NoTreePushOnOpen)
    end
    local str = self._param[1]
    assert(str)
    if str == '' then
        str = ('[%s] select: %s'):format(self:getType(), self._select)
    end
    local ret = { im.treeNodeEx(tostring(self), flags, str) }
    if im.isItemClicked() then
        self:select()
    end
    self._ret = ret
    if ret[1] then
        wi._handler(self)
        -- pop when return true
        if not is_leaf then
            im.treePop()
        end
    end
end

return M
