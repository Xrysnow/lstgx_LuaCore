--

---@type lstg.ResTexture
local M = lstg.ResTexture

local _filter = {}
for k, v in pairs(ccb.SamplerFilter) do
    _filter[k] = v
    _filter[k:lower()] = v
    _filter[v] = v
end
local _wrap = {}
for k, v in pairs(ccb.SamplerAddressMode) do
    _wrap[k] = v
    _wrap[k:lower()] = v
    _wrap[v] = v
end

local function _is_POT(n)
    return (math.log(n) / math.log(2)) % 1 == 0
end

--- see [Filtering](http://www.glprogramming.com/red/chapter09.html#name3)
--- and [Repeating and Clamping Textures](http://www.glprogramming.com/red/chapter09.html#name11)
---@param minFilter ccb.SamplerFilter|string
---@param magFilter ccb.SamplerFilter|string @'linear'/'nearest'
---@param wrapS ccb.SamplerAddressMode|string
---@param wrapT ccb.SamplerAddressMode|string @'repeat'/'mirrored_repeat'/'clamp_to_edge'
---@return lstg.ResTexture
function M:setTexParameters(minFilter, magFilter, wrapS, wrapT)
    minFilter = assert(_filter[minFilter])
    magFilter = assert(_filter[magFilter])
    wrapS = assert(_wrap[wrapS])
    wrapT = assert(_wrap[wrapT])
    local tex = self:getTexture()
    local sz = tex:getContentSizeInPixels()
    if not _is_POT(sz.width) or not _is_POT(sz.height) then
        Print(string.format(
                '[WARN] [setTexParameters] texture %q is NOPT (%d, %d), wrap parameter may not take effect',
                self:getName(), sz.width, sz.height))
    end
    tex:setTexParameters(minFilter, magFilter, wrapS, wrapT)
    return self
end

---
---@param wrap ccb.SamplerAddressMode|number
---@return lstg.ResTexture
function M:setWrap(wrap)
    local tex = self:getTexture()
    local sz = tex:getContentSizeInPixels()
    if not _is_POT(sz.width) or not _is_POT(sz.height) then
        Print(string.format(
                '[WARN] [setTexParameters] texture %q is NOPT (%d, %d), wrap parameter may not take effect',
                self:getName(), sz.width, sz.height))
    end
    tex:setTexParameters(ccb.SamplerFilter.LINEAR, ccb.SamplerFilter.LINEAR, assert(_wrap[wrap]), assert(_wrap[wrap]))
    return self
end
