--
local M = {}

function M.checkExp(str)
    str = '_=\n' .. str
    local f, msg = loadstring(str, '')
    if not f then
        msg = msg:gsub([[%[string ""%]:2: ]], '')
        msg = msg:gsub([[%[string ""%]:]], '')
        return false, msg
    end
    return true
end

function M.splitParam(s)
    if string.match(s, "^[%s]*$") then
        return {}
    end
    local pos = { 0 }
    local ret = {}
    local b1 = 0
    local b2 = 0
    for i = 1, #s do
        local c = string.byte(s, i)
        if b1 == 0 and b2 == 0 and c == 44 then
            table.insert(pos, i)
        elseif c == 40 then
            b1 = b1 + 1
        elseif c == 41 then
            b1 = b1 - 1
        elseif c == 123 then
            b2 = b2 + 1
        elseif c == 125 then
            b2 = b2 - 1
        end
    end
    table.insert(pos, #s + 1)
    for i = 1, #pos - 1 do
        local str = s:sub(pos[i] + 1, pos[i + 1] - 1)
        str = string.trim(str)
        table.insert(ret, str)
    end
    return ret
end

local _keyword = {
    'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
    'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
    'return', 'then', 'true', 'until', 'while', 'goto'
}
for k, v in pairs(_keyword) do
    _keyword[v] = true
end
local punctuation = [[%!%"%#%$%%%&%'%(%)%*%+%,%-%.%/%:%;%<%=%>%?%@%[%\%]%^%`%{%|%}%~]]

function M.checkIdentifier(s)
    s = string.trim(s)
    if _keyword[s] then
        return false
    end
    if s:match('^[0-9]') then
        return false
    end
    if s:match('[ \t\n\r\v\f]') then
        return false
    end
    if s:match('[' .. punctuation .. ']') then
        return false
    end
    return true
end

return M
