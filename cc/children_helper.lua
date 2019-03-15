local M = {}

function M.getChildrenGraph(node)
    local name = ''
    if node.getName then
        name = node:getName()
    end
    local ret = {}
    if name == '' then
        name = tostring(node['.classname']) .. ' | ' .. tostring(node)
    end
    if node.getChildren then
        ret = { name = name, node = node, children = {} }
        for _, v in ipairs(node:getChildren()) do
            table.insert(ret.children, M.getChildrenGraph(v))
        end
    end
    return ret
end

function M.getChildrenWithName(node, t)
    t          = t or {}
    local name = ''
    if node.getName then
        name = node:getName()
        --return
    end
    --name = node:getName()
    if name == '' then
        name = tostring(node['.classname']) .. ' | ' .. tostring(node)
    end
    if node.getChildren then
        t[name] = node
        for _, v in ipairs(node:getChildren()) do
            M.getChildrenWithName(v, t)
        end
    end
    return t
end

return M
