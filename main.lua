--
--lstg.DoFile('jit_test.lua')
local fu = cc.FileUtils:getInstance()
fu:setPopupNotify(true)
-- note: GLView is opened in display.lua
-- it's necessary for FrameInit
require('config')
require('cocos.init')
setmetatable(_G, nil)
-- package.path may not end with ';'
package.path = package.path .. ';?/__init__.lua;'
-- ';;' will cause error
package.path = package.path:gsub('[;]+', ';')
require('cc.ext')
require('cc.to_string')
require('cc.color')
require('i18n')
require('audio')

local _path = {}
local _path_rec = {}
for _, v in ipairs(fu:getSearchPaths()) do
    local p = string.gsub(v, '\\', '/')
    p = string.gsub(p, '//', '/')
    if not _path_rec[p] then
        table.insert(_path, p)
        _path_rec[p] = true
    end
end
fu:setSearchPaths(_path)

local sp = fu:getSearchPaths()
local _sp = '=== Search Path ===\n{'
for _, v in ipairs(sp) do
    _sp = string.format('%s\n    %q', _sp, v)
end
lstg.SystemLog(_sp .. '\n}')

local function main()
    lstg.SystemLog('start main')
    lstg.FrameInit()
    local platform = lstg.GetPlatform()
    if platform == 'android' then
        -- change src path to 'sdcard/lstg/src' if it exists
        local sd = require('platform.android.native').getSDCardPath()
        if sd and sd ~= '' then
            local src = sd .. '/lstg/src'
            if fu:isDirectoryExist(src) then
                local paths = {}
                for _, v in ipairs(sp) do
                    if v ~= 'assets/src/' then
                        table.insert(paths, v)
                    end
                end
                table.insert(paths, src)
                fu:setSearchPaths(paths)
                lstg.SystemLog(string.format('change src path to %q', src))
            end
        end
        require('platform.android.native').setOrientationLandscape()
    end
    lstg.DoFile('launch')
    lstg.SystemLog('start app')
    require("app.MyApp"):create():run()
end

local TRACE_MAX_LEVEL = 16
local function traceback(msg, level)
    local ret = ''
    if msg then
        ret = msg .. '\n'
    end
    ret = ret .. 'stack traceback:'
    while true do
        local info = debug.getinfo(level, "Slnf")
        if not info then
            break
        end
        local msgs = {}
        local source = info.source or ''
        if info.short_src == '[C]' then
            source = '[C]'
        else
            source = string.format('[%s]', source)
        end
        table.insert(msgs, string.format('    %s', source, info.currentline, info.name or ""))
        if info.currentline > 0 then
            table.insert(msgs, string.format('%d:', info.currentline))
        end
        if info.namewhat and info.name then
            table.insert(msgs, string.format(' in function \'%s\'', info.name))
        else
            if info.what == 'm' or info.linedefined == 0 then
                table.insert(msgs, ' in main chunk')
            elseif info.what == 'C' then
                table.insert(msgs, string.format(' at %s', tostring(info.func)))
            else
                table.insert(msgs, string.format(' in function <%s:%d>', source, info.linedefined))
            end
        end
        ret = ret .. '\n' .. table.concat(msgs, '')
        level = level + 1
        if level > TRACE_MAX_LEVEL then
            ret = ret .. '\n...'
            break
        end
    end
    return ret
end

-- note: in app.run, only __G__TRACKBACK__ will take effect

__G__TRACKBACK__ = function(msg)
    --msg = debug.traceback(msg, 3)
    msg = traceback(msg, 3)
    print(msg)
    lstg.SystemLog(msg)
    if plus and plus.isMobile() then
        require('cc.ui.MessageBox').OK('Error', msg, function()
            --ex.OnExit()
            cc.Director:getInstance():endToLua()
        end)
        for _, v in ipairs({ 'FrameFunc' }) do
            _G[v] = function()
            end
        end
    else
        lstg.MessageBox(msg, 'ERROR')
        lstg.FrameEnd()
        os.exit()
    end
    lstg.SystemLog('caught error in main')
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    lstg.SystemLog('=== Error Message ===\n' .. msg)
end
