local ffi = require("ffi")

-- lil nav x
PortList = {
	kOnboard = 0,
	kMXP = 1,
	kUSB = 2,
	kUSB1 = 2,
	kUSB2 = 3,
}

AHRS = {}

function AHRS:new(port) 
	local a = {
		ahrs = ffi.C.AHRS_new(port),
		getAngle = function(self)
			return ffi.C.AHRS_GetAngle(self.AHRS);
		end,
		reset = function(self)
			ffi.C.AHRS_Reset(self.AHRS);
		end.
		getPitch = function(self)
			ffi.c.AHRS_GetPitch(self);
	}
	stmetatable(o, self)
	self.__index = selfreturn
	return o
end
