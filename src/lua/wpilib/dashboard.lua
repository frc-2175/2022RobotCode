local ffi = require("ffi")

---@param name string
---@param value number
function putNumber(name, value)
	ffi.C.SmartDashboard_PutNumber(name, value)
end

---@param name string
---@param value table
function putNumberArray(name, value)
	ffi.C.SmartDashboard_PutNumberArray(name, ffi.new("double[?]", #value, value), #value)
end

---@param name string
---@param value string
function putString(name, value)
	ffi.C.SmartDashboard_PutString(name, value)
end

---@param name string
---@param value table
function putStringArray(name, value)
	ffi.C.SmartDashboard_PutStringArray(name, ffi.new("const char*[?]", #value, value), #value)
end

---@param name string
---@param value boolean
function putBoolean(name, value)
	ffi.C.SmartDashboard_PutBoolean(name, value)
end

--- Use integers instead of booleans (`0=false`, `1=true`)
---@param name string
---@param value table
function putBooleanArray(name, value)
	ffi.C.SmartDashboard_PutBooleanArray(name, ffi.new("int[?]", #value, value), #value)
end
