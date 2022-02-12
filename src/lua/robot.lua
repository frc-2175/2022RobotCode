require("subsystems.cargo")
require("subsystems.climber")
require("subsystems.drivetrain")
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

	leftMotor = TalonFX:new(0)
	rightMotor = TalonFX:new(1)
	
	leftFollower = TalonFX:new(2)
	leftFollower:follow(leftMotor)
	leftFollower:setInverted(CTRETalonFXInvertType.FollowMaster)
	rightFollower = TalonFX:new(3)
	rightFollower:follow(rightMotor)
	rightFollower:setInverted(CTRETalonFXInvertType.FollowMaster)

	robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function Robot.autonomousPeriodic()
end

function Robot.teleopPeriodic()
	-- joystick driving
	robotDrive:arcadeDrive(
        leftStick:getY(),
        rightStick:getX(),
		false
    )


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
