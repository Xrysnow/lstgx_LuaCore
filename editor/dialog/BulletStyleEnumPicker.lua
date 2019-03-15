--
local Base = require('ui.ImagePicker')

---@class editor.BulletStyleEnumPicker:ui.ImagePicker
local M = class('editor.BulletStyleEnumPicker', Base)
local path = 'editor/images/bullet/'

function M:ctor(init_val, onConfirm)
    local enum = require('editor.enum_type').bulletshow
    if type(init_val) == 'string' then
        init_val = table.indexof(enum, init_val)
    end
    init_val = init_val or 1
    assert(type(init_val) == 'number')
    local images = {}
    for i, v in ipairs(enum) do
        images[i] = path .. v .. '.png'
    end
    Base.ctor(self, 'Select Bullet Style', images, cc.size(64, 64), 4, init_val, onConfirm)
end

function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local di = M()
    di:setOnConfirm(function()
        panel:setValue(prop_idx, di:getIndex())
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
