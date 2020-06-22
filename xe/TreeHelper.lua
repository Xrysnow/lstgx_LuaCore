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
