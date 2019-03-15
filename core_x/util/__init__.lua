---
--- __init__.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

--from '.' import '*'
for _, n in ipairs({ 'color', 'color_def', 'ffi', 'xclass', 'string' }) do
    require('core_x.util.' .. n)
end
