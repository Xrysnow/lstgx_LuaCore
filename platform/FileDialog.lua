--
local M = {}

---@return string,string
local function checkReturn(ret)
    if ret ~= '' then
        return ret:gsub('\\', '/')
    end
    local err = lstg.FileDialog:getLastError()
    if err == 'cancel' then
        --return
    else
        print(string.format('got error in FileDialog: %s', err))
        --return
    end
    return nil, err
end

local function makeFilter(filter)
    if not filter then
        return ''
    end
    local str = ''
    if type(filter) == 'string' then
        str = filter
    else
        for _, f in ipairs(filter) do
            if type(f) == 'string' then
                str = str .. f .. ';'
            else
                str = str .. table.concat(f, ',') .. ';'
            end
        end
        str = str:sub(1, -2)
    end
    return str
end

local function splitFilter(filter)
    filter = makeFilter(filter)
    local ret = {}
    for _, v in ipairs(string.split(filter, ';') or {}) do
        for _, u in ipairs(string.split(v, ',') or {}) do
            table.insert(ret, u)
        end
    end
    return ret
end

--- File dialog for 'open'
--- If successed, return path. If cancelled, return nil and 'cancel'. If failed, return nil and message.
---@param filter string|table
---@param defaultPath string
function M.open(filter, defaultPath)
    --TODO: move to cpp
    if defaultPath and jit.os == 'Windows' then
        defaultPath = defaultPath:gsub('/', '\\')
    end
    return checkReturn(lstg.FileDialog:open(makeFilter(filter), defaultPath or ''))
end

---
---@param filter string|table
---@param defaultPath string
function M.openMultiple(filter, defaultPath)
    local ret = lstg.FileDialog:openMultiple(makeFilter(filter), defaultPath or '')
    if #ret > 0 then
        return ret
    end
    local err = lstg.FileDialog:getLastError()
    if err == 'cancel' then
        --return
    else
        Print(string.format('got error in FileDialog: %s', err))
    end
    return nil, err
end

---
---@param filter string|table
---@param defaultPath string
function M.save(filter, defaultPath)
    local path, msg = checkReturn(lstg.FileDialog:save(makeFilter(filter), defaultPath or ''))
    if path and string.fileext(path) == '' then
        local ext = splitFilter(filter)[1]
        if ext and ext ~= '' then
            path = path .. '.' .. ext
        end
    end
    return path, msg
end

---
---@param defaultPath string
function M.pickFolder(defaultPath)
    return checkReturn(lstg.FileDialog:pickFolder(defaultPath or ''))
end

return M
