--

---@type lstg.ResTexture
local M = lstg.ResTexture

local _filter = {}
for _, v in ipairs({ 'LINEAR', 'NEAREST' }) do
    _filter[v] = gl[v]
    _filter[string.lower(v)] = gl[v]
    _filter[gl[v]] = gl[v]
end
local _wrap = {}
for _, v in ipairs({ 'REPEAT', 'MIRRORED_REPEAT', 'CLAMP_TO_EDGE' }) do
    _wrap[v] = gl[v]
    _wrap[string.lower(v)] = gl[v]
    _wrap[gl[v]] = gl[v]
end

local function _is_POT(n)
    return (math.log(n) / math.log(2)) % 1 == 0
end

--- see [Filtering](http://www.glprogramming.com/red/chapter09.html#name3) and [Repeating and Clamping Textures](http://www.glprogramming.com/red/chapter09.html#name11)
---@param minFilter number
---@param magFilter number @gl.LINEAR gl.NEAREST
---@param wrapS number
---@param wrapT number @gl.REPEAT gl.MIRRORED_REPEAT gl.CLAMP_TO_EDGE
function M:setTexParameters(minFilter, magFilter, wrapS, wrapT)
    minFilter = assert(_filter[minFilter])
    magFilter = assert(_filter[magFilter])
    wrapS = assert(_wrap[wrapS])
    wrapT = assert(_wrap[wrapT])
    local tex = self:getTexture()
    local sz = tex:getContentSizeInPixels()
    if not _is_POT(sz.width) or not _is_POT(sz.height) then
        Print(string.format('[WARN] [setTexParameters] texture of %q is NOPT (%d, %d), wrap parameter may not take effect', self:getName(), sz.width, sz.height))
    end
    tex:setTexParameters(minFilter, magFilter, wrapS, wrapT)
end

---setWrap
---@param wrap string|number
function M:setWrap(wrap)
    local tex = self:getTexture()
    local sz = tex:getContentSizeInPixels()
    if not _is_POT(sz.width) or not _is_POT(sz.height) then
        Print(string.format('[WARN] [setTexParameters] texture of %q is NOPT (%d, %d), wrap parameter may not take effect', self:getName(), sz.width, sz.height))
    end
    tex:setTexParameters(gl.LINEAR, gl.LINEAR, assert(_wrap[wrap]), assert(_wrap[wrap]))
end
