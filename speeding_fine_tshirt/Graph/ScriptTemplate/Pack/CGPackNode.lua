local CGPackNode = CGPackNode or {}
CGPackNode.__index = CGPackNode

function CGPackNode.new()
    local self = setmetatable({}, CGPackNode)
    self.inputs = {}
    self.valueType = nil
    return self
end

function CGPackNode:setInput(index, func)
    self.inputs[index] = func
end

function CGPackNode:getOutput(index)
    if self.valueType == "Vector2f" then
        return Amaz.Vector2f(self.inputs[0](), self.inputs[1]())
    elseif self.valueType == "Vector3f" then
        return Amaz.Vector3f(self.inputs[0](), self.inputs[1](), self.inputs[2]())
    elseif self.valueType == "Vector4f" then
        return Amaz.Vector4f(self.inputs[0](), self.inputs[1](), self.inputs[2](), self.inputs[3]())
    elseif self.valueType == "Quaternionf" then
        return Amaz.Quaternionf(self.inputs[0](), self.inputs[1](), self.inputs[2](), self.inputs[3]())
    elseif self.valueType == "Rect" then
        return Amaz.Rect(self.inputs[0](), self.inputs[1](), self.inputs[2](), self.inputs[3]())
    elseif self.valueType == 'Color' then
        return Amaz.Color(self.inputs[0](), self.inputs[1](), self.inputs[2](), self.inputs[3]())
    end
end

return CGPackNode
