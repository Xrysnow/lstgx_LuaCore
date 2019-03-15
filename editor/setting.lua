--
local M = {
    _cheat = false,
    _resx = 1280,
    _resy = 960,
    _windowed = true,
}

function M:setCheat(v)
    self._cheat = v
end

function M:getCheat()
    return self._cheat
end

function M:setGameRes(x, y)
    self._resx = x
    self._resy = y
end

function M:getGameRes()
    return self._resx, self._resy
end

function M:setGameWindowed(v)
    self._windowed = v
end

function M:getGameWindowed()
    return self._windowed
end

return M
