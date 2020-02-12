--

local function init()
    local code = cc.Application:getInstance():getCurrentLanguageCode()
    local f = string.format('i18n/%s/__init__.lua', code)
    if cc.FileUtils:getInstance():isFileExist(f) then
        return require(string.format('i18n.%s', code))
    end
end

---@class i18n
local M = { _super = init() }

setmetatable(M, {
    __call = function(t, ...)
        return M.string(...)
    end
})

---@param str string
---@return string
function M.string(str)
    if M._super then
        return M._super.string(str)
    else
        return str
    end
end

return M
