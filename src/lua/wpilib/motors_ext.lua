local ffi = require("ffi")

local function toSpeedController(motor)
    if getmetatable(motor) == VictorSPX then
        return ffi.C.VictorSPX_ToSpeedController(motor._this)
    elseif getmetatable(motor) == TalonSRX then
        return ffi.C.TalonSRX_ToSpeedController(motor._this)
    elseif getmetatable(motor) == TalonFX then
        return ffi.C.TalonFX_ToSpeedController(motor._this)
    else
        error('could not convert '..tostring(motor)..' to SpeedController')
    end
end

local function toIMotorController(motor)
    if getmetatable(motor) == VictorSPX then
        return ffi.C.VictorSPX_ToIMotorController(motor._this)
    elseif getmetatable(motor) == TalonSRX then
        return ffi.C.TalonSRX_ToIMotorController(motor._this)
    elseif getmetatable(motor) == TalonFX then
        return ffi.C.TalonFX_ToIMotorController(motor._this)
    else
        error('could not convert '..tostring(motor)..' to IMotorController')
    end
end

function VictorSPX:follow(masterToFollow)
    ffi.C.VictorSPX_Follow(self._this, toIMotorController(masterToFollow))
end

function TalonSRX:follow(masterToFollow)
    ffi.C.TalonSRX_Follow(self._this, toIMotorController(masterToFollow))
end

function TalonFX:follow(masterToFollow)
    ffi.C.TalonFX_Follow(self._this, toIMotorController(masterToFollow))
end

function DifferentialDrive:new(leftMotor, rightMotor)
    local instance = {
        _this = ffi.C.DifferentialDrive_new(toSpeedController(leftMotor), toSpeedController(rightMotor)),
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end
