require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
require("utils.logger")
require("utils.blendeddrive")
require("utils.slideshow")
require("utils.purepursuit")
require("utils.path")

function Robot.robotInit()
	--initLogging()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
	-- serbo = Servo:new(1111)
	testSlides = Slideshow:new({"lemon", "*chomp chomp*", "OoOOOooOoOoOOoooO"})
end

function Robot.autonomousPeriodic()
end

function Robot.teleopPeriodic()
	-- joystick driving
	Drivetrain:drive(-leftStick:getY(), rightStick:getX())


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

	testSlides:display()
end
