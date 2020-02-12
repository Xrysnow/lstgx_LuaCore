---
--- __init__.lua
---
--- Copyright (C) 2018-2019 Xrysnow. All rights reserved.
---

Include('core_x/import.lua')

--import 'std'
--import 'table'
--import 'math'
--import 'util'

for _, n in ipairs({ 'std', 'table', 'math', 'util', 'ext' }) do
    require('core_x.' .. n)
end

lstg.eventDispatcher = require('core_x.EventDispatcher').create()
lstg.fs = require('core_x.fs')

require('core_x.symbol')
