--
local M = {}
local im = imgui
local wi = require('imgui.Widget')

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

---@param sp cc.Sprite
function M.createButton(sp, padding)
    padding = padding or 4
    local sz = sp:getContentSize()
    local btn = require('imgui.widgets.ImageButton')(sp)
    btn:setContentSize(sz):setFramePadding(padding)

    local node = cc.Node()
    local delta = padding * 2 - 2
    node:setContentSize(cc.size(sz.width + delta, sz.height + delta))
    local tint = im.vec4(1, 1, 1, 1)
    local btn_disable = wi.Widget(function()
        im.ccNode(node, tint, im.getStyleColorVec4(im.Col.Border))
    end)
    btn_disable:setVisible(false)
    node:addTo(btn_disable):setVisible(false)
    sp:addTo(node):setPosition(sz.width / 2 + padding - 1, sz.height / 2 + padding - 1)

    local program = ccb.Program:getBuiltinProgram(15)
    assert(program)
    sp:setProgramState(ccb.ProgramState(program))
    sp:setBlendFunc({ src = ccb.BlendFactor.SRC_ALPHA, dst = ccb.BlendFactor.ONE_MINUS_SRC_ALPHA })

    return btn, btn_disable
end

function M.createTextButton(str, padding, cb, color)
    local vars = {
        [im.StyleVar.FramePadding] = padding,
    }
    local colors1 = {
        [im.Col.Text] = color,
    }
    local style1 = wi.style(colors1, vars)
    local btn = wi.Button(str)
    btn:addTo(style1)
    if cb then
        btn:setOnClick(cb)
    end

    local colors2 = {
        [im.Col.Button]        = im.vec4(0, 0, 0, 0),
        [im.Col.ButtonActive]  = im.vec4(0, 0, 0, 0),
        [im.Col.ButtonHovered] = im.vec4(0, 0, 0, 0),
        [im.Col.Text]          = function()
            return im.getStyleColorVec4(im.Col.TextDisabled)
        end,
    }
    local style2 = wi.style(colors2, vars)
    style2:setVisible(false)
    local btn2 = wi.Button(str)
    btn2:addTo(style2)

    return style1, style2
end

return M
