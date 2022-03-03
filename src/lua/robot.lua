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

	

	testSlides = Slideshow:new({ "lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO" })
	testPursuit = PurePursuit:new(
		makePath(false, 0, Vector:new(0, 0), { makeLinePathSegment(60) }),
		false,
		0.02, 0, 0.002
	)
end

function Robot.autonomousInit()
	navx:reset()
	resetTracking()
end

function Robot.autonomousPeriodic()
	trackLocation(leftMotor, rightMotor)
	putNumber("X", position.x)
	putNumber("Y", position.y)
	local rotation, speed = testPursuit:run()
	putNumber("Rotation", rotation)
	Drivetrain:drive(0.33 * speed, rotation)
end

function Robot.teleopInit()
	navx:reset()
	resetTracking()
end

function Robot.teleopPeriodic()
	-- joystick driving
	trackLocation(leftMotor, rightMotor)
	putNumber("X", position.x)
	putNumber("Y", position.y)
	putNumber("Rotation", navx:getAngle())
	Drivetrain:drive(squareInput(leftStick:getY()), squareInput(rightStick:getX()))



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

	if gamepad:getButtonPressed(XboxButton.RightBumper) then
		testSlides:next()
	elseif gamepad:getButtonPressed(XboxButton.LeftBumper) then
		testSlides:prev()
	end

	if gamepad:getButtonHeld(XboxButton.Y) then
		Winch:runIn()
	elseif gamepad:getButtonHeld(XboxButton.X) then
		Winch:runOut()
	else
		Winch:stop()
	end
	if gamepad:getButtonHeld(XboxButton.A) then
		Winch:runIn2()
	elseif gamepad:getButtonHeld(XboxButton.B) then
		Winch:runOut2()
	else
		Winch:stop2()
	end

	testSlides:draw()
end
