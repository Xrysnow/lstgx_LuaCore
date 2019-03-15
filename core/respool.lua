--

local ResourceType = {
    Texture      = 1,
    Sprite       = 2,
    Animation    = 3,
    Music        = 4,
    SoundEffect  = 5,
    Particle     = 6,
    Font         = 7,
    FX           = 8,
    RenderTarget = 9,
    --Video        = 10
}
local ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 7, fx = 8, rt = 9 }
_G['ENUM_RES_TYPE'] = ENUM_RES_TYPE
---@return cc.Map[]
local function _create_pool()
    local ret = {}
    --for k, v in pairs(ENUM_RES_TYPE) do
    --    ret[v] = require('cc.Map')()
    --end
    for i = 1, 9 do
        ret[i] = require('cc.Map')()
    end
    return ret
end
local LRES = lstg.ResourceMgr:getInstance()

local function _toResType(v)
    if type(v) == 'string' then
        return ENUM_RES_TYPE[v]
    elseif type(v) == 'number' then
        if 1 <= v and v <= 9 then
            return v
        end
    end
end
local function _toColliType(v)
    if v == nil then
        return 0
    elseif type(v) == 'boolean' then
        return v and 1 or 0
    elseif type(v) == 'number' then
        if 0 <= v and v <= 5 then
            return v
        end
    end
end

local pools = {
    global = _create_pool(),
    stage  = _create_pool(),
}
local _global = pools.global
local _stage = pools.stage
local _cur
---@return cc.Map
local function _getMap(resType)
    return pools[_cur][assert(_toResType(resType), string.format('invalid resuorce type %q', resType))]
end
local _log = false
function SetResLoadInfo(b)
    _log = b
end

local CHECK_RES_INFO = {
    tex = { i18n "failed to load texture %q from %q",
            i18n "load texture %q from %q" },
    img = { i18n "failed to load image %q with texture %q",
            i18n "load image %q with texture %q" },
    ani = { i18n "failed to load animation %q with texture %q",
            i18n "load animation %q with texture %q" },
    bgm = { i18n "failed to load music %q from %q",
            i18n "load music %q from %q" },
    snd = { i18n "failed to load sound %q from %q",
            i18n "load sound %q from %q" },
    psi = { i18n "failed to load particle %q with image %q",
            i18n "load particle %q with image %q" },
    fnt = { i18n "failed to load HGE font %q from %q",
            i18n "load HGE font %q from %q" },
    ttf = { i18n "failed to load TTF font %q from %q",
            i18n "load TTF font %q from %q" },
    fx  = { i18n "failed to load fx %q from %q and %q",
            i18n "load fx %q from %q and %q'" },
    rt  = { i18n "failed to create render target %q",
            i18n "create render target %q" },
}

local function _check(res, type, args)
    local inf = CHECK_RES_INFO[type]
    if not inf then
        assert(res)
        return
    end
    assert(res, string.format(inf[1], unpack(args)))
    if _log then
        SystemLog(string.format(inf[2], unpack(args)))
    end
    --return res
end

--- 设置当前激活的资源池类型
---@param pool_type string @'stage' or 'global'
function SetResourceStatus(poolType)
    _cur = poolType
end
lstg.SetResourceStatus = SetResourceStatus

--- 若只有一个参数，则删除一个池中的所有资源。否则删除对应池中的某个资源。参数可选global或stage。
--- 若资源仍在使用之中，将继续保持装载直到相关的对象被释放。
function RemoveResource(poolType, resType, name)
    local pool = assert(pools[poolType],
                        "invalid argument #1 for 'RemoveResource', requires 'stage' or 'global'")
    if not resType then
        for k, v in pairs(pool) do
            v:clear()
        end
    else
        resType = _toResType(resType)
        assert(resType and poolType[resType],
               "invalid argument #2 for 'RemoveResource'")
        assert(name, "invalid argument #3 for 'RemoveResource'")
        pool[resType]:insert(name, nil)
    end
end
lstg.RemoveResource = RemoveResource

--- 获得一个资源的类别，通常用于检测资源是否存在。
--->   细节
--->       方法会根据名称先在全局资源池中寻找，若有则返回global。
--->       若全局资源表中没有找到资源，则在关卡资源池中找，若有则返回stage。
--->       若不存在资源，则返回nil。
function CheckRes(resType, name)
    resType = _toResType(resType)
    assert(resType,
           "invalid argument #1 for 'CheckRes'")
    if pools.global[resType]:at(name) then
        return 'global'
    end
    if pools.stage[resType]:at(name) then
        return 'stage'
    end
end
lstg.CheckRes = CheckRes

--- 枚举资源池中某种类型的资源
--- 依次返回全局资源池、关卡资源池中该类型的所有资源的名称。
function EnumRes(resType)
    return pools.global[_toResType(resType)]:keys(), pools.stage[_toResType(resType)]:keys()
end
lstg.EnumRes = EnumRes

--- 获取纹理的宽度和高度
---@param name string
---@return number,number
function GetTextureSize(name)
    local res = FindResTexture(name)
    if res then
        local tex = res:getTexture()
        return tex:getPixelsWide(), tex:getPixelsHigh()
    end
end
lstg.GetTextureSize = GetTextureSize

--- 从文件载入纹理，支持多种格式，推荐png
---@param texname string
---@param filename string
---@param mipmap boolean @是否使用纹理链
---@return lstg.ResTexture
function LoadTexture(name, path)
    local map = _getMap(ENUM_RES_TYPE.tex)
    local old = map:at(name)
    if old then
        return old
    end
    path = string.path_uniform(path)
    ---@type lstg.ResTexture
    local res
    FileTaskWrapper(path, true, function()
        res = lstg.ResTexture:create(name, path)
    end)
    _check(res, 'tex', { name, path })
    map:insert(name, res)

    if name == 'hint' then
        Print('[res]',name,res:getTexture():getName())
    end
    return res
end
lstg.LoadTexture = LoadTexture

function LoadTextureAsync(name, path, callback)
    path = string.path_uniform(path)
    local map = _getMap(ENUM_RES_TYPE.tex)
    local old = map:at(name)
    if old and callback then
        callback(old)
        return
    end
    cc.Director:getInstance():getTextureCache():addImageAsync(path, function(tex)
        local res = lstg.ResTexture:createWithTexture(name, tex)
        _check(res, 'tex', { name, path })
        map:insert(name, res)
        if callback then
            callback(res)
        end
    end)
end

--- 在纹理中创建图像
--- x,y：图像在纹理上左上角的坐标（纹理左上角为（0,0），向下向右为正方向）
--- w,h：图像的大小
--- a,b,rect：横向、纵向碰撞判定和判定形状。
--->  细节
--->    当把一个图像赋予对象的img字段时，它的a、b、rect属性会自动被赋值到对象上。
---@param name string
---@param tex_name string
---@param x number
---@param y number
---@param w number
---@param h number
---@param a number
---@param b number
---@param colliType boolean|number|string
---@return lstg.ResSprite
function LoadImage(name, tex_name, x, y, w, h, a, b, colliType)
    local map = _getMap(ENUM_RES_TYPE.img)
    local old = map:at(name)
    if old then
        return old
    end
    local tex = FindResTexture(tex_name)
    if not tex then
        error(string.format("can't find texture %q", tex_name))
    end
    colliType = assert(_toColliType(colliType))
    local res = lstg.ResSprite:create(name, tex, x, y, w, h, a or 0, b or 0, colliType)
    _check(res, 'img', { name, tex_name })
    res:setBlendMode(assert(lstg.BlendMode:getDefault()))
    map:insert(name, res)
    return res
end
lstg.LoadImage = LoadImage

--- 设置图像状态，可选一个颜色参数用于设置所有顶点或者给出4个颜色设置所有顶点。
--- name：图像资源名
--- blend_mode：混合模式
---    混合选项可选
--->""          默认值，=mul+alpha
--->"mul+add"   顶点颜色使用乘法，目标混合使用加法
--->"mul+alpha" (默认)顶点颜色使用乘法，目标混合使用alpha混合
--->"mul+sub"   顶点颜色使用乘法，结果=图像上的颜色-屏幕上的颜色
--->"mul+rev"   顶点颜色使用乘法，结果=屏幕上的颜色-图像上的颜色
--->"add+add"   顶点颜色使用加法，目标混合使用加法
--->"add+alpha" 顶点颜色使用加法，目标混合使用alpha混合
--->"add+sub"   顶点颜色使用加法，结果=图像上的颜色-屏幕上的颜色
--->"add+rev"   顶点颜色使用加法，结果=屏幕上的颜色-图像上的颜色
---color：混合颜色
---@param name string
---@param blend_mode string
---@param color lstg.Color
function SetImageState(name, blendMode, color1, color2, color3, color4)
    local sp = FindResSprite(name)
    if not sp then
        error(string.format("can't find image %q", name))
    end
    if blendMode then
        sp:setBlendMode(blendMode)
    end
    if color2 then
        sp:setColor(color1, 0):setColor(color2, 1):setColor(color3, 3):setColor(color4, 2)
    elseif color1 then
        sp:setColor(color1)
    end
end
lstg.SetImageState = SetImageState

--- 设置图像中心
--- name：图像资源名
--- x,y：相对于图像左上角的坐标
---@param name string
---@param x number
---@param y number
function SetImageCenter(name, x, y)
    ---@type lstg.ResSprite
    local sp = FindResSprite(name)
    if not sp then
        error(string.format("can't find image %q", name))
    end
    local sz = sp:getSprite():getContentSize()
    sp:getSprite():setAnchorPoint(cc.p(x / sz.width, 1 - y / sz.height))
end
lstg.SetImageCenter = SetImageCenter

function CopyImage(newname, img)
    local map = _getMap(ENUM_RES_TYPE.img)
    local old = map:at(newname)
    if old then
        return old
    end
    local res = FindResSprite(img)
    if not res then
        error(string.format(i18n "can't find image %q", img))
    end
    local ret = res:clone(newname)
    assert(res, string.format('failed to copy image %q', img))
    map:insert(newname, ret)
    return ret
end

--- 装载动画
--- 动画总是循环播放的
---@param name string
---@param tex_name string
---@param x number
---@param y number @第一帧的左上角位置
---@param w number
---@param h number @一帧的大小
---@param nCol number
---@param nRow number @纵向横向的分割数，以列优先顺序排列
---@param interval number @帧间隔
---@param a number
---@param b number
---@param colliType boolean @同Image
---@return lstg.ResAnimation
function LoadAnimation(name, tex_name, x, y, w, h, nCol, nRow, interval, a, b, colliType)
    local map = _getMap(ENUM_RES_TYPE.ani)
    local old = map:at(name)
    if old then
        return old
    end
    local tex = FindResTexture(tex_name)
    if not tex then
        error(string.format("can't find texture %q", tex_name))
    end
    colliType = assert(_toColliType(colliType))
    local res = lstg.ResAnimation:create(
            name, tex, x, y, w, h, nCol, nRow, interval, a or 0, b or 0, colliType)
    _check(res, 'ani', { name, tex_name })
    res:setBlendMode(assert(lstg.BlendMode:getDefault()))
    map:insert(name, res)
    return res
end
lstg.LoadAnimation = LoadAnimation

--- 类似于SetImageState
function SetAnimationState(name, blendMode, color1, color2, color3, color4)
    local ani = FindResAnimation(name)
    if not ani then
        error(string.format("can't find animation %q", name))
    end
    if blendMode then
        ani:setBlendMode(blendMode)
    end
    if color2 then
        ani:setColor(color1, 0):setColor(color2, 1):setColor(color3, 3):setColor(color4, 2)
    elseif color1 then
        ani:setColor(color1)
    end
end
lstg.SetAnimationState = SetAnimationState

--- 类似于SetImageCenter
function SetAnimationCenter(name, x, y)
    local ani = FindResAnimation(name)
    if not ani then
        error(string.format("can't find animation %q", name))
    end
    for i = 0, ani:getCount() - 1 do
        local s = ani:getSprite(i)
        local sz = s:getContentSize()
        s:setAnchorPoint(cc.p(x / sz.width, 1 - y / sz.height))
    end
end
lstg.SetAnimationCenter = SetAnimationCenter

local function _LoadRes(type, name, path, loadTask, async, callback)
    local map = _getMap(type)
    local old = map:at(name)
    if old then
        if async and callback then
            callback(old)
        end
        return old
    end
    local task = function()
        local res = loadTask()
        map:insert(name, res)
        return res
    end
    if not async then
        return FileTaskWrapper(path, true, task)
    else
        FileTaskAsyncWrapper(path, true, function()
            local res = task()
            if callback then
                callback(res)
            end
        end)
    end
end

local function _LoadPS(name, path, img_name, a, b, colliType, async, callback)
    path = string.path_uniform(path)
    local task = function()
        local sp = FindResSprite(img_name)
        if not sp then
            error(string.format("can't find image %q", img_name))
        end
        colliType = assert(_toColliType(colliType))
        local res = lstg.ResParticle:create(name, path, sp, a or 0, b or 0, colliType)
        _check(res, 'psi', { name, img_name })
        return res
    end
    return _LoadRes(ENUM_RES_TYPE.psi, name, path, task, async, callback)
end

--- 装载粒子系统
--- 使用HGE所用的粒子文件结构
---@param name string
---@param path string @定义文件
---@param img_name string @粒子图片
---@param a number
---@param b number
---@param colliType boolean
---@return lstg.ResParticle
function LoadPS(name, path, img_name, a, b, colliType)
    return _LoadPS(name, path, img_name, a, b, colliType, false)
end
lstg.LoadPS = LoadPS

function LoadPSAsync(name, path, img_name, a, b, colliType, callback)
    return _LoadPS(name, path, img_name, a, b, colliType, true, callback)
end

local function _LoadFont(name, path, async, callback)
    path = string.path_uniform(path)
    local task = function()
        local res = lstg.ResFont:createHGE(name, path)
        _check(res, 'fnt', { name, path })
        return res
    end
    return _LoadRes(ENUM_RES_TYPE.fnt, name, path, task, async, callback)
end

--- 装载纹理字体
--- 支持HGE的纹理字体，将根据定义文件在字体同级目录下寻找纹理文件
---@param name string @名称
---@param path string @定义文件
---@return lstg.ResFont
function LoadFont(name, path, _, _)
    return _LoadFont(name, path, false)
end
lstg.LoadFont = LoadFont

function LoadFontAsync(name, path, callback)
    return _LoadFont(name, path, true, callback)
end

--- 设置字体的混合模式、颜色。具体混合选项见SetImageState
function SetFontState(name, blend_mode, color)
    local font = FindResFont(name)
    if not font then
        error(string.format("can't find font %q", name))
    end
    if blend_mode then
        font:setBlendMode(blend_mode)
    end
    if color then
        font:setColor(color)
    end
end
lstg.SetFontState = SetFontState

local function _LoadTTF(name, path, size, async, callback)
    path = string.path_uniform(path)
    local task = function()
        local res = lstg.ResFont:createTTF(name, path, size)
        _check(res, 'ttf', { name, path })
        return res
    end
    return _LoadRes(ENUM_RES_TYPE.ttf, name, path, task, async, callback)
end

--- 加载TTF字体
---@param name string @资源名称
---@param path string @加载路径
---@param size number @字形大小
---@return lstg.ResFont
function LoadTTF(name, path, size)
    return _LoadTTF(name, path, size, false)
end
lstg.LoadTTF = LoadTTF

function LoadTTFAsync(name, path, size, callback)
    return _LoadTTF(name, path, size, true, callback)
end

--

local function _LoadSound(name, path, async, callback)
    path = string.path_uniform(path)
    local task = function()
        local res = lstg.ResSound:create(name, path)
        _check(res, 'snd', { name, path })
        return res
    end
    return _LoadRes(ENUM_RES_TYPE.snd, name, path, task, async, callback)
end

--- 装载音效
--- 仅支持wav或ogg，推荐使用wav格式
--->  细节
--->    音效将被装载进入内存。请勿使用较长的音频文件做音效。
--->    对于wav格式，由于受限于目前的实现，不支持非标准的、带压缩的格式。
---@param name string @资源名
---@param path string @文件路径
---@return lstg.ResSound
function LoadSound(name, path)
    return _LoadSound(name, path, false)
end
lstg.LoadSound = LoadSound

function LoadSoundAsync(name, path, callback)
    return _LoadSound(name, path, true, callback)
end

--

local function _LoadMusic(name, path, loop_end, loop_duration, async, callback)
    path = string.path_uniform(path)
    local task = function()
        local loop_start = math.max(0, loop_end - loop_duration)
        local res = lstg.ResMusic:create(name, path, loop_start, loop_end)
        _check(res, 'bgm', { name, path })
        return res
    end
    return _LoadRes(ENUM_RES_TYPE.bgm, name, path, task, async, callback)
end

--- 加载音乐
--- 仅支持wav或ogg，推荐使用ogg格式
--->  细节
--->    音乐将以流的形式装载进入内存，不会一次性完整解码放入内存。故不推荐使用wav格式，请使用ogg作为音乐格式。
--->    通过描述循环节可以设置音乐的循环片段。当音乐位置播放到end时会衔接到start。这一步在解码器中进行，以保证完美衔接。
---@param name string @资源名
---@param path string @文件路径
---@param loop_end number @循环结束（秒）
---@param loop_duration number @循环时长（秒）
---@return lstg.ResMusic
function LoadMusic(name, path, loop_end, loop_duration)
    return _LoadMusic(name, path, loop_end, loop_duration, false)
end
lstg.LoadMusic = LoadMusic

function LoadMusicAsync(name, path, loop_end, loop_duration, callback)
    return _LoadMusic(name, path, loop_end, loop_duration, true, callback)
end

--

--- 载入FX文件(shader特效)
---@param name string
---@param fpath string @fragment shader path, optional
---@param vpath string @vertex shader path, optional
---@return lstg.ResFX
function LoadFX(name, fpath, vpath)
    local map = _getMap(ENUM_RES_TYPE.fx)
    local old = map:at(name)
    if old then
        return old
    end
    fpath = fpath or 'src/shader/ColorMulti.frag'
    vpath = vpath or 'src/shader/Common.vert'
    fpath = string.path_uniform(fpath)
    vpath = string.path_uniform(vpath)
    local res = lstg.ResFX:create(name, vpath, fpath)
    _check(res, 'fx', { name, fpath, vpath })
    map:insert(name, res)
    return res
end
lstg.LoadFX = LoadFX

function CreateRenderTarget(name)
    local map = _getMap(ENUM_RES_TYPE.rt)
    local old = map:at(name)
    if old then
        return old
    end
    local res = lstg.ResRenderTarget:create(name)
    _check(res, 'rt', { name })
    map:insert(name, res)
    return res
end
lstg.CreateRenderTarget = CreateRenderTarget

--- deprecated
function IsRenderTarget(name)
    if FindResRenderTarget(name) then
        return true
    else
        return false
    end
end
lstg.IsRenderTarget = IsRenderTarget

------------------------------------------------------------
-- graph api
------------------------------------------------------------

---@param res lstg.ResFX
local function _setResFX(res, t)
    for k, v in pairs(t) do
        local ty = type(v)
        if ty == 'number' then
            res:setValue(k, v)
        elseif ty == 'string' then
            res:setTexture(k, assert(FindTexture2D(v)))
        elseif ty == 'userdata' then
            res:setColor(k, v)
        else
            error('invalid param')
        end
    end
end

function PushRenderTarget(name)
    assert(FindResRenderTarget(name):push())
end
lstg.PushRenderTarget = PushRenderTarget

function PopRenderTarget(name)
    assert(FindResRenderTarget(name):pop())
end

function PostEffect(rt, fx, blend, param)
    fx = FindResFX(fx)
    _setResFX(fx, param or {})
    assert(FindResRenderTarget(rt):render(fx, blend))
end
lstg.PostEffect = PostEffect

local _temp_rt = '::temp_rt::'

function PostEffectCapture()
    assert(FindResRenderTarget(_temp_rt):push())
end

function PostEffectApply(fx, blend_mode, param)
    fx = FindResFX(fx)
    _setResFX(fx, param or {})
    local _temp = FindResRenderTarget(_temp_rt)
    _temp:pop()
    _temp:render(fx, blend_mode)
end
lstg.PostEffectApply = PostEffectApply

function SetShaderUniform(fx, param)
    _setResFX(FindResFX(fx), param)
end

--- 设置全局图像渲染缩放
function SetImageScale(scale)
    LRES:setGlobalImageScaleFactor(scale)
end
lstg.SetImageScale = SetImageScale

function GetImageScale()
    return LRES:getGlobalImageScaleFactor()
end

------------------------------------------------------------
-- text api
------------------------------------------------------------

--TODO: method on ResFont?
local _RenderText = lstg.RenderText
function RenderText(name, text, x, y, scale, align)
    return _RenderText(FindResFont(name), text, x, y, scale, align)
end
lstg.RenderText = RenderText

local _RenderTTF = lstg.RenderTTF
function RenderTTF(name, text, left, right, bottom, top, fmt, color, scale)
    return _RenderTTF(FindResFont(name), text, left, right, bottom, top, fmt, color, scale)
end
lstg.RenderTTF = RenderTTF

function CalcTextSize(name, str)
    local sz = FindResFont(name):calcSize(str)
    return sz.x, sz.y
end

------------------------------------------------------------
-- audio api
------------------------------------------------------------

--TODO: reset factor when needed
local _se_factor = 1
function SetSEVolume(arg1, arg2)
    if not arg2 then
        _se_factor = tonumber(arg1) or 1
    else
        FindResSound(arg1):setVolume(arg2)
    end
end
lstg.SetSEVolume = SetSEVolume

local _bgm_factor = 1
function SetBGMVolume(arg1, arg2)
    if not arg2 then
        _bgm_factor = tonumber(arg1) or 1
    else
        FindResMusic(arg1):setVolume(arg2)
    end
end
lstg.SetBGMVolume = SetBGMVolume

function PlaySound(name, vol, pan)
    FindResSound(name):play(vol * _se_factor, pan or 0)
end
lstg.PlaySound = PlaySound

function StopSound(name)
    FindResSound(name):stop()
end
lstg.StopSound = StopSound

function PauseSound(name)
    FindResSound(name):pause()
end
lstg.PauseSound = PauseSound

function ResumeSound(name)
    FindResSound(name):resume()
end
lstg.ResumeSound = ResumeSound

function GetSoundState(name)
    local res = FindResSound(name)
    if res:isPlaying() then
        return 'playing'
    elseif res:isStopped() then
        return 'stopped'
    else
        return 'paused'
    end
end
lstg.GetSoundState = GetSoundState

function PlayMusic(name, vol, position)
    local res = FindResMusic(name)
    assert(res, string.format("can't find music %q", name))
    res:play((vol or 1) * _bgm_factor, 0)
    position = position or 0
    if position > 0 then
        res:setTime(position)
    end
end
lstg.PlayMusic = PlayMusic

function StopMusic(name)
    FindResMusic(name):stop()
end
lstg.StopMusic = StopMusic

function PauseMusic(name)
    FindResMusic(name):pause()
end
lstg.PauseMusic = PauseMusic

function ResumeMusic(name)
    FindResMusic(name):resume()
end
lstg.ResumeMusic = ResumeMusic

function GetMusicState(name)
    local res = FindResMusic(name)
    if res:isPlaying() then
        return 'playing'
    elseif res:isStopped() then
        return 'stopped'
    else
        return 'paused'
    end
end
lstg.GetMusicState = GetMusicState

------------------------------------------------------------
-- render api
------------------------------------------------------------

function Render(name, x, y, rot, hscale, vscale, z)
    hscale = hscale or 1
    vscale = vscale or hscale
    local factor = LRES:getGlobalImageScaleFactor()
    FindResSprite(name):render(x, y, rot or 0, hscale * factor, vscale * factor, z or 0.5)
end
lstg.Render = Render

function RenderRect(name, left, right, bottom, top)
    FindResSprite(name):renderRect(left, top, right, bottom)
end
lstg.RenderRect = RenderRect

function Render4V(name, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    FindResSprite(name):render4v(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
end
lstg.Render4V = Render4V

local _RenderTexture = lstg.RenderTexture
function RenderTexture(name, blend, vertex1, vertex2, vertex3, vertex4)
    _RenderTexture(FindResTexture(name) or FindResRenderTarget(name), blend, vertex1, vertex2, vertex3, vertex4)
end
lstg.RenderTexture = RenderTexture

local _RenderSector = lstg.RenderSector
function RenderSector(name, x, y, start, end_, r1, r2, seg)
    _RenderSector(FindResSprite(name), x, y, start, end_, r1, r2, seg)
end
lstg.RenderSector = RenderSector

------------------------------------------------------------
-- particle api
------------------------------------------------------------

---启动绑定在对象上的粒子发射器
---@param object object
function ParticleFire(object)
    local pp = GetParticlePool(object)
    if not pp then
        return
    end
    pp:setActive(true)
end
lstg.ParticleFire = ParticleFire

---停止绑定在对象上的粒子发射器
---@param object object
function ParticleStop(object)
    local pp = GetParticlePool(object)
    if not pp then
        return
    end
    pp:setActive(false)
end
lstg.ParticleStop = ParticleStop

---返回绑定在对象上的粒子发射器的存活粒子数
---@param object object
function ParticleGetn(object)
    local pp = GetParticlePool(object)
    if not pp then
        return 0
    end
    return pp:getAliveCount()
end
lstg.ParticleGetn = ParticleGetn

---获取绑定在对象上粒子发射器的发射密度（个/秒）
--- 细节
---　 更新粒子发射器的时钟始终为1/60s。
---@param object object
function ParticleGetEmission(object)
    local pp = GetParticlePool(object)
    if not pp then
        return 0
    end
    return pp:getEmissionFreq()
end
lstg.ParticleGetEmission = ParticleGetEmission

---设置绑定在对象上粒子发射器的发射密度（个/秒）
---@param object object
---@param count number
function ParticleSetEmission(object, count)
    local pp = GetParticlePool(object)
    if not pp then
        return
    end
    return pp:setEmissionFreq(count)
end
lstg.ParticleSetEmission = ParticleSetEmission

------------------------------------------------------------
local type = type

local function _FindResource(name, resType)
    local ret = name
    if type(name) == 'string' then
        ret = _stage[resType].___[name]
        if not ret then
            ret = _global[resType].___[name]
        end
    end
    return ret
end

---FindResource
---@param name string
---@param resType number|string
function FindResource(name, resType)
    local ret = name
    if type(name) == 'string' then
        ret = _FindResource(name, _toResType(resType))
    end
    return ret
end

---FindResTexture
---@param name string
---@return lstg.ResTexture
function FindResTexture(name)
    return _FindResource(name, 1)
end
---FindResSprite
---@param name string
---@return lstg.ResSprite
function FindResSprite(name)
    return _FindResource(name, 2)
end
---FindResAnimation
---@param name string
---@return lstg.ResAnimation
function FindResAnimation(name)
    return _FindResource(name, 3)
end
---FindResMusic
---@param name string
---@return lstg.ResMusic
function FindResMusic(name)
    return _FindResource(name, 4)
end
---FindResSound
---@param name string
---@return lstg.ResSound
function FindResSound(name)
    return _FindResource(name, 5)
end
---FindResParticle
---@param name string
---@return lstg.ResParticle
function FindResParticle(name)
    return _FindResource(name, 6)
end
---FindResFont
---@param name string
---@return lstg.ResFont
function FindResFont(name)
    return _FindResource(name, 7)
end
---FindResFX
---@param name string
---@return lstg.ResFX
function FindResFX(name)
    return _FindResource(name, 8)
end
---FindResRenderTarget
---@param name string
---@return lstg.ResRenderTarget
function FindResRenderTarget(name)
    if name == _temp_rt then
        return _FindResource(name, 9) or CreateRenderTarget(name)
    end
    return _FindResource(name, 9)
end
---FindResVideo
---param name string
---return lstg.ResVideo
--function FindResVideo(name)
--    return FindResource(name, ResourceType.Video)
--end

---@param name string
---@return cc.Texture2D
function FindTexture2D(name)
    local tex = FindResTexture(name)
    if tex then
        return tex:getTexture()
    end
    local rt = FindResRenderTarget(name)
    if rt then
        return rt:getTexture()
    end
end

local FindResSprite = FindResSprite
local FindResAnimation = FindResAnimation
local FindResParticle = FindResParticle
local FindResFont = FindResFont
local FindResTexture = FindResTexture

--- used by engine
function FindResForObject(name)
    local res = FindResSprite(name)
    if not res then
        res = res or FindResAnimation(name)
        res = res or FindResParticle(name)
        res = res or FindResFont(name)
        res = res or FindResTexture(name)
    end
    return res
end

