---@class lstg.mbg.Event
local M = class('lstg.mbg.Event')

function M:ctor(idx)
    self.index = assert(idx)
    self.tag = "新事件组"
    self.t = 1
    self.loop = 0
    self.addtime = 0
    self.special = 0
    -- List<string>
    self.events = {}
    -- List<EventRead>
    self.results = {}
end

function M:clone()
    local ret = M(self.index)
    for k, v in pairs(self) do
        ret[k] = table.deepcopy(v)
    end
    return ret
end

return M
