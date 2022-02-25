local winchMotor = CANSparkMax:new(24, SparkMaxMotorType.kBrushless)
local winchFollower = CANSparkMax:new(25, SparkMaxMotorType.kBrushless)
winchFollower:follow(winchMotor)
winchFollower:setInverted(false)

---@class Winch
Winch = {}

function Winch:runIn()
	winchMotor:set(0.5)
end

function Winch:runOut()
	winchMotor:set(-0.5)
end

function Winch:stop()
	winchMotor:set(0)
end
