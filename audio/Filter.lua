---@type audio.Filter
local M = audio.Filter
require('audio.enum')

---Lowpass
---@param gain number
---@param high_gain number
function M.Lowpass(gain, high_gain)
    return {
        [audio.FilterParameter.TYPE]     = audio.FilterType.LOWPASS,
        [audio.FilterParameter.VOLUME]   = gain,
        [audio.FilterParameter.HIGHGAIN] = high_gain,
    }
end

---Highpass
---@param gain number
---@param low_gain number
function M.Highpass(gain, low_gain)
    return {
        [audio.FilterParameter.TYPE]    = audio.FilterType.HIGHPASS,
        [audio.FilterParameter.VOLUME]  = gain,
        [audio.FilterParameter.LOWGAIN] = low_gain,
    }
end

---Bandpass
---@param gain number
---@param low_gain number
---@param high_gain number
function M.Bandpass(gain, low_gain, high_gain)
    return {
        [audio.FilterParameter.TYPE]     = audio.FilterType.BANDPASS,
        [audio.FilterParameter.VOLUME]   = gain,
        [audio.FilterParameter.LOWGAIN]  = low_gain,
        [audio.FilterParameter.HIGHGAIN] = high_gain,
    }
end

return M
