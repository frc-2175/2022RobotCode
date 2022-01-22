require("utils.vector")

TICKS_TO_INCHES = 112.0/182931.0 --stolen from java code, should be right numvber but confirm?
lastEncoderDistanceLeft = 0
lastEncoderDistanceRight = 0
position = NewVector(0,0)

function robot.robotInit()
	leftStick = Joystick:new(0)
	rightStick = Joystick:new(1)
	gamepad = Joystick:new(2)

	intakeMotor = TalonSRX:new(5)
	leftMotor = TalonSRX:new(1)
	rightMotor = TalonSRX:new(6)

	rightMotor:setInverted(CTREInvertType.InvertMotorOutput)
	drive = DifferentialDrive:new(leftMotor, rightMotor)
	navx = AHRS:new()

	print("RIP Blockboy, you will never be forgotten. <3")
end

-- function getAverageEncoderDistance() 
-- 	return ((rightMotor:getSelectedSensorPosition() + leftMotor:getSelectedSensorPosition())/2)*TICKS_TO_INCHES
-- end

function trackLocation() 
	--first, get the distance we've traveled since last time trackLocation was called
	distanceLeft = (leftMotor:getSelectedSensorPosition() * TICKS_TO_INCHES) - lastEncoderDistanceLeft
	distanceRight = (rightMotor:getSelectedSensorPosition() * TICKS_TO_INCHES) - lastEncoderDistanceRight
	--calculates avg distance traveled
	distance = (distanceLeft+distanceRight)/2
	--get our heading in radians
	angle = math.rad(navx:getAngle())
	
	--make a vector representing our change in position since last time
	x = math.sin(angle) * distance
	y = math.cos(angle) * distance

	changeInPosition = NewVector(x,y)
	position = position + changeInPosition

	--setting the "lastEncoderDistance" for next time
	lastEncoderDistanceLeft = leftMotor:getSelectedSensorPosition() * TICKS_TO_INCHES
	lastEncoderDistanceRight = rightMotor:getSelectedSensorPosition() * TICKS_TO_INCHES
end
-- public void trackLocation() {
-- 	double distanceLeft = getLeftDistance() - lastEncoderDistanceLeft; 
-- 	double distanceRight = getRightDistance() - lastEncoderDistanceRight; 
-- 	double distance = (distanceLeft + distanceRight) / 2; 
-- 	double angle = Math.toRadians(navx.getAngle()); 

-- 	double x = Math.sin(angle) * distance; 
-- 	double y = Math.cos(angle) * distance; 

-- 	Vector changeInPosition = new Vector(x, y); 
-- 	position = position.add(changeInPosition); 

-- 	lastEncoderDistanceLeft = getLeftDistance(); 
-- 	lastEncoderDistanceRight = getRightDistance();
-- }
function resetTracking()
	lastEncoderDistanceLeft = 0
	lastEncoderDistanceRight = 0
	-- zeroEncoderLeft = leftMotor:getSelectedSensorPosition(0)
	-- zeroEncoderRight = rightMotor:getSelectedSensorPosition(0)
	position = new Vector(0,0)
	navx.reset();
end
-- public void resetTracking() {
-- 	lastEncoderDistanceLeft = 0;
-- 	lastEncoderDistanceRight = 0;
-- 	zeroEncoderLeft = leftMaster.getSelectedSensorPosition(0);
-- 	zeroEncoderRight = rightMaster.getSelectedSensorPosition(0);
-- 	position = new Vector(0, 0);
-- 	navx.reset();
-- }

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

	trackLocation()

	print("g")
	print("encoder uhh :" .. rightMotor:getSelectedSensorPosition(0))
	print("navx uhh :".. navx:getAngle())
	print(position)
end

function robot.autonomousInit()
end

function robot.autonomousPeriodic()
end
--Elizabeth was here 