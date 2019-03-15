---@class editor.PropertyPanel:ccui.ScrollView
local M = class('editor.PropertyPanel', ccui.ScrollView)

--local _instance
--local _create = M.create
--M.create = nil
--
-----@return editor.PropertyPanel
--function M:getInstance()
--    if not _instance then
--        _instance = _create(M)
--    end
--    return _instance
--end

function M:ctor()
    --local inner=self:getInnerContainer()
    self:setLayoutType(ccui.LayoutType.VERTICAL)
    --self:setContentSize(cc.size(320, 720))
end

function M:collectValues()
    local ret = {}
    for i, c in ipairs(self:getChildren()) do
        if c.getValue then
            table.insert(ret, c:getValue())
        end
    end
    return ret
end

function M:getValue(idx)
    local c = self:getChildren()[idx]
    assert(c and c.getValue)
    return c:getValue()
end

function M:setValue(idx, v)
    local c = self:getChildren()[idx]
    assert(c and c.setValue)
    return c:setValue(v)
end

---@return editor.PropertySetter
function M:getSetter(idx)
    return self:getChildren()[idx]
end

---@param node editor.TreeNode
function M:showNode(node)
    self:removeAllChildren()
    self._node = node
    local ww = self:getContentSize().width
    if node and node:getAttrCount() > 0 then
        for i = 1, node:getAttrCount() do
            local name = node:getAttrName(i)
            local type = node:getAttrType(i)
            local value = node:getAttrValue(i)
            local pi = require('editor.PropertySetter')(name, { type or 'code' }, {
                size = cc.size(ww, 30 + 16),
            })
            pi:setValue(value)
            pi:setOnAdvancedEdit(function()
                --require('editor.TreeMgr').EditAttr(i)
                require('editor.main').getMainTree():editCurrentAttr(i)
            end)
            self:add(pi)
        end
    end
    self:updateLayout()
end

function M:insert(node, idx)
    local count = self:getChildrenCount()
    assert(1 <= idx and idx <= count + 1)
    local tmp = {}
    for i, c in ipairs(self:getChildren()) do
        if i == idx then
            table.insert(tmp, node)
        end
        c:retain()
        table.insert(tmp, c)
    end
    if idx == count + 1 then
        table.insert(tmp, node)
    end
    self:removeAllChildren()
    node:retain()
    for i, c in ipairs(tmp) do
        self:addChild(c)
        c:release()
    end
    self:requestDoLayout()
end

function M:erase(idx)
    local count = self:getChildrenCount()
    assert(1 <= idx and idx <= count)
    local tmp = {}
    for i, c in ipairs(self:getChildren()) do
        c:retain()
        table.insert(tmp, c)
    end
    self:removeAllChildren()
    for i, c in ipairs(tmp) do
        if i ~= idx then
            self:addChild(c)
        end
        c:release()
    end
    self:requestDoLayout()
end

function M:updateLayout()
    self:requestDoLayout()
end

function M:setContentSize(size)
    self.super.setContentSize(self, size)
    self:updateLayout()
    return self
end

return M
