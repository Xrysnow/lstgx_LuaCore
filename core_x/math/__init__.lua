---
--- __init__.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

for _, n in ipairs({ 'math', 'math_const', 'math_types' }) do
    require('core_x.math.' .. n)
end

math.Vec2 = require('core_x.math.vec2')
math.Vec3 = require('core_x.math.vec3')
math.Vec4 = require('core_x.math.vec4')
math.Mat4 = require('core_x.math.mat4')
math.Quat = require('core_x.math.quaternion')

---@return math.vec2
function math.vec2(...)
    return math.Vec2(...)
end

---@return math.vec3
function math.vec3(...)
    return math.Vec3(...)
end

---@return math.vec4
function math.vec4(...)
    return math.Vec4(...)
end

---@return math.mat4
function math.mat4(...)
    return math.Mat4(...)
end

---@return math.quaternion
function math.quat(...)
    return math.Quat(...)
end
