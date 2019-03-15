---@type lstg.BlendMode
local BlendMode = lstg.BlendMode

local _default

function BlendMode:setAsDefault()
    _default = self:getName()
    return self
end

---@return lstg.BlendMode
function BlendMode:getDefault()
    return BlendMode:getByName(_default)
end

