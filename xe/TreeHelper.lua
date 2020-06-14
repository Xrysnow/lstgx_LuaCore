local M = { data = {}, imageIndex = {} }

local watch = {}
M.watch = watch
---@type table<xe.ui.TreeNode,boolean>
watch.image = {}

---@param node xe.SceneNode
function M.ClearWatch(node)
    local watch = node:getConfig().watch
    if watch then
        M.watch[watch][node] = nil
    end
end
--[[
---iter for children of Node in TreeCtrl
function M.Children(TreeCtrl, Node)
    local n = TreeCtrl:GetChildrenCount(Node, false)
    local i = 1
    local CurNode
    local First = true
    --return function()
    --    if i > n then
    --        return nil
    --    end
    --    if First then
    --        CurNode = TreeCtrl:GetFirstChild(Node)
    --        First = false
    --    else
    --        CurNode = TreeCtrl:GetNextSibling(CurNode)
    --    end
    --    i = i + 1
    --    return CurNode
    --end
end

function M.Data2Ctrl(TreeCtrl, Parent, pos, Data)
    local ret = TreeCtrl:InsertItem(Parent, pos, "", M.imageIndex[Data.type])
    M.data[ret:GetValue()] = { ['type'] = Data.type, attr = {} }
    for i = 1, #(nodeType[Data.type]) do
        M.data[ret:GetValue()].attr[i] = Data.attr[i] or nodeType[Data.type][i][4] or enumType[nodeType[Data.type][i][2] ][1] or ''
    end
    TreeCtrl:SetItemText(ret, (nodeType[Data.type].totext)(M.data[ret:GetValue()]))
    if nodeType[Data.type].watch then
        M.watch[nodeType[Data.type].watch][ret:GetValue()] = true
    end
    --if Data.child then
    --    for i = 1, #Data.child do
    --        M.Data2Ctrl(TreeCtrl, ret, -1, Data.child[i])
    --    end
    --end
    --if Data.expand then
    --    TreeCtrl:Expand(ret)
    --end
    --if Data.select then
    --    TreeCtrl:SelectItem(ret)
    --end
    --local color = nodeColor[Data.type]
    --if color then
    --    TreeCtrl:SetItemTextColour(ret, wx.wxColour(color[1], color[2], color[3], color[4]))
    --    if color[5] then
    --        TreeCtrl:SetItemBold(ret)
    --    end
    --end
    return ret
end

---@param node editor.TreeNode
function M.Ctrl2Data(TreeCtrl, node)
    local ret = { ['type'] = node:getType(), attr = {}, expand = not node._fold, child = {} }
    if node._select then
        ret.select = true
    end
    for i = 1, node:getAttrCount() do
        ret.attr[i] = node:getAttrValue(i)
    end
    for CurNode in node:children() do
        table.insert(ret.child, M.Ctrl2Data(TreeCtrl, CurNode))
    end
    return ret
end
]]
function M.Clone(Node)
    if type(Node) ~= 'table' then
        return Node
    else
        local ret = {}
        for k, v in pairs(Node) do
            ret[k] = M.Clone(v)
        end
        return ret
    end
end

function M.Serialize(o, tab)
    tab = tab or 0
    if type(o) == 'number' then
        return tostring(o)
    elseif type(o) == 'string' then
        return string.format('%q', o)
    elseif type(o) == 'boolean' then
        return tostring(o)
    elseif type(o) == 'nil' then
        return 'nil'
    elseif type(o) == 'table' then
        local r = '{\n'
        for k, v in pairs(o) do
            if type(k) == 'number' then
                k = '[' .. k .. ']'
            elseif type(k) == 'string' then
                k = string.format('[%q]', k)
            else
                error('cannot serialize a ' .. type(k) .. ' key')
            end
            r = r .. string.rep('\t', tab + 1) .. k .. '=' .. M.Serialize(v, tab + 1) .. ',\n'
        end
        return r .. string.rep('\t', tab) .. '}'
    else
        error('cannot serialize a ' .. type(o))
    end
end

function M.DeSerialize(s)
    return assert(loadstring('return ' .. s))()
end

return M
