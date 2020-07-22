--

---该函数未指定窗口化分辨率，请使用ChangeVideoMode
---设置窗口化(true)/非窗口化(false)
---@param b boolean
---@deprecated
function SetWindowed(b)
end

---设置窗口大小
---可以在运行时动态设置
---@param width number
---@param height number
function SetResolution(width, height)
    local w = lstg.WindowHelperDesktop:getInstance()
    if w and not w:isFullscreen() then
        w:setSize(cc.size(width, height))
    end
end

---改变视频选项。若成功返回true，否则返回false
---@param width number
---@param height number
---@param windowed boolean
---@param vsync boolean
function ChangeVideoMode(width, height, windowed, vsync)
    local w = lstg.WindowHelperDesktop:getInstance()
    if w then
        if windowed then
            w:setSize(cc.size(width, height))
        else
            w:setFullscreen()
        end
        w:setVsync(vsync)
        SystemLog(string.format(
                'change video mode to: (%d, %d), %s, %s',
                width, height,
                windowed and 'Windowed' or 'FullScreen',
                vsync and 'VSync On' or 'VSync Off'))
        w:moveToCenter()
        return true
    else
        return false
    end
end

---设置是否显示光标，默认显示
---@param b boolean
function SetSplash(b)
    local w = lstg.WindowHelperDesktop:getInstance()
    if w then
        w:setCursorVisible(b)
    end
end

---设置窗口标题
---默认为"LuaSTG-x"
---@param title string
function SetTitle(title)
    local w = lstg.WindowHelperDesktop:getInstance()
    if w then
        w:setTitle(title)
        --Print('set title to '..title)
    end
end
