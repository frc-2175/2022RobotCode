require("subsystems.cargo")
require("subsystems.drivetrain")
require("utils.logger")

function Robot.robotInit()
	initLogging()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
end

function Robot.teleopPeriodic()
	if rightStick:getTriggerHeld() then
		Intake:runIn()
	else
		Intake:stop()
	end

	if leftStick:getTriggerHeld() then
		Intake:extend()
	elseif leftStick:getTopHeld() then
		Intake:retract()
	end

	if gamepad:getButtonHeld(4) then
		winchIn()
	elseif gamepad:getButtonHeld(3) then
		winchOut()
	else
		stop()
	end
end
