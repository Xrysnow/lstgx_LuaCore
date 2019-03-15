local FU = cc.FileUtils:getInstance()

---判断文件夹是否存在
---@param path @路径
---@return boolean
function plus.FileExists(path)
    path = string.gsub(path, '\\', '/')
    path = string.gsub(path, '//', '/')
    local ret = FU:isFileExist(path)
    if not ret then
        --SystemLog('FileExist: no ' .. path)
    end
    return ret
    --local p = FU:fullPathForFilename(path)
    --if p and p ~= '' then
    --    return true
    --else
    --    SystemLog('FileExist: no ' .. path)
    --    return false
    --end
end

---判断文件夹是否存在
---@param path @路径
---@return boolean
function plus.DirectoryExists(path)
    return FU:isDirectoryExist(path)
end

---创建目录
---@param path @路径
function plus.CreateDirectory(path)
    SystemLog(string.format(i18n 'try to create directory %q', path))
    if FU:isDirectoryExist(path) then
        return
    end
    if not FU:createDirectory(path) or not FU:isDirectoryExist(path) then
        error(i18n "create directory failed")
    end
end

---枚举目录中的文件或文件夹，仅本地文件
---@param path @目录
---@return table
---结果表述为：
--- { { isDirectory = false, name = "abc.txt", lastAccessTime = 0, size = 0 },
---   { isDirectory = true, name = "test" } }
function plus.EnumFiles(path)
    path = string.gsub(path, '\\', '/')
    if path:sub(-1) ~= '/' then
        path = path .. '/'
    end
    if not plus.DirectoryExists(path) then
        --SystemLog('EnumFiles: [' .. path .. '] dose not exist!')
        SystemLog(string.format(i18n 'path %q dose not exist', path))
        return {}
    end
    local pp = FU:fullPathForFilename(path)
    assert(pp ~= '', 'can not find ' .. path)
    local files = FU:listFiles(path)
    local ret = {}
    ---@param f string
    for _, f in ipairs(files) do
        local fullpath = f
        if f:sub(-1) == '/' then
            f = f:sub(1, -2)
            -- find may return nil
            local _pos = f:reverse():find('/')
            if _pos then
                local pos = 1 - _pos
                f = f:sub(pos)
            end
            if f ~= '.' and f ~= '..' then
                table.insert(ret, {
                    isDirectory = true, name = f, fullPath = fullpath })
            end
        else
            local access = lfs.attributes(ex.UTF8ToMultiByte(f), 'access') or 'UNKNOEN'
            local size = FU:getFileSize(f) or 'UNKNOEN'
            local pos = 1 - f:reverse():find('/')
            f = f:sub(pos)
            table.insert(ret, {
                isDirectory = false, name = f, size = size, lastAccessTime = access, fullPath = fullpath })
        end
    end
    return ret
end

function plus.enumFiles(path)
    return plus.EnumFiles(path)
end

function plus.enumFilesByType(path, suffix)
    local ret = {}
    suffix = string.lower(suffix)
    local l = -1 - #suffix
    local files = plus.EnumFiles(path)
    for i, v in ipairs(files) do
        if not v.isDirectory then
            if string.lower(v.name:match(".+%.(%w+)$") or '') == suffix then
                v.name = v.name:sub(1, l)
                assert(v.name ~= '')
                table.insert(ret, v)
            end
        end
    end
end

---getWriteablePath
---@return string
function plus.getWritablePath()
    if plus.writablePath then
        return plus.writablePath
    end
    local wp = FU:getWritablePath()
    if plus.isDesktop() and wp == './' then
        return FU:fullPathForFilename(wp):sub(1, -3)
    else
        return wp
    end
    --return FU:getWritablePath()
end

local osname = ex.GetOSName()
plus.os = osname
plus.is_mobile = osname == 'android' or osname == 'ios'
--Android-----------------------------------------
if osname == 'android' then
    local native = require('platform.android.native')
    plus.getAssetsPath = native.getAssetsPath
    plus.getCocos2dxPackageName = native.getCocos2dxPackageName
    plus.vibrate = native.vibrate
    plus.getVersion = native.getVersion
    plus.openURL = native.openURL
    plus.getDPI = native.getDPI
    plus.getSDCardPath = native.getSDCardPath
    plus.GetNativeInfo = native.GetNativeInfo

    local info = native.GetNativeInfo()
    plus.native_info = info
    local p = info['SDCardPath']
    if p and p ~= '' then
        local path = p .. '/lstg/'
        if plus.DirectoryExists(path) then
            FU:setWritablePath(path)
            FU:addSearchPath(path)
            plus.writablePath = path
            SystemLog(string.format('set local writable path to %q', path))
        end
        local lp = lstg.LogSystem:getInstance():getPath()
        local expected = p .. '/lstg/lstg_log.txt'
        if lp ~= expected then
            if lstg.LogSystem:getInstance():changePath(expected) then
                SystemLog('change log path successfully')
            else
                SystemLog('failed to change log path')
            end
        end
    end

    local inf = '\n=== Native Info ===\n'
    for k, v in pairs(info) do
        inf = inf .. string.format('%s = %s\n', k, tostring(v))
    end
    SystemLog(inf)
end

local _languages = {
    'english',
    'chinese',
    'french',
    'italian',
    'german',
    'spanish',
    'dutch',
    'russian',
    'korean',
    'japanese',
    'hungarian',
    'portuguese',
    'arabic',
    'norwegian',
    'polish',
    'turkish',
    'ukrainian',
    'romanian',
    'bulgarian',
    'belarusian',
}
local _platform = {
    'Windows',
    'Linux',
    'macOS',
    'Android',
    'iPhone',
    'iPad',
    'BlackBerry',
    'NACL',
    'Emscripten',
    'Tizen',
    'WinRT',
    'WP8',
}
local function _log_app_info()
    local info = {}
    local app = cc.Application:getInstance()
    info.platform = _platform[app:getTargetPlatform() + 1] or 'unknown'
    info.version = app:getVersion()
    info.language_code = app:getCurrentLanguageCode()
    info.language = _languages[app:getCurrentLanguage() + 1] or 'unknown'
    --local inf = '\n=== Application Info ===\n{'
    --for k, v in pairs(info) do
    --    inf = string.format('%s\n    %s = %s', inf, k, tostring(v))
    --end
    --inf = inf .. '\n}'
    --SystemLog(inf)
    plus.language = info.language
    plus.platform = info.platform
end
_log_app_info()

if not plus.is_mobile then
    FU:setWritablePath('./')
end

--

function plus.isMobile()
    return plus.is_mobile
end

function plus.isDesktop()
    return not plus.is_mobile
end

---gives an error by a messagebox
---@param msg string
---@param title string
---@param exit boolean @true if omitted
function plus.error(msg, title, exit)
    msg = msg or ''
    title = title or ''
    exit = exit or (exit == nil)
    local emsg = exit and ', exit' or ''
    SystemLog(string.format('error: [%s]%s' .. emsg, title, msg))
    ex.MessageBox(msg, title)
    if exit then
        ex.OnExit()
        os.exit()
    end
end

