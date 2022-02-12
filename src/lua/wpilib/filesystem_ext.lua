local ffi = require("ffi")

function reallyGetDeployDirectory()
	local cstr = ffi.C.GetDeployDirectory()
	local luastr = ffi.string(cstr)
	ffi.C.liberate(ffi.cast("void*", cstr))
	return luastr
end
