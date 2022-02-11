require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
require("wpilib.dashboard")
require("utils.logger")
require("utils.blendeddrive")
require("utils.purepursuit")
require("utils.path")

function Robot.robotInit()
	--initLogging()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)
	-- serbo = Servo:new(1111)
	chooser = SendableChooser:new()
	chooser:putChooser({
		{name = "Test 1", value = "they're selecting test 1"},
		{name = "Test 2", value = "they're selecting test 2"},
	})
	pathy = makePath(false, 0, Vector:new(0,0), {makeLinePathSegment(10)})
	purepursuity = PurePursuit:new(pathy, 0, 0, 0)
end

function Robot.autonomousPeriodic()
	turnvalue = purepursuity:run()
	getBlendedMotorValues(.5,turnvalue)
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

	if gamepad:getButtonHeld(XboxButton.Y) then
		Winch:runIn()
	elseif gamepad:getButtonHeld(XboxButton.X) then
		Winch:runOut()
	else
		Winch:stop()
	end
end
