---
local M = {}

local code = cc.Application:getInstance():getCurrentLanguageCode()
M._code = code
local f = string.format('i18n/%s/__init__.lua', code)
if cc.FileUtils:getInstance():isFileExist(f) then
    M._super = require(string.format('i18n.%s', code))
end

local function call(t, arg1, ...)
    local ty = type(arg1)
    if ty == 'string' then
        return M.string(arg1, ...)
    elseif ty == 'table' then
        local narg = select('#', ...)
        local ret = arg1[M._code]
        if ret == nil then
            ret = arg1.default or arg1.en
        end
        local ty1 = type(ret)
        if ty1 == 'string' then
            if narg > 0 then
                return ret:format(...)
            else
                return ret
            end
        elseif ty1 == 'function' then
            return ret(...)
        end
    elseif ty == 'function' then
        return arg1(M._code, ...)
    elseif ty == 'nil' then
        return nil
    end
end

setmetatable(M, {
    __call = call
})

---@param str string
---@return string
function M.string(str, ...)
    local s
    if M._super then
        s = M._super.string(str)
    else
        s = str
    end
    if select('#', ...) > 0 then
        s = s:format(...)
    end
    return s
end

return M
