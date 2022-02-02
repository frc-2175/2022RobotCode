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
		runIntakeIn()
	else
		stopIntake()
	end

	if leftStick:getButton(1) then
		extendIntake()
	elseif leftStick:getButton(2) then
		retractIntake()
	end
end
