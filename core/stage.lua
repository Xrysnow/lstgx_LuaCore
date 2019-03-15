---场景类
stage = { stages = {} }
local e = lstg.eventDispatcher

---请使用stage.group
function stage.init(self)
end
function stage.del(self)
end
function stage.render(self)
end
function stage.frame(self)
end

---创建场景
---stage_name：场景名
---as_entrance：是否为第一个场景（立即进入）
---is_menu：是否为菜单
function stage.New(stage_name, as_entrance, is_menu)
    local result = { init   = stage.init,
                     del    = stage.del,
                     render = stage.render,
                     frame  = stage.frame,
    }
    if as_entrance then
        stage.next_stage = result
    end
    result.is_menu           = is_menu
    result.stage_name        = tostring(stage_name)
    stage.stages[stage_name] = result
    return result
end

---设置场景
---@param mode string @录像模式，可选none/load/save
---@param path string @录像文件路径（可选）
---@param stage string @关卡名称
function stage.Set(mode, path, stageName)
    e:dispatchEvent('onStageSet',{mode, path, stageName})
end

---设置timer为t-1
function stage.SetTimer(t)
    stage.current_stage.timer = t - 1
end

---重新开始场景
function stage.Restart()
    e:dispatchEvent('onStageRestart')
end

---退出游戏
function stage.QuitGame()
    lstg.quit_flag = true
end
