--
local M = {}
local FU = cc.FileUtils:getInstance()

function M.changeLogPath(path)
    local lp = lstg.LogSystem:getInstance():getPath()
    if lp ~= path then
        if lstg.LogSystem:getInstance():changePath(path) then
            os.remove(lp)
            SystemLog(('change log path to %q'):format(path))
        else
            SystemLog(('failed to change log path to %q'):format(path))
            return false
        end
    end
    return true
end

function M.changeWritablePath()
    local ret
    local osname = lstg.GetPlatform()
    if osname == 'android' then
        local native = require('platform.android.native')
        local p = native.getSDCardPath()
        if p and p ~= '' then
            local path = p .. '/lstg/'
            if FU:isDirectoryExist(path) then
                FU:setWritablePath(path)
                FU:addSearchPath(path)
                ret = path
            end
            M.changeLogPath(path .. '/lstg_log.txt')
        end
    elseif osname == 'mac' then
        local home = os.getenv('HOME')
        if #home > 1 then
            -- use Documents
            local path = home .. '/Documents/lstg'
            if FU:isDirectoryExist(path) then
                FU:setWritablePath(path)
                FU:addSearchPath(path)
                local ok = M.changeLogPath(path .. '/lstg_log.txt')
                if ok then
                    ret = path
                end
            end
        end

        if not ret then
            -- use Resources
            local native = require('platform.apple.native')
            local p = native.getBundleResourcesDirectory()
            if #p > 1 and FU:isDirectoryExist(p) then
                local path = p
                FU:setWritablePath(path)
                FU:addSearchPath(path)
                ret = path
                M.changeLogPath(path .. '/lstg_log.txt')
            end
        end
    elseif osname == 'ios' then
    elseif osname == 'windows' then
        FU:setWritablePath('./')
    elseif osname == 'linux' then
        local dir = require('platform.linux.directory').get_current_dir_name()
        if not dir then
            dir = FU:fullPathForFilename('./')
        end
        if dir and dir ~= '' then
            FU:setWritablePath(dir)
            ret = FU:getWritablePath()
        end
    end
    if ret then
        if ret:sub(-1) ~= '/' then
            ret = ret .. '/'
        end
        SystemLog(('set local writable path to %q'):format(ret))
    end
    return ret
end

function M.enumMods(path, root_name)
    local ret = {}
    root_name = root_name or 'root.lua'
    local files = plus.EnumFiles(path)
    for i, v in ipairs(files) do
        if v.isDirectory then
            if plus.FileExists(path .. v.name .. '/' .. root_name) then
                table.insert(ret, v)
            end
        else
            if string.lower(v.name:match(".+%.(%w+)$") or '') == 'zip' then
                v.name = v.name:sub(1, -5)
                assert(v.name ~= '')
                table.insert(ret, v)
            end
        end
    end
    table.sort(ret, function(a, b)
        if a.isDirectory ~= b.isDirectory then
            return a.isDirectory
        end
        return a.name < b.name
    end)
    return ret
end

return M
