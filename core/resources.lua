---默认音量
local soundVolume = {
    bonus    = 0.6, bonus2 = 0.6, boon00 = 0.9, boon01 = 0.7,
    cancel00 = 0.4, cardget = 0.8, cat00 = 0.55,
    ch00     = 0.9, ch02 = 1,
    don00    = 0.85, damage00 = 0.35, damage01 = 0.5,
    enep00   = 0.35, enep02 = 0.45, enep01 = 0.6, explode = 0.4, extend = 0.6,
    graze    = 0.4, gun00 = 0.6, invalid = 0.8, item00 = 0.32,
    kira00   = 0.33, kira01 = 0.4, kira02 = 0.6,
    lazer00  = 0.35, lazer01 = 0.35, lazer02 = 0.18,
    lgods1   = 0.6, lgods2 = 0.6, lgods3 = 0.6, lgods4 = 0.6, lgodsget = 0.6,
    msl      = 0.37, msl2 = 0.37, nep00 = 0.5, nodamage = 0.5,
    ok00     = 0.4, option = 0.7, pause = 0.5, pldead00 = 0.7, plst00 = 0.27,
    power0   = 0.7, power02 = 0.7, power1 = 0.6,
    powerup  = 0.6, powerup1 = 0.55,
    select00 = 0.4, slash = 0.75,
    tan00    = 0.28, tan01 = 0.35, tan02 = 0.5,
    timeout  = 0.6, timeout2 = 0.7, water = 0.6,
}
_G['soundVolume'] = soundVolume

local _PlaySound = PlaySound
---PlaySound，全局函数
function PlaySound(name, vol, pan, sndflag)
    local v
    if not (sndflag) then
        v = soundVolume[name] or vol
    else
        v = vol
    end
    _PlaySound(name, v, (pan or 0) / 1024)
end

---载入图像名及对应参数

--local _LoadImage = LoadImage
--local function __LoadImage(...)
--    local ret = _LoadImage(...)
--    ret:setBlendMode(assert(lstg.BlendMode:getDefault()))
--    return ret
--end
--local _LoadAnimation = LoadAnimation
--local function __LoadAnimation(...)
--    local ret = _LoadAnimation(...)
--    ret:setBlendMode(assert(lstg.BlendMode:getDefault()))
--    return ret
--end
--for k, v in pairs({ LoadImage = __LoadImage, LoadAnimation = __LoadAnimation }) do
--    _G[k] = v
--end

--function LoadPS(...)
--    local ret = lstg.LoadPS(...)
--    local inf = ret:getInfo()
--    inf = string.gsub(inf, '|', '\n')
--    SystemLog(inf)
--    return ret
--end

---复制已载入的图像资源
---@param newname string @新的图像资源名
---@param img string @原有图像资源名
---@return lstg.ResSprite
--function CopyImage(newname, img)
--    local res = FindResSprite(img)
--    if not res then
--        error(string.format(i18n "can't find image %q", img))
--    end
--    res:clone(newname)
--    return res
--end

---从纹理资源载入图像组
---@param prefix string @资源名前缀
---@param texname string @纹理资源名
---@param x number
---@param y number @起始坐标
---@param w number
---@param h number @单个图像尺寸
---@param cols number
---@param rows number @行列数
---@param a number
---@param b number @碰撞半径 省略为0
---@param rect boolean @是否为矩形碰撞盒 省略为false
function LoadImageGroup(prefix, texname, x, y, w, h, cols, rows, a, b, rect)
    for i = 0, cols * rows - 1 do
        LoadImage(prefix .. (i + 1), texname,
                             x + w * (i % cols), y + h * (int(i / cols)), w, h, a or 0, b or 0, rect or false)
    end
end

function LoadImageFromFile(name, filename, mipmap, a, b, rect)
    LoadTexture(name, filename, mipmap)
    local w, h = GetTextureSize(name)
    return LoadImage(name, name, 0, 0, w, h, a or 0, b or 0, rect)
end

---从文件载入动画
---@param texaniname string @资源名
---@param filename string @文件名
---@param mipmap boolean @创建Mipmap链，用于加快图像渲染，对动态纹理和渲染目标无效
---@param n number @行数
---@param m number @列数
---@param intv number @动画间隔（帧） 最小为1
---@param a number @横向碰撞大小的一半
---@param b number @纵向碰撞大小的一半
---@param rect boolean @是否为矩形碰撞盒
function LoadAniFromFile(texaniname, filename, mipmap, n, m, intv, a, b, rect)
    LoadTexture(texaniname, filename, mipmap)
    local w, h = GetTextureSize(texaniname)
    return LoadAnimation(texaniname, texaniname, 0, 0, w / n, h / m, n, m, intv, a, b, rect)
end

--请使用 editor.lua 中的 _LoadImageGroupFromFile
function LoadImageGroupFromFile(texaniname, filename, mipmap, n, m, a, b, rect)
    LoadTexture(texaniname, filename, mipmap)
    local w, h = GetTextureSize(texaniname)
    return LoadImageGroup(texaniname, texaniname, 0, 0, w / n, h / m, n, m, a, b, rect)
end

--local ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 8, fx = 9 }
--_G['ENUM_RES_TYPE'] = ENUM_RES_TYPE

---资源是否已加载
---typename：资源类型 tex,img,ani,bgm,snd,psi,fnt,ttf,fx
---resname：资源名
--function CheckRes(typename, resname)
--    local t = ENUM_RES_TYPE[typename]
--    if t == nil then
--        error(string.format('%s: %s', i18n 'Invalid resource type name', typename))
--    else
--        return lstg.CheckRes(t, resname)
--    end
--end

--local _EnumRes = lstg.EnumRes
-----枚举资源
-----@param typename string|number @资源类型: tex,img,ani,bgm,snd,psi,fnt,ttf,fx
-----@return table,table @包含资源名的table，分别属于全局和关卡资源池
--function EnumRes(typename)
--    local t
--    if type(typename) == 'string' then
--        t = ENUM_RES_TYPE[typename]
--    else
--        t = typename
--    end
--    if not t then
--        error(string.format('%s: %s', i18n 'Invalid resource type name', typename))
--    end
--    return _EnumRes(t)
--end

local ENUM_TTF_FMT = {
    left        = 0x00000000,
    center      = 0x00000001,
    right       = 0x00000002,
    top         = 0x00000000,
    vcenter     = 0x00000004,
    bottom      = 0x00000008,
    wordbreak   = 0x00000010,
    --singleline=0x00000020,
    --expantextabs=0x00000040,
    noclip      = 0x00000100,
    --calcrect=0x00000400,
    --rtlreading=0x00020000,
    paragraph   = 0x00000010,
    centerpoint = 0x00000105,
}
setmetatable(ENUM_TTF_FMT, { __index = function(t, k)
    return 0
end })
_G['ENUM_TTF_FMT'] = ENUM_TTF_FMT
local _RenderTTF = RenderTTF

---
---渲染TTF
---ttfname：已载入的字体名
---text：文本
---left,right,bottom,top：文本区域
---color：文本颜色
---scale：文本缩放，可省略
---...：文本格式 如：'left', 'top'
---  包括：left,center,right,top,vcenter,bottom,wordbreak,noclip,paragraph,centerpoints
function RenderTTF(ttfname, text, left, right, bottom, top, color, ...)
    local fmt = 0
    local arg = { ... }
    local i0 = 1
    local scale = 1
    if type(arg[1]) == 'number' then
        scale = arg[1]
        i0 = 2
    end
    for i = i0, #arg do
        fmt = fmt + ENUM_TTF_FMT[arg[i]]
    end
    _RenderTTF(ttfname, text, left, right, bottom, top, fmt, color, scale)
end

local _RenderText = RenderText
---
---直接渲染文本
---fontname：已载入的字体名
---text：文本
---x,y：对齐点
---size：文本缩放
---...：文本格式 如：'left', 'top'
function RenderText(fontname, text, x, y, size, ...)
    local fmt = 0
    local arg = { ... }
    for i = 1, #arg do
        fmt = fmt + ENUM_TTF_FMT[arg[i]]
    end
    _RenderText(fontname, text, x, y, size, fmt)
end
