local ffi = require("ffi")

AHRS = {}

function AHRS:new()
	local a = {
		ahrs = ffi.C.AHRS_new(4),
		getAngle = function(self)
			return ffi.C.AHRS_GetAngle(self.ahrs);
		end,
		reset = function(self)
			ffi.C.AHRS_Reset(self.ahrs);
		end,
		getPitch = function(self)
			return ffi.c.AHRS_GetPitch(self.ahrs);
		end,
	}
	setmetatable(a, self)
	self.__index = selfreturn
	return a
end
