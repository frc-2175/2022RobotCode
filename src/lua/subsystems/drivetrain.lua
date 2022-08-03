leftMotor = TalonSRX:new(1)
leftMotor:setInvertedBool(true)

rightMotor = TalonSRX:new(6)

---@class Drivetrain
Drivetrain = {}

function Drivetrain:drive(speed, rotation)
	local leftSpeed, rightSpeed = getBlendedMotorValues(speed, rotation)
	leftMotor:set(leftSpeed)
	rightMotor:set(rightSpeed)
end

function Drivetrain:stop()
	Drivetrain:drive(0, 0)
end
