---
--- __init__.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

--from '.' import '*'
for _, n in ipairs({ 'math', 'math_const', 'math_types' }) do
    require('core_x.math.' .. n)
end
