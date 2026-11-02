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

-- Android uses MIME types and asynchronous SAF operations. Imported files are
-- local copies; exporting copies an existing app-owned file to the selected URI.
-- Keep the request ID and cancel it when its owning UI/scene is disposed.
local function request(method, args, signature, callback)
    assert(type(callback) == 'function', 'a completion callback is required')
    if lstg.GetPlatform() ~= 'android' then
        return nil, 'unsupported: use the desktop synchronous file dialog'
    end
    local requestId
    args[#args + 1] = function(payload)
        local ok, result = pcall(require('cjson').decode, payload)
        if not ok or type(result) ~= 'table' then
            result = { requestId = requestId, status = 'error', path = '', uri = '',
                message = 'invalid document result' }
        end
        callback(result)
    end
    local ok, value = require('cocos.cocos2d.luaj').callStaticMethod(
            'org/cocos/game/StorageBridge', method, args, signature)
    if not ok then
        return nil, 'document request failed: ' .. tostring(value)
    end
    requestId = value
    return requestId
end

---@param mime string MIME type, for example application/zip or */*
---@param callback function Receives {requestId,status,path,uri,message} on the engine thread
function M.importAsync(mime, callback)
    return request('importDocument', { mime or '*/*' }, '(Ljava/lang/String;I)I', callback)
end

---@param source string Existing absolute path in an app-specific directory
---@param suggestedName string User-editable name in the create-document picker
---@param mime string
---@param callback function
function M.exportAsync(source, suggestedName, mime, callback)
    assert(type(source) == 'string', 'an app-owned source path is required')
    return request('exportDocument', { source, suggestedName or '', mime or 'application/octet-stream' },
            '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I', callback)
end

function M.cancel(requestId)
    if lstg.GetPlatform() ~= 'android' then
        return false
    end
    local ok, cancelled = require('cocos.cocos2d.luaj').callStaticMethod(
            'org/cocos/game/StorageBridge', 'cancelRequest', { requestId }, '(I)Z')
    return ok and cancelled or false
end

return M
