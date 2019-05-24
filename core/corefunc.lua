local forward = require('forward')
forward.forward('LoadFont')
forward.forward('SetResourceStatus')

local profiler = profiler
local e = lstg.eventDispatcher

function BeforeRender()
    lstg.forceSetViewMode('ui')
    --TODO: fix this
    for k, _ in pairs(forward.Fonts) do
        RenderText(k, '', 0, 0)
    end
    e:dispatchEvent('onBeforeRender')
end

function AfterRender()
    e:dispatchEvent('onAfterRender')
end

local abs = abs
local cos = cos
local sin = sin
local hypot = hypot
local pairs = pairs
local rawget = rawget
local rawset = rawset

local ot = ObjTable()

function UserSystemOperation()
    --assistance of Polar coordinate system
    local polar--, radius, angle, delta, omiga, center
    --acceleration and gravity
    local alist--, accelx, accely, gravity
    --limitation of velocity
    local forbid--, vx, vy, v, ovx, ovy, cache
    --
    for i = 1, 32768 do
        local obj = ot[i]
        if obj then
            polar = rawget(obj, 'polar')
            if polar then
                local radius = polar.radius or 0
                local angle = polar.angle or 0
                local delta = polar.delta
                if delta then
                    polar.radius = radius + delta
                end
                local omiga = polar.omiga
                if omiga then
                    polar.angle = angle + omiga
                end
                local center = polar.center or { x = 0, y = 0 }
                radius = polar.radius
                angle = polar.angle
                obj.x = center.x + radius * cos(angle)
                obj.y = center.y + radius * sin(angle)
            end
            alist = rawget(obj, 'acceleration')
            if alist then
                local accelx = alist.ax
                if accelx then
                    obj.vx = obj.vx + accelx
                end
                local accely = alist.ay
                if accely then
                    obj.vy = obj.vy + accely
                end
                local gravity = alist.g
                if gravity then
                    obj.vy = obj.vy - gravity
                end
            end
            forbid = rawget(obj, 'forbidveloc')
            if forbid then
                local ovx = obj.vx
                local ovy = obj.vy
                local v = forbid.v
                if v and (v * v) < (ovx * ovx + ovy * ovy) then
                    local cache = v / hypot(ovx, ovy)
                    obj.vx = cache * ovx
                    obj.vy = cache * ovy
                    ovx = obj.vx
                    ovy = obj.vy
                end
                local vx = forbid.vx
                local vy = forbid.vy
                if vx and vx < abs(ovx) then
                    obj.vx = vx
                end
                if vy and vy < abs(ovy) then
                    obj.vy = vy
                end
            end
        end
    end
    --rebounder
    if not rebounder then
        return
    end
    if not ReboundPause and rebounder.size ~= 0 then
        for _, obj in ObjList(GROUP_ENEMY_BULLET) do
            if IsValid(obj) and obj.colli and (obj.vx ~= 0 or obj.vy ~= 0) then
                local accel, ax, ay = obj.acceleration, 0, 0
                if accel then
                    ax, ay = accel.ax, accel.ay
                end
                local result = { rebounding.ReboundCheck(obj.x, obj.y, obj.vx, obj.vy, ax, ay) }
                if result[1] then
                    obj.x, obj.y, obj.vx, obj.vy = unpack(result, 1, 4)
                    if accel then
                        accel.ax, accel.ay = result[5], result[6]
                    end
                    for i = 7, #result do
                        local self = rebounder.list[result[i]]
                        self.class.colli(self, obj)
                    end
                end
            end
        end
        for _, obj in ObjList(GROUP_INDES) do
            if IsValid(obj) and obj.colli and (obj.vx ~= 0 or obj.vy ~= 0) then
                local accel, ax, ay = obj.acceleration, 0, 0
                if accel then
                    ax, ay = accel.ax, accel.ay
                end
                local result = { rebounding.ReboundCheck(obj.x, obj.y, obj.vx, obj.vy, ax, ay) }
                if result[1] then
                    obj.x, obj.y, obj.vx, obj.vy = unpack(result, 1, 4)
                    if accel then
                        accel.ax, accel.ay = result[5], result[6]
                    end
                    for i = 7, #result do
                        local self = rebounder.list[result[i]]
                        self.class.colli(self, obj)
                    end
                end
            end
        end
    end
end

--local jit = require('jit')
--local ffi = ffi or require('ffi')
--local ptr_t = ffi.typeof('uint32_t*')
--local ObjOnFrame = ObjOnFrame
--local ii = 0

function DoFrame()
    --SetTitle(setting.mod .. ' | FPS=' .. GetFPS() .. ' | Nobj=' .. GetnObj())
    UpdateObjList()
    GetInput()
    --next_stage顶替current_stage
    if stage.next_stage then

        -- from ex
        if lstg.var.ran_seed then
            ran:Seed(lstg.var.ran_seed)
        end

        stage.current_stage = stage.next_stage
        stage.next_stage = nil
        stage.current_stage.timer = 0
        stage.current_stage:init()
    end
    if stage.current_stage then
        task.Do(stage.current_stage)
        if stage.current_stage then
            stage.current_stage:frame()
            stage.current_stage.timer = stage.current_stage.timer + 1
        end
    end

    profiler.tic('ObjFrame')
    ObjFrame()--LPOOL.DoFrame() 执行对象的Frame函数
    profiler.toc('ObjFrame')

    profiler.tic('UserSystemOperation')
    UserSystemOperation()  --用于lua层模拟内核级操作
    profiler.toc('UserSystemOperation')

    BoundCheck()--执行边界检查

    profiler.tic('CollisionCheck')
    --碰撞检查
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY_BULLET)
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY)
    CollisionCheck(GROUP_PLAYER, GROUP_INDES)
    CollisionCheck(GROUP_ENEMY, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_NONTJT, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_ITEM, GROUP_PLAYER)
    profiler.toc('CollisionCheck')

    profiler.tic('UpdateXY')
    UpdateXY()--更新对象的XY坐标偏移量
    profiler.toc('UpdateXY')

    profiler.tic('AfterFrame')
    AfterFrame()--帧末更新函数
    profiler.toc('AfterFrame')

    --next_stage顶替current_stage
    if stage.next_stage and stage.current_stage then
        stage.current_stage:del()
        task.Clear(stage.current_stage)
        if stage.preserve_res then
            stage.preserve_res = nil
        else
            RemoveResource 'stage'--清空场景资源池
            SystemLog(i18n 'clear stage resource pool')
        end
        --LPOOL.ResetPool 清空对象池
        ResetPool()
        SystemLog(i18n 'clear object pool')

        --LDEBUG()
    end
end

function RenderFunc()
    e:dispatchEvent('onRenderFunc')
end
e:addListener('onRenderFunc', function()
    local stage = stage
    if not stage.current_stage then
        return
    end
    if stage.current_stage.timer and stage.current_stage.timer > 1 and stage.next_stage == nil then
        BeginScene()

        BeforeRender()

        --profiler.tic('stagerender')
        stage.current_stage:render()
        --profiler.toc('stagerender')

        profiler.tic('ObjRender')
        ObjRender()
        profiler.toc('ObjRender')

        --profiler.tic('AfterRender')
        AfterRender()
        --profiler.toc('AfterRender')

        --profiler.tic('EndScene')
        e:dispatchEvent('beforeEndScene')
        EndScene()
        e:dispatchEvent('afterEndScene')
        --profiler.toc('EndScene')
    end
end, 0)

----------------------------------------------------------------------

function FrameFunc()
    e:dispatchEvent('onFrameFunc')
    return lstg.quit_flag
end

e:addListener('onFrameFunc', function()
    if GetLastKey() == setting.keysys.snapshot and setting.allowsnapshot then
        Screenshot()
    end
end, -1, 'Screenshot')

e:addListener('onFrameFunc', function()
    if lstg.quit_flag then
        GameExit()
    end
end, 9, 'GameExit')

e:addListener('onFrameFunc', function()
    if GetKeyState(KEY.CTRL) and GetLastKey() == KEY.R then
        lstg.included = {}
        lstg.current_script_path = { '' }
        lstg.eventDispatcher:removeAllListeners()
        for _, v in ipairs(
                {
                    'RenderFunc',
                    'FrameFunc',
                    'all_class',
                    'class_name',
                }) do
            _G[v] = nil
        end
        Print('=   FrameReset   =')
        FrameReset()
    end
end, 10, 'FrameReset')

----------------------------------------------------------------------

function FocusLoseFunc()
    e:dispatchEvent('onFocusLose')
end

function FocusGainFunc()
    e:dispatchEvent('onFocusGain')
end

---游戏初始化
function GameInit()
    SetViewMode 'ui'
    if stage.next_stage == nil then
        error(i18n 'Entrance stage not set')
    end
    SetResourceStatus 'stage'
end

local Director = cc.Director:getInstance()
function GameExit()
    --require('jit.p').stop()
    lstg.saveSettingFile()
    ex.OnExit()
    if plus and plus.isMobile() then
        Director:endToLua()
    else
        os.exit()
    end
end

--

function DrawCollider()
    local x, y = 0, 0
    DrawGroupCollider(GROUP_ENEMY_BULLET, Color(150, 163, 73, 164), x, y)
    DrawGroupCollider(GROUP_ENEMY, Color(150, 163, 73, 164), x, y)
    DrawGroupCollider(GROUP_INDES, Color(150, 163, 73, 20), x, y)
    DrawGroupCollider(GROUP_PLAYER, Color(100, 175, 15, 20), x, y)

    --DrawGroupCollider(GROUP_ITEM, Color(100, 175, 175, 175), x, y)
end

local show_collider = false

e:addListener('beforeEndScene', function()
    if KeyIsPressed('toggle_collider') then
        show_collider = not show_collider
    end
    if show_collider then
        DrawCollider()
    end
    SetViewMode('world')
end, 9)

--

function Screenshot()
    local path = 'snapshot/' .. os.date("!%Y-%m-%d-%H-%M-%S", os.time() + setting.timezone * 3600) .. '.png'
    lstg.Snapshot(path)
    SystemLog(string.format('%s: %s', i18n('save screenshot to'), path))
end

function BentLaserData()
    return lstg.GameObjectBentLaser:create()
end

--

local fu = cc.FileUtils:getInstance()
local glc = cc.GLProgramCache:getInstance()
local shader_path = "src/shader/"
local internalShaders = {
    add   = { "Common.vert", "ColorAdd.frag" },
    addF1 = { "Fog_Liner.vert", "ColorAdd_Fog.frag" },
    addF2 = { "Fog_Exp1.vert", "ColorAdd_Fog.frag" },
    addF3 = { "Fog_Exp2.vert", "ColorAdd_Fog.frag" },
    mul   = { "Common.vert", "ColorMulti.frag" },
    mulF1 = { "Fog_Liner.vert", "ColorMulti_Fog.frag" },
    mulF2 = { "Fog_Exp1.vert", "ColorMulti_Fog.frag" },
    mulF3 = { "Fog_Exp2.vert", "ColorMulti_Fog.frag" },
}
for k, v in pairs(internalShaders) do
    local glp = CreateGLProgramFromPath(shader_path .. v[1], shader_path .. v[2])
    glc:addGLProgram(glp, 'lstg.' .. k)
end

local internalBM = {
    ['add+add']   = { 'GL_FUNC_ADD', 'GL_SRC_ALPHA', 'GL_ONE' },
    ['add+alpha'] = { 'GL_FUNC_ADD', 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' },
    ['add+sub']   = { 'GL_FUNC_SUBTRACT', 'GL_SRC_ALPHA', 'GL_ONE' },
    ['add+rev']   = { 'GL_FUNC_REVERSE_SUBTRACT', 'GL_SRC_ALPHA', 'GL_ONE' },

    ['mul+add']   = { 'GL_FUNC_ADD', 'GL_SRC_ALPHA', 'GL_ONE' },
    ['mul+alpha'] = { 'GL_FUNC_ADD', 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' },
    ['mul+sub']   = { 'GL_FUNC_SUBTRACT', 'GL_SRC_ALPHA', 'GL_ONE' },
    ['mul+rev']   = { 'GL_FUNC_REVERSE_SUBTRACT', 'GL_SRC_ALPHA', 'GL_ONE' },

    ['']          = { 'GL_FUNC_ADD', 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' },
}
for k, v in pairs(internalBM) do
    local m = k:sub(1, 3)
    if m == '' then
        m = 'mul'
    end
    local bm = lstg.BlendMode:createByNames(k, v[1], v[2], v[3], 'lstg.' .. m)
    assert(bm, i18n 'failed to create BlendMode')
    for i = 1, 3 do
        local glp_name = string.format('lstg.%sF%d', m, i)
        local glp = glc:getGLProgram(glp_name)
        assert(glp, 'failed to get GLProgram ' .. glp_name)
        bm:setFogGLProgram(i, glp)
    end
end
lstg.BlendMode:getByName(''):setAsDefault()

function CreateBlendMode(name, blendEquation, blendFuncSrc, blendFuncDst, shaderName)
    local glProgram
    if not shaderName then
        glProgram = 'lstg.mul'
    else
        local res = FindResFX(shaderName)
        if res then
            local glp = res:getProgram()
            glProgram = tostring(glp)
            glc:addGLProgram(glp, glProgram)
        else
            glProgram = tostring(shaderName)
        end
    end
    local ret = lstg.BlendMode:createByNames(name, blendEquation, blendFuncSrc, blendFuncDst, glProgram)
    assert(ret, i18n 'failed to create BlendMode')
    return ret
end

local glp = CreateGLProgramFromPath(shader_path .. 'NormalTex.vert', shader_path .. 'NormalTex.frag')
if glp then
    glc:addGLProgram(glp, 'lstg.light')
else
    Print('failed to load NormalTex shader')
end

--

local _capture = {}

---
--- x,y,w,h are in ui coords
---@param obj object
---@param x number
---@param y number
---@param w number
---@param h number
function CaptureScreen(obj, x, y, w, h)
    x = x + screen.dx
    y = y + screen.dy
    local scale = screen.scale
    table.insert(_capture,
                 { obj, x * scale, y * scale, w * scale, h * scale })
end

e:addListener('afterEndScene', function()
    if #_capture > 0 then
        ---@type cc.RenderTexture
        local fb = CopyFrameBuffer()
        local sp = fb:getSprite()
        local sz = sp:getTextureRect()
        local hh = sz.height
        for _, v in ipairs(_capture) do
            local obj, x, y, w, h = unpack(v)
            local newsp = cc.Sprite:createWithTexture(
                    sp:getTexture(), cc.rect(x, hh - y - h, w, h), false)
            local r = lstg.ResSprite:createWithSprite(
                    string.format('::CAP:: %s', tostring(obj)), newsp, 0, 0, 0)
            obj.img = r
        end
        _capture = {}
    end
end, 1, 'CaptureScreen')
