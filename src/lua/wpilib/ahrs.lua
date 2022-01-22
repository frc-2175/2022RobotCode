local ffi = require("ffi")

-- lil nav x
PortList = {
	kOnboard = 0,
	kMXP = 1,
	kUSB = 2,
	kUSB1 = 2,
	kUSB2 = 3,
}

AHRS = {
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
AHRS.__index = AHRS

function AHRS:new(port)
	local a = {
		ahrs = ffi.C.AHRS_new(port),
	}
	setmetatable(a, self)
	self.__index = selfreturn
	return a
end
