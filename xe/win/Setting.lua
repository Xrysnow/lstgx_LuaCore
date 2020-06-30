local base = require('imgui.Widget')
---@class xe.Setting:im.Widget
local M = class('xe.Setting', base)
local im = imgui
local wi = base

function M:ctor()
    base.ctor(self)
    self._setting = setting.xe
    self:_set()

    self._timer = 1
    self:scheduleUpdateWithPriorityLua(std.bind(self._update, self), 1)
    --
    self:push()
    self:addChild(function()
        local sz = im.vec2(-1, -im.getFrameHeightWithSpacing())
        if im.beginChildFrame(im.getID('xe.setting.content'), sz) then
            local ret
            local tmp = self._tmp
            ret, tmp.cheat = im.checkbox('Cheat', tmp.cheat)

            im.separator()

            im.textWrapped('Editor tree padding')
            ret, tmp.editor_tree_padding = im.sliderInt(
                    '##', tmp.editor_tree_padding or 0, 0, 8)

            im.separator()

            im.endChildFrame()
        end
    end)

    local ok = wi.Button('OK', std.bind(self._ok, self))
    local cancel = wi.Button('Cancel', std.bind(self._cancel, self))
    self:addChildren(ok, im.sameLine, cancel)
end

function M:_ok()
    self:pop()
    self:setVisible(false)
end

function M:_cancel()
    self:setVisible(false)
end

function M:push()
    -- push temp values
    self._tmp = table.clone(self._setting)
end

function M:pop()
    -- pop temp values
    for k, v in pairs(self._tmp) do
        self._setting[k] = v
    end
end

function M:_set()
    local setting = self._setting
    local glv = cc.Director:getInstance():getOpenGLView()
    local fsz = setting.frame_size
    if fsz then
        glv:setFrameSize(fsz[1], fsz[2])
    end
end

function M:_update()
    local t = self._timer + 1
    if t > 3600 then
        self._timer = 1
        t = 1
    else
        self._timer = t
    end
    if t % 30 == 0 then
        local s = self._setting
        local glv = cc.Director:getInstance():getOpenGLView()
        local fsz = glv:getFrameSize()
        s.frame_size = { fsz.width, fsz.height }
        setting.windowsize_w = fsz.width
        setting.windowsize_h = fsz.height

        lstg.saveSettingFile()
    end
end

local _id = 'Setting'
function M:_handler()
    im.setNextWindowSize(im.vec2(300, 300), im.Cond.Once)
    im.openPopup(_id)
    if im.beginPopupModal(_id) then
        wi._handler(self)
        im.endPopup()
    end
end

local function get_ins()
    return require('xe.main'):getInstance()._setting
end

function M:show()
    if self == nil or self == M then
        self = get_ins()
    end
    self:push()
    self:setVisible(true)
    return self
end

function M.setVar(k, v)
    local ins = get_ins()
    ins._setting[k] = v
end

function M.getVar(k)
    local ins = get_ins()
    return ins._setting[k]
end

function M.save()
    local path = require('xe.Project').getDir()
    if not path then
        return
    end
    --TODO: save to json
    local ins = get_ins()
end

return M
