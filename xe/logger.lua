--
local M = {}

function M.log(str, type, trace)
    --print(type, str)
    require('xe.main'):getInstance()._output:addLine(str, type)
end

function M.clear()
    require('xe.main'):getInstance()._output:clear()
end

return M
