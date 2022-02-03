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
	if rightStick:getButton(1) then
		Intake:runIn()
	else
		Intake:stop()
	end

	if leftStick:getButton(1) then
		Intake:extend()
	elseif leftStick:getButton(2) then
		Intake:retract()
	end

	if gamepad:getButton(4) then
		winchIn()
	elseif gamepad:getButton(3) then
		winchOut()
	else 	
		stop()
	end
end
