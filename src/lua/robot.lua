require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
require("utils.logger")
require("utils.blendeddrive")
require("utils.slideshow")
require("utils.purepursuit")
require("utils.path")
require("auto.coroutines")

local selectedAuto = doNothingAuto

function Robot.robotInit()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
	resetTracking()
	navx:reset()
	autoChooser = SendableChooser:new()
	autoChooser:putChooser({
		{ name = "doNothing", value = doNothingAuto },
		{ name = "taxi", value = taxiAuto },
		{ name = "oneBallAuto", value = oneBallAuto },
	})

	-- testSlides = Slideshow:new({ "lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO" })
	startAutomaticCapture();
end

function Robot.robotPeriodic()
	-- we make armPosition negative because i hate you.
	armPosition = -arm:getPosition(armEncoder)
	putNumber("arm", armPosition)
	putNumber("armSpeed", arm:get())
	putNumber("left", leftMotor:getSelectedSensorPosition())
	putNumber("right", rightMotor:getSelectedSensorPosition())
	putNumber("X", position.x)
	putNumber("Y", position.y)
	putNumber("Rotation", navx:getAngle())
end

function Robot.autonomousInit()
	navx:reset()
	resetTracking()
	selectedAuto = autoChooser:getSelected()
	selectedAuto:reset()
end

function Robot.autonomousPeriodic()
	trackLocation(leftMotor, rightMotor)
	selectedAuto:run()
end

function Robot.teleopInit()
	navx:reset()
	resetTracking()
end

function Robot.teleopPeriodic()
	Intake:periodic()

	-- joystick driving
	Drivetrain:drive(squareInput(leftStick:getY()), squareInput(rightStick:getX()))

	if gamepad:getButtonPressed(XboxButton.RightBumper) or rightStick:getTriggerPressed() then
		Intake:down()
	end

	if gamepad:getButtonReleased(XboxButton.RightBumper) or rightStick:getTriggerReleased() then
		Intake:up()
	end

	if gamepad:getButtonHeld(XboxButton.Start) then
		Winch:runIn()
		Intake:down()
	elseif gamepad:getButtonHeld(XboxButton.Select) then
		Winch:runOut()
		Intake:down()
	else
		Winch:stop()
	end

	
	if rightStick:getTriggerHeld() then
		Intake:rollIn()
	else
		Intake:stop()
		intakeMotor:set(gamepad:getLeftTriggerAmount() - gamepad:getRightTriggerAmount())
	end
end
