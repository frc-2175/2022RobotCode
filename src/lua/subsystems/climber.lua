local winchMotor = CANSparkMax:new(14, SparkMaxMotorType.kBrushless)
local winchFollower = CANSparkMax:new(15, SparkMaxMotorType.kBrushless)
winchFollower:setInverted(true)

---@class Winch
Winch = {}

function Winch:runIn()
	print("running in")
	winchMotor:set(1)
	winchFollower:set(1)
end

function Winch:runOut()
	print("running out")
	winchMotor:set(-1)
	winchFollower:set(-1)
end

function Winch:stop()
	winchMotor:set(0)
	winchFollower:set(0)
end

function Winch:get()
	return winchMotor:get()
end
