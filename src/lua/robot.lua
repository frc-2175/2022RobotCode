require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
require("utils.logger")
require("utils.blendeddrive")
require("utils.slideshow")
require("utils.purepursuit")
require("utils.path")

function Robot.robotInit()
	initLogging()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
	resetTracking()
	-- serbo = Servo:new(1111)
	-- for i, value in ipairs(readPath("funny").path) do
	-- 	print(i, value)
	-- 	print(makePath(false, 0, Vector:new(0, 0), { makeLinePathSegment(60) }).path[i])
	-- end

	path = orientPath(readPath("p2"))
	print(path.path[1])
	print(path.path[2])

	testSlides = Slideshow:new({ "lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO" })
	CameraServer:startAutomaticCapture();
end

function Robot.autonomousInit()
	navx:reset()
	resetTracking()
	testPursuit = PurePursuit:new(
		path,
		false,
		-- 0.015, 0, 0.002
		0.015, 0, 0.002
	)
end

function Robot.autonomousPeriodic()
	trackLocation(leftMotor, rightMotor)
	putNumber("X", position.x)
	putNumber("Y", position.y)
	local rotation, speed = testPursuit:run()
	putNumber("Rotation", rotation)
	Drivetrain:drive(0.6 * speed, rotation)
end

function Robot.teleopInit()
	navx:reset()
	resetTracking()
end

function Robot.teleopPeriodic()
	-- joystick driving
	trackLocation(leftMotor, rightMotor)
	putNumber("left", leftMotor:getSelectedSensorPosition())
	putNumber("right", rightMotor:getSelectedSensorPosition())
	putNumber("X", position.x)
	putNumber("Y", position.y)
	putNumber("Rotation", navx:getAngle())
	Drivetrain:drive(squareInput(leftStick:getY()), squareInput(rightStick:getX()))



	if gamepad:getButtonPressed(XboxButton.RightBumper) then
		print("extending")
		Intake:extend()
	elseif gamepad:getButtonPressed(XboxButton.LeftBumper) then
		Intake:retract()
	end

	if gamepad:getButtonHeld(XboxButton.A) then
		Winch:runIn()
	elseif gamepad:getButtonHeld(XboxButton.Y) then
		Winch:runOut()
	else
		Winch:stop()
	end

	intakeMotor:set(gamepad:getLeftTriggerAmount()-gamepad:getRightTriggerAmount())

	-- if gamepad:getButtonHeld(XboxButton.A) then
	-- 	Winch:runOut2()
	-- elseif gamepad:getButtonHeld(XboxButton.B) then
	-- 	Winch:runIn2()
	-- else
	-- 	Winch:stop()a
	-- end
end
