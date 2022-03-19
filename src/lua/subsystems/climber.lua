local winchMotor = CANSparkMax:new(24, SparkMaxMotorType.kBrushless)
local winchFollower = CANSparkMax:new(25, SparkMaxMotorType.kBrushless)

winchMotor:restoreFactoryDefaults()
winchFollower:restoreFactoryDefaults()

winchFollower:setInverted(true)

winchMotor:setIdleMode(IdleMode.kBrake)
winchFollower:setIdleMode(IdleMode.kBrake)

local speed = 1

---@class Winch
Winch = {}

function Winch:runIn()
	print("running in")
	winchMotor:set(speed)
	winchFollower:set(speed)
end

function Winch:runIn1()
	print("running in")
	winchMotor:set(speed)
end

function Winch:runIn2()
	print("running in")
	winchFollower:set(speed)
end



function Winch:runOut()
	print("running out")
	winchMotor:set(-speed)
	winchFollower:set(-speed)
end

function Winch:runOut1()
	winchMotor:set(-speed)
end

function Winch:runOut2()
	winchFollower:set(-speed)
end



function Winch:stop()
	winchMotor:set(0)
	winchFollower:set(0)
end

function Winch:stop1()
	winchMotor:set(0)
end

function Winch:stop2()
	winchFollower:set(0)
end

function Winch:get()
	return winchMotor:get()
end
