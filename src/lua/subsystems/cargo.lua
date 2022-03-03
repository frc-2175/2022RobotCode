local intakeSolenoid = Solenoid:new(1)

---@class Intake
Intake = {}

function Intake:extend()
	intakeSolenoid:set(true)
end

function Intake:retract()
	intakeSolenoid:set(false)
end