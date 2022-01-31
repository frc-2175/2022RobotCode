PIDController = {}

function PIDController:new(p, i, d)
	local p = {
		kp = p,
		ki = i,
		kd = d,
		integral = 0,
		previousError = nil,
		previousTime = 0,
		dt = 0,
		shouldRunIntegral = false,
	}
	setmetatable(p, self)
	self.__index = self

	return p
end

function PIDController:clear(time)
	self.dt = 0
	self.previousTime = time
	self.integral = 0
	self.previousError = nil
	self.shouldRunIntegral = false
end

function PIDController:pid(input, setpoint, thresh)
	local threshold = thresh or 0
	local error = setpoint - input
	local p = error * self.kp
	local i = 0
	if self.shouldRunIntegral then
		if threshold == 0 or (input < (threshold + setpoint) and input > (setpoint - threshold)) then
			self.integral = self.integral + self.dt * error
		else
			self.integral = 0
		end
	else
		self.shouldRunIntegral = true
	end
	local d
	if self.previousError == nil or self.dt == 0 then
		d = 0
	else
		d = ((error - self.previousError) / self.dt) * self.kd
	end
	self.previousError = error
	return p + i + d
end

function PIDController:updateTime(time)
	self.dt = time - self.previousTime
	self.previousTime = time
end
