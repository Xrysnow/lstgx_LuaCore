--
local Base = require('cc.ui.ImagePicker')

---@class editor.EnemyStyleEnumPicker:ui.ImagePicker
local M = class('editor.EnemyStyleEnumPicker', Base)
local path = 'editor/images/enemy/'

function M:ctor(init_val, onConfirm)
    local enum = require('editor.enum_type').selectenemystyle
    if type(init_val) == 'string' then
        init_val = table.indexof(enum, init_val)
    end
    init_val = init_val or 1
    assert(type(init_val) == 'number')
    local images = {}
    for i = 1, 34 do
        images[i] = string.format('%senemy%d.png', path, i)
    end
    Base.ctor(self, 'Select Enemy Style', images, cc.size(64, 64), 4, init_val, onConfirm)
end

function M.show(prop_idx, node)
    local panel = require('editor.main').getPropertyPanel()
    local di = M()
    di:setOnConfirm(function()
        panel:setValue(prop_idx, tostring(di:getIndex()))
        require('editor.TreeMgr').SubmitAttr()
    end)
end

return M
