require("utils.teleopcoroutine")
require("utils.timer")

intakeMotor = TalonSRX:new(26)

---@type CANSparkMax
arm = CANSparkMax:new(31, SparkMaxMotorType.kBrushless)
arm:restoreFactoryDefaults()
arm:setIdleMode(IdleMode.kBrake)
armEncoder = arm:getEncoder()
armPosition = 0
local minPosition = -12
local maxPosition = -5
local upSpeed = 1
local downSpeed = 0.1

---@class Intake
Intake = {}

function Intake:up()
	if armPosition < maxPosition then
		arm:set(upSpeed)
	else
		arm:set(0)
	end
end

function Intake:down()
	if armPosition > minPosition then
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