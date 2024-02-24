local CGLessThan = CGLessThan or {}
CGLessThan.__index = CGLessThan

function CGLessThan.new()
    local self = setmetatable({}, CGLessThan)
    self.inputs = {}
    return self
end

function CGLessThan:setInput(index, func)
    self.inputs[index] = func
end

function CGLessThan:getOutput(index)
    return self.inputs[0]() < self.inputs[1]()
end

return CGLessThan
