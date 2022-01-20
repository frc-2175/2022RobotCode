function robot.robotInit()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)

	intakeMotor = TalonSRX:new(5)
	leftMotor = TalonSRX:new(1)
	rightMotor = TalonSRX:new(6)

	rightMotor:setInverted(CTREInvertType.InvertMotorOutput)
	drive = DifferentialDrive:new(leftMotor, rightMotor)

	print("froggers")
end

-- teleop periodic : WHERE EVERTHING HAPPENS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function robot.teleopPeriodic()
	local speed = -leftStick:getAxis(JoystickAxes.Y)
	local turnSpeed = rightStick:getAxis(JoystickAxes.X) * 0.77

	drive:arcadeDrive(speed, turnSpeed)

	if rightStick:getButton(1) then
		intakeMotor:set(0.77)
	else
		intakeMotor:set(0)
	end
	print("g")
	print("encoder uhh :" .. rightMotor:getSelectedSensorPosition(0))
end

function robot.autonomousInit()
end

function robot.autonomousPeriodic()
end
--Elizabeth was here 