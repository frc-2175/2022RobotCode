-- Automatically generated by bindings.c. DO NOT EDIT.

local ffi = require("ffi")
require("wpilib.bindings.asserts")
require("wpilib.bindings.enum")

---@param ptr any
---@return any
function liberate(ptr)
    ffi.C.liberate(ptr)
end