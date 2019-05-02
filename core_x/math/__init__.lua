---
--- __init__.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

for _, n in ipairs({ 'math', 'math_const', 'math_types' }) do
    require('core_x.math.' .. n)
end

local vec2 = require('core_x.math.vec2')
local vec3 = require('core_x.math.vec3')
local vec4 = require('core_x.math.vec4')
local mat4 = require('core_x.math.mat4')
local quat = require('core_x.math.quaternion')

---@return math.vec2
function math.vec2(...)
    return vec2(...)
end

---@return math.vec3
function math.vec3(...)
    return vec3(...)
end

---@return math.vec4
function math.vec4(...)
    return vec4(...)
end

---@return math.mat4
function math.mat4(...)
    return mat4(...)
end

---@return math.quaternion
function math.quat(...)
    return quat(...)
end
