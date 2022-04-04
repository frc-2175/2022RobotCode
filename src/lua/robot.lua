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

	path = orientPath(readPath("p2"))

	testSlides = Slideshow:new({ "lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO" })
	startAutomaticCapture();
end

function Robot.autonomousInit()
	navx:reset()
	resetTracking()
	testPursuit = PurePursuit:new(
		path,
		false,
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
	putNumber("Rotation", navx:getRoll())

	Drivetrain:drive(squareInput(leftStick:getY()), squareInput(rightStick:getX()))

	if gamepad:getButtonPressed(XboxButton.RightBumper) then
		Intake:down()
	elseif gamepad:getButtonPressed(XboxButton.LeftBumper) then
		Intake:up()
	end

	if gamepad:getButtonHeld(XboxButton.Start) then
		Winch:runIn()
	elseif gamepad:getButtonHeld(XboxButton.Select) then
		Winch:runOut()
	else
		Winch:stop()
	end

	intakeMotor:set(gamepad:getLeftTriggerAmount() - gamepad:getRightTriggerAmount())
end
