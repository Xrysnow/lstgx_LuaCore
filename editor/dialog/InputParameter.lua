---@class editor.dialog.InputParameter:ui.DialogBase
local M = class('editor.dialog.InputParameter', require('ui.DialogBase'))

function M:ctor()
    self.super.ctor(self, 'Input Parameter', cc.size(650, 350))
    local wi = self:getWidget()
    wi:setBackGroundColor(cc.c3b(243, 243, 243))
    ---@type cc.Label[]
    self._labels = {}
    ---@type ui.EditBoxString[]
    self._inputs = {}

    for _, xx in ipairs({ 0, 320 }) do
        for i = 1, 8 do
            local yy = 36 + (i - 1) * 32
            local lb = require('ui.label').create('N/A')
            lb:addTo(wi):alignLeft(xx + 20):alignTop(yy)
            table.insert(self._labels, lb)
            local eb = require('ui.prefab.EditBox').String(cc.size(192, 22))
            eb:addTo(wi):alignLeft(xx + 120):alignTop(yy)
            table.insert(self._inputs, eb)
            require('ui.helper').addFrame(eb, cc.c3b(122, 122, 122))
        end
    end
    self._num = 0

    self:addConfirmButton():alignRight(92):alignBottom(8)
    self:addCancelButton():alignRight(10):alignBottom(8)
end

function M:reset()
    for _, v in ipairs(self._labels) do
        v:setString('N/A')
    end
    for _, v in ipairs(self._inputs) do
        v:setString(0, '')
    end
    self._num = 0
end

function M:setValues(names, values)
    self:reset()
    for i = 1, #names do
        self._labels[i]:setString(names[i])
        self._inputs[i]:setString(0, values[i])
    end
    self._num = #names
end

function M:getValues()
    local ret = {}
    for i = 1, self._num do
        table.insert(ret, self._inputs[i]:getString())
    end
    return ret
end

local _def_node_type = {
    enemydefine = true, bulletdefine = true, objectdefine = true, laserdefine = true, laserbentdefine = true, rebounderdefine = true
}
local _init_node_type = {
    enemyinit = true, bulletinit = true, objectinit = true, laserinit = true, laserbentinit = true, rebounderinit = true
}

---@param node editor.TreeNode
local function FindDifficulty(node)
    while node do
        if node:isRoot() then
            break
        end
        local type = node:getType()
        if _def_node_type[type] then
            return string.match(node:getAttrValue(1), '^.+:(.+)$')
        elseif type == 'stagegroup' then
            return node:getAttrValue(1)
        end
        node = node:getParentNode()
    end
end

---@param node editor.TreeNode
local function FindNodeByTypeName(node, tname)
    if _def_node_type[node:getType()] then
        if node:getAttrValue(1) == tname then
            return node
        else
            return
        end
    else
        local ret
        for i = 1, node:getChildrenCount() do
            ret = FindNodeByTypeName(node:getChildAt(i), tname)
            if ret then
                return ret
            end
        end
    end
end

local function SplitParam(s)
    if string.match(s, "^[%s]*$") then
        return {}
    end
    local pos = { 0 }
    local ret = {}
    local b1 = 0
    local b2 = 0
    for i = 1, #s do
        local c = string.byte(s, i)
        if b1 == 0 and b2 == 0 and c == 44 then
            table.insert(pos, i)
        elseif c == 40 then
            b1 = b1 + 1
        elseif c == 41 then
            b1 = b1 - 1
        elseif c == 123 then
            b2 = b2 + 1
        elseif c == 125 then
            b2 = b2 - 1
        end
    end
    table.insert(pos, #s + 1)
    for i = 1, #pos - 1 do
        table.insert(ret, string.sub(s, pos[i] + 1, pos[i + 1] - 1))
    end
    return ret
end

---@param node editor.TreeNode
function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    --local Tree = require('editor.TreeHelper')
    local root = require('editor.ProjectMgr').GetRootNode()
    --local curNode = node
    local di = M()
    --local type = node:getType()
    di:reset()

    local tname = node:getAttrValue(1)
    local tnamefull
    local plist = node:getAttrValue(prop_idx)
    local diff = FindDifficulty(node)
    ---@type editor.TreeNode
    local ret
    --[[
    if diff then
        tnamefull = tname .. ":" .. diff
        for k, v in pairs(treeShot[treeShotPos]) do
            ret = FindNodeByTypeName(v, tnamefull)
            if ret then
                break
            end
        end
    end
    if not ret then
        for k, v in pairs(treeShot[treeShotPos]) do
            ret = FindNodeByTypeName(v, tname)
            if ret then
                break
            end
        end
    end
    ]]
    if diff then
        tnamefull = tname .. ":" .. diff
        for i = 1, root:getChildrenCount() do
            ret = FindNodeByTypeName(root:getChildAt(i), tnamefull)
            if ret then
                break
            end
        end
    end
    if not ret then
        for i = 1, root:getChildrenCount() do
            ret = FindNodeByTypeName(root:getChildAt(i), tname)
            if ret then
                break
            end
        end
    end
    if ret then
        local names, values = {}, {}
        for _, v in ret:children() do
            if _init_node_type[v:getType()] then
                local ret2 = SplitParam(v:getAttrValue(1))
                local ret3 = SplitParam(plist)
                for i = 1, #ret2 do
                    table.insert(names, ret2[i])
                    table.insert(values, ret3[i] or "")
                    --paramNameLabel[i]:SetLabel(ret2[i])
                    --paramText[i]:SetValue(ret3[i] or "")
                    --paramText[i]:SetEditable(true)
                end
                --for i = #ret2 + 1, 16 do
                --    paramNameLabel[i]:SetLabel("")
                --    paramText[i]:SetValue("")
                --    paramText[i]:SetEditable(false)
                --end
            end
        end
        di:setValues(names, values)
    else
        di:setValues({ "Parameters" }, { plist })
        --paramNameLabel[1]:SetLabel("Parameters")
        --paramText[1]:SetValue(plist)
        --paramText[1]:SetEditable(true)
        --for i = 2, 16 do
        --    paramNameLabel[i]:SetLabel("")
        --    paramText[i]:SetValue("")
        --    paramText[i]:SetEditable(false)
        --end
        OutputLog(string.format("Type %q not found", tname), 'warning')
    end

    di._box:selectString(panel:getValue(prop_idx))
    di:setOnConfirm(function()
        local val = di:getValues()
        for i = 1, #val do
            if val[i] == '' then
                val[i] = 'nil'
            end
        end
        panel:setValue(prop_idx, table.concat(val, ','))
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
