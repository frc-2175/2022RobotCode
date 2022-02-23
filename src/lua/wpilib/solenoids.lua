-- Automatically generated by bindings.c. DO NOT EDIT.

local ffi = require("ffi")
require("wpilib.bindings.asserts")
require("wpilib.bindings.enum")

---@class Solenoid
---@field _this Solenoid
Solenoid = {}

---@class DoubleSolenoid
---@field _this DoubleSolenoid
DoubleSolenoid = {}

---@class DoubleSolenoidValue
---@field Off integer
---@field Forward integer
---@field Reverse integer
DoubleSolenoidValue = BindingEnum:new('DoubleSolenoidValue', {
    Off = 0,
    Forward = 1,
    Reverse = 2,
})


---@param on boolean
---@return any
function Solenoid:set(on)
    ffi.C.Solenoid_Set(self._this, on)
end

---@return boolean
function Solenoid:get()
    return ffi.C.Solenoid_Get(self._this)
end

---@return any
function Solenoid:toggle()
    ffi.C.Solenoid_Toggle(self._this)
end


---@param value integer
---@return any
function DoubleSolenoid:set(value)
    value = AssertEnumValue(DoubleSolenoidValue, value)
    value = AssertInt(value)
    ffi.C.DoubleSolenoid_Set(self._this, value)
end

---@return any
function DoubleSolenoid:toggle()
    ffi.C.DoubleSolenoid_Toggle(self._this)
end
