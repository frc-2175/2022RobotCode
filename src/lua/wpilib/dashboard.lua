-- Automatically generated by bindings.c. DO NOT EDIT.

local ffi = require("ffi")
require("wpilib.bindings.asserts")
require("wpilib.bindings.enum")

SmartDashboard = {}

SendableChooser = {}

---@param keyName any
---@param value number
---@return any
function putNumber(keyName, value)
    value = AssertNumber(value)
    ffi.C.PutNumber(keyName, value)
end

---@param keyName any
---@param value any
---@param size any
---@return any
function putNumberArray(keyName, value, size)
    ffi.C.PutNumberArray(keyName, value, size)
end

---@param keyName any
---@param value any
---@return any
function putString(keyName, value)
    ffi.C.PutString(keyName, value)
end

---@param keyName any
---@param value any
---@param size any
---@return any
function putStringArray(keyName, value, size)
    ffi.C.PutStringArray(keyName, value, size)
end

---@param keyName any
---@param value boolean
---@return any
function putBoolean(keyName, value)
    ffi.C.PutBoolean(keyName, value)
end

---@param keyName any
---@param value any
---@param size any
---@return any
function putBooleanArray(keyName, value, size)
    ffi.C.PutBooleanArray(keyName, value, size)
end


---@return any
function SendableChooser:new()
    local instance = {
        _this = ffi.C.SendableChooser_new(),
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

---@param name any
---@param object integer
---@return any
function SendableChooser:addOption(name, object)
    object = AssertInt(object)
    ffi.C.SendableChooser_AddOption(self._this, name, object)
end

