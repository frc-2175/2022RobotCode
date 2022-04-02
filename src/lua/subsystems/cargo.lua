require("utils.teleopcoroutine")
require("utils.timer")

local intakeSolenoid = DoubleSolenoid:new(0, 1)
intakeMotor = TalonSRX:new(25)

---@class Intake
Intake = {}

function Intake:extend()
	intakeSolenoid:set(DoubleSolenoidValue.Forward)
end

function Intake:retract()
	intakeSolenoid:set(DoubleSolenoidValue.Reverse)
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