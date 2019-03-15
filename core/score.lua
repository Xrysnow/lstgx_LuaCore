function new_scoredata_table()
    t = {}
    setmetatable(t, { __newindex = scoredata_mt_newindex, __index = scoredata_mt_index, data = {} })
    return t
end
function scoredata_mt_newindex(t, k, v)
    if type(k) ~= 'string' and type(k) ~= 'number' then
        error('Invalid key type \'' .. type(k) .. '\'')
    end
    if type(v) == 'function' or type(v) == 'userdata' or type(v) == 'thread' then
        error('Invalid value type \'' .. type(v) .. '\'')
    end
    if type(v) == 'table' then
        make_scoredata_table(v)
    end
    getmetatable(t).data[k] = v
    -- save instantly
    SaveScoreData()
end
function scoredata_mt_index(t, k)
    return getmetatable(t).data[k]
end
function make_scoredata_table(t)
    if type(t) ~= 'table' then
        error('t must be a table')
    end
    Serialize(t)
    setmetatable(t, { __newindex = scoredata_mt_newindex, __index = scoredata_mt_index, data = {} })
    for k, v in pairs(t) do
        if type(v) == 'table' then
            make_scoredata_table(v)
        end
        getmetatable(t).data[k] = v
        t[k] = nil
    end
end

function DefineDefaultScoreData(t)
    scoredata = t
end

local score_dir = 'score/' .. setting.mod .. '/'
if plus.os ~= 'windows' then
    score_dir = plus.getWritablePath() .. "score/" .. setting.mod .. '/'
end
plus.CreateDirectory(score_dir:sub(1, -2))

--- save scoredata to file
function SaveScoreData()
    local dst = score_dir .. setting.username .. '.dat'
    local fu = cc.FileUtils:getInstance()
    fu:writeStringToFile(Serialize(scoredata), dst)
end

---init score data
---score/mod_name

local fpath = score_dir .. setting.username .. '.dat'
if not plus.FileExists(fpath) then
    if scoredata == nil then
        scoredata = {}
    end
    if type(scoredata) ~= 'table' then
        error('scoredata must be a Lua table.')
    end
else
    -- score/mod_name/user_name.dat
    local fu = cc.FileUtils:getInstance()
    fpath = fu:getSuitableFOpen(fpath)
    --local tmp = assert(io.open(fpath, 'a+'), 'Can not open score file!')
    --tmp:close()
    if not fu:isFileExist(fpath) then
        error(string.format('%s: %s', i18n "Can't find score file", fpath))
    end
    local data = fu:getStringFromFile(fpath);
    if not data or data == '' then
        data = [[{"_":0}]]
    end
    scoredata = DeSerialize(data)
end
make_scoredata_table(scoredata)
