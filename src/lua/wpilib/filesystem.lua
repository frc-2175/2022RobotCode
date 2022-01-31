local ffi = require("ffi")

---@return string deployDirectory
function getDeployDirectory()
	local cstr = ffi.C.GetDeployDirectory()
	local luastr = ffi.string(cstr)
	ffi.C.liberate(ffi.cast("void*", cstr))
	return luastr
end
