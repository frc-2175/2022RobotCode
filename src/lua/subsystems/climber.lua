local winchMotor = CANSparkMax:new(24, SparkMaxMotorType.kBrushless)
local winchFollower = CANSparkMax:new(25, SparkMaxMotorType.kBrushless)

winchMotor:restoreFactoryDefaults()
winchFollower:restoreFactoryDefaults()

winchFollower:setInverted(true)
winchMotor:setIdleMode(IdleMode.kBrake)
winchFollower:setIdleMode(IdleMode.kBrake)


---@class Winch
Winch = {}

function Winch:runIn()
	print("running in")
	winchMotor:set(1)
	
end
function Winch:runIn2()
	print("running in")
	
	winchFollower:set(1)
end



function Winch:runOut()
	print("running out")
	winchMotor:set(-1)
	
end
function Winch:runOut2()
	print("running out")
	
	winchFollower:set(-1)
end

function Winch:stop()
	winchMotor:set(0)
	
end
function Winch:stop2()
	
	winchFollower:set(0)
end

function Winch:get()
	return winchMotor:get()
end
