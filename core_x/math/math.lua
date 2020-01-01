---
--- math.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

--local math = math
local pi = math.pi
local pix2 = math.pi * 2
local abs = math.abs
local acos = math.acos
local asin = math.asin
local atan = math.atan
local atan2 = math.atan2
local ceil = math.ceil
local cos = math.cos
local cosh = math.cosh
local deg = math.deg
local exp = math.exp
local floor = math.floor
local fmod = math.fmod
local frexp = math.frexp
local ldexp = math.ldexp
local log = math.log
local log10 = math.log10
local max = math.max
local min = math.min
local modf = math.modf
local pow = math.pow
local rad = math.rad
local random = math.random
local randomseed = math.randomseed
local sin = math.sin
local sinh = math.sinh
local sqrt = math.sqrt
local tan = math.tan
local tanh = math.tanh

---@param v number
---@return number
function math.cbrt(v)
    return pow(v, 1 / 3)
end

---@param v number
---@param lo number
---@param hi number
---@return number
function math.clamp(v, lo, hi)
    --if v < min then
    --    return min
    --elseif v > max then
    --    return max
    --else
    --    return v
    --end
    return min(hi, max(v, lo))
end

---@param v1 number
---@param v2 number
---@return number
function math.hypot(v1, v2)
    return sqrt(v1 * v1 + v2 * v2)
end

---@param v1 number
---@param v2 number
---@param a number
---@return number
function math.lerp(v1, v2, a)
    return v1 + (v2 - v1) * a
end

---C++ std::remainder
---C# Math.IEEERemainder
---@param v1 number
---@param v2 number
---@return number
function math.remainder(v1, v2)
    return v1 - v2 * math.round(v1 / v2)
end

---@param v number
---@return number
function math.round(v)
    local f, c = floor(v), ceil(v)
    if v - f < c - v then
        return f
    else
        return c
    end
end

---@param v number
---@return number
function math.sign(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end

--- solve:
--- a1 x + b1 y = c1
--- a2 x + b2 y = c2
---@return number,number,boolean
function math.solveLiner(a1, b1, c1, a2, b2, c2)
    local den = a2 * b1 - a1 * b2
    return (c2 * b1 - c1 * b2) / den, (c1 * a2 - c2 * a1) / den, den == 0
end

--------------------------------------------------
-- from Microsoft.Xna.Framework.MathHelper
--------------------------------------------------

---C# MathHelper.Barycentric
---@param v1 number
---@param v2 number
---@param v3 number
---@param a1 number
---@param a2 number
---@return number
function math.barycentric(v1, v2, v3, a1, a2)
    return (v1 + (a1 * (v2 - v1))) + (a2 * (v3 - v1))
end

---C# MathHelper.SmoothStep
---@param v1 number
---@param v2 number
---@param a number
---@return number
function math.smoothstep(v1, v2, a)
    a = math.clamp(a, 0, 1)
    return math.lerp(v1, v2, a * a * (3 - 2 * a))
end

---C# MathHelper.WrapAngle
---@return number
---@param v number
function math.wrapangle(v)
    local a = math.remainder(v, pix2)
    if a <= -pi then
        return a + pix2
    elseif a > pi then
        return a - pix2
    else
        return a
    end
end

--------------------------------------------------
-- metrics
--------------------------------------------------

function math.EuclideanDistance(v1, v2)
    local sum = 0
    for i = 1, #v1 do
        local d = v1[i] - v2[i]
        sum = sum + d * d
    end
    return sqrt(sum)
end

function math.ManhattanDistance(v1, v2)
    local sum = 0
    for i = 1, #v1 do
        sum = sum + abs(v1[i] - v2[i])
    end
    return sum
end

function math.ChebyshevDistance(v1, v2)
    local ret = 0
    for i = 1, #v1 do
        local d = abs(v1[i] - v2[i])
        if d > ret then
            ret = d
        end
    end
    return ret
end

function math.MinkowskiDistance(v1, v2, p)
    local sum = 0
    for i = 1, #v1 do
        sum = sum + pow(abs(v1[i] - v2[i]), p)
    end
    return pow(sum, 1 / p)
end

--------------------------------------------------
-- special number
--------------------------------------------------

local inf = 1 / 0
local ninf = -1 / 0

--TODO: cdata float

--- v == +/-inf
function math.isinf(v)
    return v == inf or v == ninf
end

--- v is not positive infinity, negative infinity, or NaN
function math.isfinite(v)
    return v ~= inf and v ~= ninf and v == v
end

function math.isnan(v)
    return v ~= v
end

