--

---@type lstg.Random
local M = lstg.Random
local insert = table.insert
local floor = math.floor

--- Choose a random element from a non-empty array.
---@param array table
function M:choice(array)
    local len = #array
    if len == 0 then
        return
    end
    return array[self:below(len) + 1]
end

--- Shuffle array in place.
---@param array table
function M:shuffle(array)
    for i = #array, 2, -1 do
        local j = self:below(i) + 1
        array[i], array[j] = array[j], array[i]
    end
end

--- Chooses k unique random elements from an array.
---
--- Returns a new array.
---@param array table
---@param k number
---@return table
function M:sample(array, k)
    local n = #array
    if k > n or n == 0 then
        return {}
    end
    local result = {}
    local mark = {}
    for i = 1, k do
        local j = self:below(k - i + 1) + 1
        insert(result, array[mark[j] or j])
        mark[j] = mark[k - i + 1] or n - i + 1
    end
    return result
end

--- Chooses k unique random numbers from a range.
---
--- Returns an array.
---@param start number
---@param stop number
---@param step number
---@param k number
---@return table
function M:sample_range(start, stop, step, k)
    if start == stop or step == 0 then
        return {}
    end
    local width = stop - start
    local n
    if step > 0 then
        n = (width + step - 1) / step
    else
        n = (width + step + 1) / step
    end
    n = floor(n)
    if n <= 0 then
        return {}
    end
    local result = {}
    local mark = {}
    for i = 1, k do
        local j = self:below(i) + 1
        insert(result, start + step * (mark[j] or j - 1))
        mark[j] = mark[k - i + 1] or n - i + 1
    end
    return result
end
