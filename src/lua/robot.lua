require("subsystems.cargo")
require("subsystems.drivetrain")
require("utils.logger")
require("utils.blendeddrive")

OVERSHOOTNESS = 100
MAX_RPM = 5620
targetSpeed = 3000

function Robot.robotInit()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
end

function Robot.teleopInit()
end

function Robot.teleopPeriodic()
	-- joystick driving
	Drivetrain:drive(squareInput(leftStick:getY()), squareInput(rightStick:getX()))

	-- if gamepad:getButtonHeld(XboxButton.RightBumper) then
	-- 	shooter:set(0.75)
	-- else
	-- 	shooter:set(0)
	-- end

	if gamepad:getButtonHeld(XboxButton.RightBumper) then
		-- print(shooter:getEncoder():getVelocity())
	end
end
