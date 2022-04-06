require("utils.teleopcoroutine")
require("utils.timer")
require("utils.math")

intakeMotor = TalonSRX:new(26)

---@type CANSparkMax
arm = CANSparkMax:new(31, SparkMaxMotorType.kBrushless)
arm:restoreFactoryDefaults()
arm:setIdleMode(IdleMode.kBrake)
armEncoder = arm:getEncoder()
armPosition = 0

local upPosition = 3
local downPosition = 18

local upSpeed = 1
local downSpeed = 0.1

---@class Intake
Intake = {}

function Intake:up()
	local speed = arm:set(getTrapezoidSpeed(upSpeed, upSpeed, 0, downPosition, 0, 6, armPosition))
	if armPosition > upPosition then
		arm:set(speed)
	else
		arm:set(0)
	end
end

function Intake:down()
	if armPosition > downPosition then
		arm:set(-downSpeed)
	else
		arm:set(0)
	end
end

function Intake:stopArm()
	arm:set(0)
end

function Intake:rollIn()
	intakeMotor:set(0.5)
end

function Intake:rollOut()
	intakeMotor:set(-0.5)
end

function Intake:stop()
	intakeMotor:set(0)
end