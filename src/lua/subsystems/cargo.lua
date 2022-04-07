require("utils.teleopcoroutine")
require("utils.math")

intakeMotor = TalonSRX:new(26)

---@type CANSparkMax
arm = CANSparkMax:new(31, SparkMaxMotorType.kBrushless)
arm:restoreFactoryDefaults()
arm:setIdleMode(IdleMode.kBrake)
armEncoder = arm:getEncoder()
armPosition = 0

local upPosition = 1
local midPosition = 12
local downPosition = 14

local upSpeed = 1
local midSpeed = 0.3
local downSpeed = 0.2

---@class Intake
Intake = {}

function Intake:up()
	if armPosition > midPosition then
		arm:set(upSpeed)
	elseif armPosition > upPosition then
		arm:set(midSpeed)
	else
		arm:set(0)
	end
end

function Intake:down()
	if armPosition < downPosition then
		arm:set(-downSpeed)
	else
		arm:set(0)
	end
end

function Intake:stopArm()
	arm:set(0)
end

function Intake:rollIn()
	intakeMotor:set(-0.7)
end

function Intake:rollOut()
	intakeMotor:set(0.7)
end

function Intake:stop()
	intakeMotor:set(0)
end