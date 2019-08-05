--
local M = {}
require('audio.enum')

function M.Lowpass(gain, high_gain)
    return {
        [audio.FilterParameter.TYPE]     = audio.FilterType.LOWPASS,
        [audio.FilterParameter.VOLUME]   = gain,
        [audio.FilterParameter.HIGHGAIN] = high_gain,
    }
end

function M.Highpass(gain, low_gain)
    return {
        [audio.FilterParameter.TYPE]    = audio.FilterType.HIGHPASS,
        [audio.FilterParameter.VOLUME]  = gain,
        [audio.FilterParameter.LOWGAIN] = low_gain,
    }
end

function M.Bandpass(gain, low_gain, high_gain)
    return {
        [audio.FilterParameter.TYPE]     = audio.FilterType.BANDPASS,
        [audio.FilterParameter.VOLUME]   = gain,
        [audio.FilterParameter.LOWGAIN]  = low_gain,
        [audio.FilterParameter.HIGHGAIN] = high_gain,
    }
end

return M
