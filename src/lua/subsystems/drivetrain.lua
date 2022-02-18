leftMotor = TalonFX:new(20)
leftMotor:setInverted(CTREInvertType.InvertMotorOutput)

rightMotor = TalonFX:new(21)
	
leftFollower = TalonFX:new(22)
leftFollower:follow(leftMotor)
leftFollower:setInverted(CTREInvertType.FollowMaster)

rightFollower = TalonFX:new(23)
rightFollower:follow(rightMotor)
rightFollower:setInverted(CTREInvertType.FollowMaster)

Drivetrain = {}

function Drivetrain:drive(speed, rotation)
    local leftSpeed, rightSpeed = getBlendedMotorValues(speed, rotation)
    leftMotor:set(leftSpeed)
    rightMotor:set(rightSpeed)
end

function Drivetrain:stop()
    Drivetrain:drive(0, 0)
end
