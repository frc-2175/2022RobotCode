require("utils.teleopcoroutine")
require("utils.timer")

intakeMotor = TalonSRX:new(26)

---@type CANSparkMax
local intakeArm = CANSparkMax:new(27, SparkMaxMotorType.kBrushless)
armPosition = 0
minPosition = 0 -- TODO: REAL MIN PLEASE DONT RUN THIS
maxPosition = 100 -- TODO: REAL MAX PLEASE DONT RUN THIS

---@class Intake
Intake = {}

function Intake:up()
	armPosition = intakeArm:getPosition()
	if armPosition < maxPosition then
		intakeArm:set(0.5)
	else
		intakeArm:set(0)
	end
end

function Intake:down()
	armPosition = intakeArm:getPosition()
	if armPosition > minPosition then
		intakeArm:set(-0.5)
	else
		intakeArm:set(0)
	end
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