leftMotor = TalonFX:new(20)

rightMotor = TalonFX:new(21)
rightMotor:setInverted(CTREInvertType.InvertMotorOutput)
	
leftFollower = TalonFX:new(22)
leftFollower:follow(leftMotor)
leftFollower:setInverted(CTREInvertType.FollowMaster)

rightFollower = TalonFX:new(23)
rightFollower:follow(rightMotor)
rightFollower:setInverted(CTREInvertType.FollowMaster)

function drive(speed, rotation)
    local leftSpeed, rightSpeed = getBlendedMotorValues(speed, rotation)
    leftMotor:set(leftSpeed)
    rightMotor:set(rightSpeed)
end

function stop()
    drive(0, 0)
end
