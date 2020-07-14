---
--- xclass.lua
---
--- Copyright (C) 2018-2020 Xrysnow. All rights reserved.
---


local New = lstg.New

---Extends [Class] function so that you can use ClassName(...) to create an instance of lstg object.
---Example: `classname = xclass(object)`
---@see object
---@param base object
---@param define table
---@return object
function xclass(base, define)
    local ret = Class(base, define)
    ret['.x'] = true
    if base and base['.3d'] then
        ret['.3d'] = true
    end
    local mt = { __call = function(t, ...)
        local obj = New(ret, ...)
        table.supplement(obj, ret)
        return obj
    end }
    return setmetatable(ret, mt)
end

