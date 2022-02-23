local rollerBar = DummyMotor:new(1) -- TODO: not a real device ID
local elevator = DummyMotor:new(2) -- TODO: not a real device ID
local shooter = DummyMotor:new(3) -- TODO: not a real device ID
local intakeExtender = DummyMotor:new(1, 2) -- TODO: not a real device ID

---@class Intake
Intake = {}

function Intake:runIn()
	rollerBar:set(0.5)
	elevator:set(0.5)
end

function Intake:runOut()
	rollerBar:set(-0.5)
	elevator:set(-0.5)
end

function Intake:stop()
	rollerBar:set(0)
	elevator:set(0)
end

function Intake:extend()
	intakeExtender:set(DoubleSolenoidValue.Forward)
end

function Intake:retract()
	intakeExtender:set(DoubleSolenoidValue.Reverse)
end

function shootCargo()
	shooter:set(0.5)
end

function stopShooter()
	shooter:set(0)
end