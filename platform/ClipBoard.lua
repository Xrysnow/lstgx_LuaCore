--
local M = {}
local w = lstg.WindowHelper:getInstance()
local last_set = ''

function M.set(s)
    if not s then
        w:setClipboardString('')
        last_set = ''
        return
    end
    assert(type(s) == 'string')
    last_set = s
    w:setClipboardString(s)
end

function M.get()
    --TODO
    if plus.isMobile() then
        return last_set
    end
    return w:getClipboardString()
end

function M.getLastSet()
    return last_set
end

return M
