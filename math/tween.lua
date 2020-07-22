---
--- tween.lua
---
--- Copyright (C) 2018-2020 Xrysnow. All rights reserved.
---

local math = math

-- t: current step
-- b: begin
-- c: total delta
-- d: total step
--
---@class math.tween
local M = {}

function M.linear(t, b, c, d)
    d = d or 1
    return c * t / d + b
end

function M.quadIn(t, b, c, d)
    d = d or 1
    t = t / d
    return c * t * t + b
end
function M.quadOut(t, b, c, d)
    d = d or 1
    t = t / d
    return -c * t * (t - 2) + b
end
function M.quadInOut(t, b, c, d)
    d = d or 1
    t = t / (d / 2)
    if (t < 1) then
        return c / 2 * t * t + b
    end
    t = t - 1
    return -c / 2 * (t * (t - 2) - 1) + b
end

function M.cubicIn(t, b, c, d)
    d = d or 1
    t = t / d
    return c * t * t * t + b
end
function M.cubicOut(t, b, c, d)
    d = d or 1
    t = t / d - 1
    return c * (t * t * t + 1) + b
end
function M.cubicInOut(t, b, c, d)
    d = d or 1
    t = t / (d / 2)
    if (t < 1) then
        return c / 2 * t * t * t + b
    end
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
end

function M.quartIn(t, b, c, d)
    d = d or 1
    t = t / d
    return c * t * t * t * t + b
end
function M.quartOut(t, b, c, d)
    d = d or 1
    t = t / d - 1
    return -c * (t * t * t * t - 1) + b
end
function M.quartInOut(t, b, c, d)
    d = d or 1
    t = t / (d / 2)
    if (t < 1) then
        return c / 2 * t * t * t * t + b
    end
    t = t - 2
    return -c / 2 * (t * t * t * t - 2) + b
end

function M.quintIn(t, b, c, d)
    d = d or 1
    t = t / d
    return c * t * t * t * t * t + b
end
function M.quintOut(t, b, c, d)
    d = d or 1
    t = t / d - 1
    return c * (t * t * t * t * t + 1) + b
end
function M.quintInOut(t, b, c, d)
    d = d or 1
    t = t / (d / 2)
    if (t < 1) then
        return c / 2 * t * t * t * t * t + b
    end
    t = t - 2
    return c / 2 * (t * t * t * t * t + 2) + b
end

function M.sineIn(t, b, c, d)
    d = d or 1
    return -c * math.cos(t / d * (math.pi / 2)) + c + b
end
function M.sineOut(t, b, c, d)
    d = d or 1
    return c * math.sin(t / d * (math.pi / 2)) + b
end
function M.sineInOut(t, b, c, d)
    d = d or 1
    return -c / 2 * (math.cos(math.pi * t / d) - 1) + b
end

function M.expoIn(t, b, c, d)
    d = d or 1
    if t == 0 then
        return b
    else
        return c * math.pow(2, 10 * (t / d - 1)) + b
    end
end
function M.expoOut(t, b, c, d)
    d = d or 1
    if t == d then
        return b + c
    else
        return c * (-math.pow(2, -10 * t / d) + 1) + b
    end
end
function M.expoInOut(t, b, c, d)
    d = d or 1
    if (t == 0) then
        return b
    end
    if (t == d) then
        return b + c
    end
    t = t / (d / 2)
    if (t < 1) then
        return c / 2 * math.pow(2, 10 * (t - 1)) + b
    end
    t = t - 1
    return c / 2 * (-math.pow(2, -10 * t) + 2) + b
end

function M.circIn(t, b, c, d)
    d = d or 1
    t = t / d
    return -c * (math.sqrt(1 - t * t) - 1) + b
end
function M.circOut(t, b, c, d)
    d = d or 1
    t = t / d - 1
    return c * math.sqrt(1 - t * t) + b
end
function M.circInOut(t, b, c, d)
    d = d or 1
    t = t / (d / 2)
    if (t < 1) then
        return -c / 2 * (math.sqrt(1 - t * t) - 1) + b
    end
    t = t - 2
    return c / 2 * (math.sqrt(1 - t * t) + 1) + b
end

function M.elasticIn(t, b, c, d, a, p)
    d = d or 1
    if (t == 0) then
        return b
    end
    t = t / d
    if (t == 1) then
        return b + c
    end
    if not p then
        p = d * .3
    end
    local s
    if not a or a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end
    t = t - 1
    return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end
function M.elasticOut(t, b, c, d, a, p)
    d = d or 1
    if (t == 0) then
        return b
    end
    t = t / d
    if (t == 1) then
        return b + c
    end
    if not p then
        p = d * .3
    end
    local s
    if (not a or a < math.abs(c)) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end
    return (a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b)
end
function M.elasticInOut(t, b, c, d, a, p)
    d = d or 1
    if (t == 0) then
        return b
    end
    t = t / (d / 2)
    if (t == 2) then
        return b + c
    end
    if not p then
        p = d * (.3 * 1.5)
    end
    local s
    if (not a or a < math.abs(c)) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end
    if (t < 1) then
        t = t - 1
        return -.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
    end
    t = t - 1
    return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) * .5 + c + b
end

function M.backIn(t, b, c, d, s)
    d = d or 1
    s = s or 1.70158
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
end
function M.backOut(t, b, c, d, s)
    d = d or 1
    s = s or 1.70158
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end
function M.backInOut(t, b, c, d, s)
    d = d or 1
    s = s or 1.70158
    t = t / (d / 2)
    if t < 1 then
        s = s * 1.525
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    end
    t = t - 2
    s = s * 1.525
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

function M.bounceIn(t, b, c, d)
    d = d or 1
    return c - M.bounceOut(d - t, 0, c, d) + b
end
function M.bounceOut(t, b, c, d)
    d = d or 1
    t = t / d
    if (t < (1 / 2.75)) then
        return c * (7.5625 * t * t) + b
    elseif (t < (2 / 2.75)) then
        t = t - 1.5 / 2.75
        return c * (7.5625 * t * t + .75) + b
    elseif (t < (2.5 / 2.75)) then
        t = t - 2.25 / 2.75
        return c * (7.5625 * t * t + .9375) + b
    else
        t = t - 2.625 / 2.75
        return c * (7.5625 * t * t + .984375) + b
    end
end
function M.bounceInOut(t, b, c, d)
    d = d or 1
    if (t < d / 2) then
        return M.bounceIn(t * 2, 0, c, d) * .5 + b
    else
        return M.bounceOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b
    end
end

return M
