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
    require('editor.node_def.audio')
    require('editor.node_def.background')
    require('editor.node_def.boss')
    require('editor.node_def.boss_effect')
    require('editor.node_def.bullet')
    require('editor.node_def.bullet_cleaner')
    require('editor.node_def.bullet_prefab')
    require('editor.node_def.callbackfunc')
    require('editor.node_def.connect')
    require('editor.node_def.enemy')
    require('editor.node_def.folder')
    require('editor.node_def.language')
    require('editor.node_def.laser')
    require('editor.node_def.laserbent')
    require('editor.node_def.loadres')
    require('editor.node_def.misc')
    require('editor.node_def.object')
    require('editor.node_def.patch')
    require('editor.node_def.rebounder')
    require('editor.node_def.render_object')
    require('editor.node_def.setter')
    require('editor.node_def.setting')
    require('editor.node_def.stage')
    require('editor.node_def.task')

    local helper = require('editor.TreeHelper')
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
            --Tree.watch[v.watch] = {}
            helper.watch[v.watch] = {}
        end
    end
end

return M
