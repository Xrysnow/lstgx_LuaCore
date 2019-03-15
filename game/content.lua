local M = {}

local _rank_names = {}
local _ranks = {}

function M.enumRanks()
    if #_ranks == 0 then
        for _, sg in ipairs(stage.groups) do
            if sg ~= 'Spell Practice' then
                _rank_names[stage.groups[sg].difficulty] = sg
                table.insert(_ranks, stage.groups[sg].difficulty)
            end
        end
        table.sort(_ranks)
    end

    return _ranks, _rank_names
end

function M.setRank(rank)
    M.enumRanks()
    scoredata.difficulty_select = rank
    lstg.group_name = _rank_names[rank]
    if not lstg.group_name then
        local msg = string.format(
                "can't find rank [%s], possible value: [%s]",
                tostring(rank), tostring(_ranks[1]))
        error(msg)
    end
end

--

function M.enumPlayers()
    return player_list
end

function M.setPlayer(index)
    scoredata.player_select = index--TODO: may have problem
    lstg.var.player_name = player_list[index][2]
    lstg.var.rep_player = player_list[index][3]
    assert(lstg.var.player_name and lstg.var.rep_player)
end

--

local _stage_groups = {}
local _stages = {}
--
local _stage_names = {}
local _stage_origin_names = {}

function M.enumStages(rank)
    if table.nums(_stages) == 0 then
        for _, sg in ipairs(stage.groups) do
            if sg ~= 'Spell Practice' and stage.groups[sg].allow_practice then
                _stage_groups[stage.groups[sg].difficulty] = sg
                _stages[sg] = {}
                for _, s in ipairs(stage.groups[sg]) do
                    if stage.stages[s].allow_practice then
                        table.insert(_stages[sg],
                                string.match(s, "^[%w_][%w_ ]*"))
                    end
                end
            end
        end
    end

    local dif = rank or scoredata.difficulty_select or 1
    _stage_names = _stages[_stage_groups[dif]]
    _stage_origin_names = stage.groups[_stage_groups[dif]]
    return _stage_names, _stage_origin_names
end

function M.getStageGroups()
    return _stage_groups
end

function M.setStage(index)
    lstg.practice = 'stage'
    local dif = scoredata.difficulty_select or 1
    lstg.stage_name = stage.groups[_stage_groups[dif]][index]
    assert(lstg.stage_name)
end

--

local _spells = {}
local _spells_classified = {}
local _spell_ranks = {}
local _spell_rank_names = {}

function M.enumSpells()
    if #_spells == 0 then
        local need_fix = false
        for k, v in pairs(_ranks) do
            _spell_ranks[k] = v
        end
        for k, v in pairs(_rank_names) do
            _spell_rank_names[k] = v
        end
        --_spell_ranks      = table.clone(_ranks)
        --_spell_rank_names = table.clone(_rank_names)
        local _wrong_rank_name
        for idx, sp in ipairs(_sc_table) do
            local rank_name = _editor_class[sp[1]].difficulty
            if not _spells_classified[rank_name] then
                _spells_classified[rank_name] = {}
            end
            table.insert(_spells_classified[rank_name], { index = idx, name = sp[2] })
            if not table.has(_spell_rank_names, rank_name) then
                need_fix = true
                if rank_name ~= _wrong_rank_name then
                    SystemLog('[enumSpells] got wrong difficulty: ' .. rank_name)
                    _wrong_rank_name = rank_name
                end
            end
        end
        if need_fix then
            _spell_ranks = {}
            _spell_rank_names = {}
            for k, _ in pairs(_spells_classified) do
                table.insert(_spell_rank_names, k)
            end
            for i = 1, #_spell_rank_names do
                _spell_ranks[i] = i
            end
        end
        for k, s in pairs(_spells_classified) do
            for _, v in pairs(s) do
                --table.insert(_spells, {
                --    index     = v.index,
                --    name      = v.name,
                --    rank_name = k,
                --    rank      = table.keyof(_spell_ranks, k),
                --})
                _spells[v.index] = {
                    index     = v.index,
                    name      = v.name,
                    rank_name = k,
                    rank      = table.keyof(_spell_ranks, k),
                }
            end
        end
    end

    return _spells, _spells_classified, _spell_ranks, _spell_rank_names
end

function M.getSpellRank(index)
    M.enumSpells()
    for i, k in pairs(_spell_rank_names) do
        for _, s in ipairs(_spells_classified[k]) do
            if s.index == index then
                return _spell_ranks[i]
            end
        end
    end
end

function M.setSpell(index)
    lstg.practice = 'spell'
    scoredata.difficulty_select = M.getSpellRank(index) or scoredata.difficulty_select
    lstg.var.sc_index = index
    local p = scoredata.player_select or 1
    lstg.var.player_name = player_list[p][2]
    lstg.var.rep_player = player_list[p][3]
    assert(scoredata.difficulty_select and lstg.var.player_name)
end

--

local _replays

function M.enumReplays()
    --if not _replays then
    _replays = M._getReplaySlots()
    --end
    return _replays
end

function M._getSlotStages(slot)
    local ret = {}
    for i, v in pairs(slot.stages) do
        --local score = string.format('%09d', v.score)
        local name = string.match(v.stageName, '^.+@(.+)$')
        table.insert(ret, { name, v.score })
    end
end

function M._getReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()
    for i = 1, ext.replay.GetSlotCount() do
        --local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- use time of the first stage
            local datetime = slot.stages[1].stageDate + setting.timezone * 3600
            local date_str = os.date("!%y/%m/%d", datetime)

            local totalScore = 0
            local diff, stage_num = 0, 0
            local is_cleared, is_spell--TODO: is_stage?
            local tmp
            for i, k in ipairs(slot.stages) do
                totalScore = totalScore + slot.stages[i].score
                diff = string.match(k.stageName, '^.+@(.+)$')
                tmp = string.match(k.stageName, '^(.+)@.+$')
                if string.match(tmp, '%d+') == nil then
                    stage_num = tmp
                else
                    stage_num = 'St' .. string.match(tmp, '%d+')
                end
            end
            if diff == 'Spell Practice' then
                diff = 'SpellPr'
                is_spell = true
            end
            if tmp == 'Spell Practice' then
                local var = DeSerialize(slot.stages[1].stageExtendInfo)
                stage_num = var.sc_index
                is_spell = true
            end
            if slot.group_finish == 1 then
                stage_num = 'All'
                is_cleared = true
            end
            local ply = slot.stages[1].stagePlayer
            local usr = slot.userName
            local time_str = os.date("!%H:%M", slot.stages[1].stageDate + setting.timezone * 3600)
            -- spaces
            stage_num = tostring(stage_num)
            for i = 1, 3 - #stage_num do
                stage_num = ' ' .. stage_num
            end
            for i = 1, 7 - #diff do
                diff = diff .. ' '
            end
            for i = 1, 8 - #ply do
                ply = ply .. ' '
            end
            for i = 1, 8 - #usr do
                usr = usr .. ' '
            end

            table.insert(ret, {
                index       = i,
                user        = slot.userName,
                user_str    = usr,
                datetime    = datetime,
                date_str    = date_str,
                time_str    = time_str,
                player      = slot.stages[1].stagePlayer,
                player_str  = ply,
                rank_str    = diff,
                stage_str   = stage_num,
                total_score = totalScore,

                is_cleared  = is_cleared,
                is_spell    = is_spell,
                stages      = M._getSlotStages(slot),
                slot        = slot,
            })
            --text = { string.format('No.%02d', i), usr, date_str, time_str, ply, diff, stage_num }
            --text = { string.format('No.%02d', i), '--------', '--/--/--', '--:--', '--------', '-------', '---' }
        end
    end
    return ret
end

function M.setReplay(replay, i_stage)
    lstg.practice = 'replay'
    local rep_path = replay.slot.path
    local rep_stage
    if replay.rank_str == 'SpellPr' then
        rep_stage = replay.slot.stages[1].stageName
    else
        rep_stage = replay.slot.stages[i_stage].stageName
    end
    local u = require('game.util')
    u._rep_path = rep_path
    u._rep_stage = rep_stage
    lstg.tmpvar.rep_path = rep_path
    lstg.tmpvar.rep_stage = rep_stage
    assert(rep_path and rep_stage)
end

return M
