require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
require("utils.logger")
require("utils.blendeddrive")
require("utils.slideshow")
require("utils.purepursuit")
require("utils.path")

function Robot.robotInit()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
	resetTracking()

	path = orientPath(readPath("p2"))

	testSlides = Slideshow:new({ "lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO" })
	-- startAutomaticCapture();
end

function Robot.robotPeriodic()
	-- we make armPosition negative because i hate you.
	armPosition = -arm:getPosition(armEncoder)
	putNumber("arm", armPosition)
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

	if gamepad:getButtonHeld(XboxButton.RightBumper) then
		Intake:down()
	elseif gamepad:getButtonHeld(XboxButton.LeftBumper) then
		Intake:up()
	else
		Intake:stopArm()
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
