--
local M = {}
local nodeType = {}

function M.DefineNode(type, def)
    nodeType[type] = def
end

function M.UndefineNode(type)
    nodeType[type] = nil
end

function M.getDefine(type)
    return nodeType[type]
end

function M.getNodeType()
    return nodeType
end

function M.regist()
    require('xe.node_def.audio')
    require('xe.node_def.background')
    require('xe.node_def.boss')
    require('xe.node_def.boss_effect')
    require('xe.node_def.bullet')
    require('xe.node_def.bullet_cleaner')
    require('xe.node_def.bullet_prefab')
    require('xe.node_def.callbackfunc')
    require('xe.node_def.connect')
    require('xe.node_def.enemy')
    require('xe.node_def.folder')
    require('xe.node_def.language')
    require('xe.node_def.laser')
    require('xe.node_def.laserbent')
    require('xe.node_def.loadres')
    require('xe.node_def.misc')
    require('xe.node_def.object')
    require('xe.node_def.patch')
    require('xe.node_def.rebounder')
    require('xe.node_def.render_object')
    require('xe.node_def.setter')
    require('xe.node_def.setting')
    require('xe.node_def.stage')
    require('xe.node_def.task')

    local helper = require('xe.TreeHelper')
    for k, v in pairs(nodeType) do
        v.name = k
        if not v.disptype then
            v.disptype = k
        end
        if v.allowchild then
            for _, typename in ipairs(v.allowchild) do
                v.allowchild[typename] = true
            end
        end
        if v.forbidchild then
            for _, typename in ipairs(v.forbidchild) do
                v.forbidchild[typename] = true
            end
        end
        if v.allowparent then
            for _, typename in ipairs(v.allowparent) do
                v.allowparent[typename] = true
            end
        end
        if v.forbidparent then
            for _, typename in ipairs(v.forbidparent) do
                v.forbidparent[typename] = true
            end
        end
        if v.needancestor then
            for _, typename in ipairs(v.needancestor) do
                v.needancestor[typename] = true
            end
        end
        if v.forbidancestor then
            for _, typename in ipairs(v.forbidancestor) do
                v.forbidancestor[typename] = true
            end
        end
        if v.watch then
            helper.watch[v.watch] = {}
        end
    end

    --local types = {}
    --for k, v in pairs(nodeType) do
    --    for i, item in ipairs(v) do
    --        if item[2] then
    --            types[item[2]] = true
    --        end
    --    end
    --end
    --print('---')
    --for k, v in pairs(types) do
    --    print(k)
    --end
    --print('---')
end

return M
