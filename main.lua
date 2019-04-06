--lstg.DoFile('jit_test.lua')
local fu = cc.FileUtils:getInstance()
fu:setPopupNotify(true)
-- note: opengl view is opened in display.lua by default,
-- it's necessary for FrameInit
require "config"

require('cocos.init')
setmetatable(_G, nil)
require('cc.ext.__init__')
require('cc.to_string')
require('cc.color')
require('i18n.__init__')

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
    if ex.GetOSName() == 'android' then
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

-- note: in app.run, only __G__TRACKBACK__ will take effect

__G__TRACKBACK__ = function(msg)
    msg = debug.traceback(msg, 3)
    print(msg)
    lstg.SystemLog(msg)
    if plus and plus.isMobile() then
        require('ui.MessageBox').OK('Error', msg, function()
            ex.OnExit()
            cc.Director:getInstance():endToLua()
        end)
        for _, v in ipairs({ 'FrameFunc' }) do
            _G[v] = function()
            end
        end
    else
        ex.MessageBox(msg, 'ERROR')
        ex.OnExit()
        os.exit()
    end
    lstg.SystemLog('caught error in main')
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    lstg.SystemLog('=== Error Message ===\n' .. msg)
end
