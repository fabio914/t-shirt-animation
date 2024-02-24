local CGLessEqual = CGLessEqual or {}
CGLessEqual.__index = CGLessEqual

function CGLessEqual.new()
    local self = setmetatable({}, CGLessEqual)
    self.inputs = {}
    return self
end

function CGLessEqual:setInput(index, func)
    self.inputs[index] = func
end

function CGLessEqual:getOutput(index)
    return self.inputs[0]() <= self.inputs[1]()
end

return CGLessEqual
