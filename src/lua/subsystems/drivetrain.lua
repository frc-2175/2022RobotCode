local leftMasterMotor = TalonFX:new(1) --TODO: not a real device id
local leftFollowerMotor = TalonFX:new(1) --TODO: not a real device id
local rightMasterMotor = TalonFX:new(1) --TODO: not a real device id
local rightFollowerMotor = TalonFX:new(1) --TODO: not a real device id

leftFollowerMotor:follow(leftMasterMotor)
rightFollowerMotor:follow(rightMasterMotor)

local dive = DifferentialDrive:new(leftMasterMotor, rightMasterMotor)

function drive(speed, rotation)
local leftSpeed, rightSpeed = getBlendedMotorValues(speed, rotation)
leftMasterMotor:set(leftSpeed)
rightMasterMotor:set(rightSpeed)
end

function stop()
    drive(0, 0)
end
