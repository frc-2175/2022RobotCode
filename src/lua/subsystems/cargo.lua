require("utils.teleopcoroutine")
require("utils.timer")

local intakeSolenoid = DoubleSolenoid:new(0, 1)
local intakeMotor = TalonSRX:new(0) --TODO: not real number

---@class Intake
Intake = {}

function Intake:extend()
	intakeSolenoid:set(DoubleSolenoidValue.Forward)
end

function Intake:retract()
	intakeSolenoid:set(DoubleSolenoidValue.Reverse)
end

local extendIntake = NewTeleopCoroutine(function ()
	local outTimer = Timer:new():start()
	intakeSolenoid:set(true)
	while outTimer:getElapsedTimeSeconds() < 0.05 do
		coroutine.yield()
	end
	local inTimer = Timer:new():start()
	intakeSolenoid:set(false)
	while inTimer:getElapsedTimeSeconds() < 0.05 do
		coroutine.yield()
	end
	-- intakeSolenoid:set(true)
end)

function Intake:rollIn()
	intakeMotor:set(0.5)
end

function Intake:rollOut()
	intakeMotor:set(-0.5)
end

function Intake:stop()
	intakeMotor:set(0)
end