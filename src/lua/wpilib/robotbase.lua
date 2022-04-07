-- Automatically generated by bindings.c. DO NOT EDIT.

local ffi = require("ffi")
require("wpilib.bindings.asserts")
require("wpilib.bindings.enum")

---@return boolean
function isEnabled()
    return ffi.C.IsEnabled()
end

---@return boolean
function isDisabled()
    return ffi.C.IsDisabled()
end

---@return boolean
function isAutonomous()
    return ffi.C.IsAutonomous()
end

---@return boolean
function isAutonomousEnabled()
    return ffi.C.IsAutonomousEnabled()
end

---@return boolean
function isOperatorControl()
    return ffi.C.IsOperatorControl()
end

---@return boolean
function isTeleop()
    return ffi.C.IsTeleop()
end

---@return boolean
function isOperatorControlEnabled()
    return ffi.C.IsOperatorControlEnabled()
end

---@return boolean
function isTeleopEnabled()
    return ffi.C.IsTeleopEnabled()
end

---@return boolean
function isTest()
    return ffi.C.IsTest()
end

---@return integer
function getRuntimeType()
    return ffi.C.GetRuntimeType()
end

---@return boolean
function isReal()
    return ffi.C.IsReal()
end

---@return boolean
function isSimulation()
    return ffi.C.IsSimulation()
end
