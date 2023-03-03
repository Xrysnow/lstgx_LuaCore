--

---@~chinese 设置窗口化(true)/非窗口化(false)，请使用 `ChangeVideoMode`
---
---@~english Set the engine windowed or full-screen. `true` for windowed and `false` for full-screen. Default is `true`. Please use `ChangeVideoMode` instead.
---
---@param b boolean
---@deprecated
function SetWindowed(b)
end
lstg.SetWindowed = SetWindowed

---@~chinese 设置窗口大小。可以在运行时动态设置。
---
---@~english Set window resolution (size) if game is windowed.
---
---@param width number
---@param height number
function SetResolution(width, height)
    local w = lstg.WindowHelper:getInstance()
    if w and not w:isFullscreen() then
        w:setSize(cc.size(width, height))
    end
end
lstg.SetResolution = SetResolution

---@~chinese 改变视频选项。若成功返回true，否则返回false
---
---@~english Change video parameters. Returns `true` if success, otherwise returns `false` and restore last parameters.
---
---@param width number
---@param height number
---@param windowed boolean
---@param vsync boolean
function ChangeVideoMode(width, height, windowed, vsync)
    local w = lstg.WindowHelper:getInstance()
    if w then
        if windowed then
            w:setSize(cc.size(width, height))
        else
            w:setFullscreen()
            --cc.Director:getInstance():getOpenGLView():setFrameSize(width, height)
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
lstg.ChangeVideoMode = ChangeVideoMode

---@~chinese 设置是否显示光标，默认显示
---
---@~english Set if the mouse cursor is displayed in game window. Default is `true`.
---
---@param b boolean
function SetSplash(b)
    local w = lstg.WindowHelper:getInstance()
    if w then
        w:setCursorVisible(b)
    end
end
lstg.SetSplash = SetSplash

---@~chinese 设置窗口标题。默认为"LuaSTG-x"。
---
---@~english Set the caption of window. Default is `"LuaSTG-x"`.
---
---@param title string
function SetTitle(title)
    local w = lstg.WindowHelper:getInstance()
    if w then
        w:setTitle(title)
        --Print('set title to '..title)
    end
end
lstg.SetTitle = SetTitle
