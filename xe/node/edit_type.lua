--
local M = {}

M.any = {
}
M.audio_pan = {
}
M.bgstage = {
    'bgstage'
}
M.blend = {
    'blend'
}
M.bool = {
    'bool'
}
M.bulletstyle = {
    'bullet_style'
}
M.color = {
    'color_enum',
    --'color',
}
M.difficulty = {
    -- enum
}
M.directmode = {
    -- enum
}
M.event = {
    -- only used in callbackfunc
}
M.gop = {
    -- game object property
}
M.group = {
    'group'
}
M.image = {
    'image'
}
M.item = {
    -- used in dropitem
    'item'
}
M.layer = {
}
M.leftright = {
    -- enum
}
M.movetomode = {
}
M.number = {
    'number'
}
M.param = {
    'param'
}
M.pos = {
    'vec2',
    'const',
    const = { { 'follow', "self.x, self.y" } }
}
M.resfile = {
    'path',
    loadsound    = { "wav", "ogg" },
    loadbgm      = { "wav", "ogg" },
    loadimage    = { "png", "jpg", "bmp" },
    loadani      = { "png", "jpg", "bmp" },
    bossdefine   = { "png", "jpg", "bmp" },
    loadparticle = "psi",
    patch        = "lua",
    loadFX       = { "fx", "vert", "frag" },
}
M.selectenemystyle = {
    'enemy_style'
}
M.selecttype = {
    'type_name'
}
M.sound = {
    'sound_effect'
}
M.stagegroup = {
    'stagegroup'
}
M.string = {
}
M.typename = {
    -- define an editor class
}
M.vec2 = {
    'vec2'
}

local enum = require('xe.node.enum_type')
for k, v in pairs(M) do
    if enum[k] then
        table.insert(v, 'enum')
        v.enum = enum[k]
    end
    table.insert(v, 'string')
end

return M
