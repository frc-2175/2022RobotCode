local ffi = require("ffi")

local function makeMotorController(motor, toSCFunc, toIMCFunc)
	return {
		motor = motor,
		toSpeedController = toSCFunc,
		toIMotorController = toIMCFunc,
	}
end

-- Constants

CTREInvertType = {
	None = 0,
	InvertMotorOutput = 1,
	FollowMaster = 2,
	OpposeMaster = 3,
}

-- Clockwise and CounterClockwise here are as viewed from the face of the motor,
-- that is, from the shaft looking toward the body of the motor.
CTRETalonFXInvertType = {
	CounterClockwise = 0,
	Clockwise = 1,
	FollowMaster = 2,
	OpposeMaster = 3,
}

SparkMaxIdleMode = {
	Coast = 0,
	Brake = 1,
}

SparkMaxMotorType = {
	Brushed = 0,
	Brushless = 1,
}

TalonFXFeedbackDevice = {
	IntegratedSensor = 1,
	SensorSum = 9,
	SensorDifference = 10,
	RemoteSensor0 = 11,
	RemoteSensor1 = 12,
	None = 14,
	SoftwareEmulatedSensor = 15,
}

TalonSRXFeedbackDevice = {
	QuadEncoder = 0,
	CTRE_MagEncoder_Relative = 0,
	Analog = 2,
	PulseWidthEncodedPosition = 4,
	CTRE_MagEncoder_Absolute = 8,
	SensorSum = 9,
	SensorDifference = 10,
	RemoteSensor0 = 11,
	RemoteSensor1 = 12,
	None = 14,
	SoftwareEmulatedSensor = 15,
}

-- Victor SPX

VictorSPX = {}

function VictorSPX:new(deviceNumber)
	local o = makeMotorController(
		ffi.C.VictorSPX_new(deviceNumber), ffi.C.VictorSPX_toSpeedController,
		ffi.C.VictorSPX_toIMotorController
	)
	setmetatable(o, self)
	self.__index = self
	return o
end

function VictorSPX:get()
	return ffi.C.VictorSPX_Get(self.motor)
end

function VictorSPX:getSelectedSensorPosition(pidIdx)
	pidIdx = pidIdx or 0
	return ffi.C.VictorSPX_GetSelectedSensorPosition(self.motor, pidIdx)
end

function VictorSPX:set(value)
	ffi.C.VictorSPX_Set(self.motor, value)
end

function VictorSPX:setInverted(invertType)
	ffi.C.VictorSPX_SetInverted(self.motor, invertType)
end

function VictorSPX:follow(masterToFollow)
	-- TODO: Test that the master is a motor controller
	local masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
	ffi.C.VictorSPX_Follow(self.motor, masterIMC)
end

-- Talon SRX

TalonSRX = {}

function TalonSRX:new(deviceNumber)
	local o = makeMotorController(
		ffi.C.TalonSRX_new(deviceNumber), ffi.C.TalonSRX_toSpeedController,
		ffi.C.TalonSRX_toIMotorController
	)
	setmetatable(o, self)
	self.__index = self
	return o
end

function TalonSRX:get()
	return ffi.C.TalonSRX_Get(self.motor)
end

function TalonSRX:set(value)
	ffi.C.TalonSRX_Set(self.motor, value)
end

function TalonSRX:setInverted(invertType)
	ffi.C.TalonSRX_SetInverted(self.motor, invertType)
end

function TalonSRX:follow(masterToFollow)
	-- TODO: Test that the master is a motor controller
	masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
	ffi.C.TalonSRX_Follow(self.motor, masterIMC)
end

function TalonSRX:getOutputCurrent()
	return ffi.C.TalonSRX_GetOutputCurrent(self.motor)
end

function TalonSRX:getSelectedSensorPosition(pidIdx)
	pidIdx = pidIdx or 0
	return ffi.C.TalonSRX_GetSelectedSensorPosition(self.motor, pidIdx)
end

function TalonSRX:getStatorCurrent()
	return ffi.C.TalonSRX_GetStatorCurrent(self.motor)
end

function TalonSRX:getMotorOutputVoltage()
	return ffi.C.TalonSRX_GetMotorOutputVoltage(self.motor)
end

function TalonSRX:configSelectedFeedbackSensor(device, pididx, timeoutms)
	timeoutms = timeoutms or 0
	ffi.C.TalonSRX_ConfigSelectedFeedbackSensor(self.motor, device, pididx, timeoutms)
end

-- Talon FX

TalonFX = {}

function TalonFX:new(deviceNumber)
	local o = makeMotorController(
		ffi.C.TalonFX_new(deviceNumber), ffi.C.TalonFX_toSpeedController, ffi.C.TalonFX_toIMotorController
	)
	setmetatable(o, self)
	self.__index = self
	return o
end

function TalonFX:get()
	return ffi.C.TalonFX_Get(self.motor)
end

function TalonFX:getSelectedSensorPosition(pidIdx)
	pidIdx = pidIdx or 0
	return ffi.C.TalonFX_GetSelectedSensorPosition(self.motor, pidIdx)
end

function TalonFX:getStatorCurrent()
	return ffi.C.TalonFX_GetStatorCurrent(self.motor)
end

function TalonFX:set(value)
	ffi.C.TalonFX_Set(self.motor, value)
end

function TalonFX:setInverted(invertType)
	ffi.C.TalonFX_SetInverted(self.motor, invertType)
end

function TalonFX:follow(masterToFollow)
	-- TODO: Test that the master is a motor controller
	local masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
	ffi.C.TalonFX_Follow(self.motor, masterIMC)
end

---@param enable boolean
---@param limit number
function TalonFX:configStatorCurrentLimit(enable, limit, time)
	time = time or 0
	ffi.C.TalonFX_ConfigStatorCurrentLimit(enable, limit, time)
end

function TalonFX:configSelectedFeedbackSensor(device, pididx, timeoutms)
	timeoutms = timeoutms or 0
	ffi.C.TalonFX_ConfigSelectedFeedbackSensor(self.motor, device, pididx, timeoutms)
end

-- Spark Max (Neo)

SparkMax = {}
SparkMaxEncoder = {}

function SparkMax:new(deviceID, type)
	local o = makeMotorController(
		ffi.C.SparkMax_new(deviceID, type), ffi.C.SparkMax_toSpeedController, nil
	)
	setmetatable(o, self)
	self.__index = self
	return o
end

function SparkMax:get()
	return ffi.C.SparkMax_Get(self.motor)
end

function SparkMax:set(value)
	ffi.C.SparkMax_Set(self.motor, value)
end

function SparkMax:getEncoder()
	-- Every time we call GetEncoder, it allocates memory on the robot. This memory
	-- never gets freed. Therefore, we really do not want to do this more than once.
	if not self.encoder then
		self.encoder = SparkMaxEncoder:new(ffi.C.SparkMax_GetEncoder(self.motor))
	end
	return self.encoder
end

function SparkMax:follow(masterToFollow, invert)
	local invert = invert or false
	ffi.C.SparkMax_Follow(self.motor, masterToFollow.motor, invert)
end

function SparkMax:restoreFactoryDefaults(persist)
	local persist = persist or false
	ffi.C.SparkMax_RestoreFactoryDefaults(self.motor, persist)
end

function SparkMax:setIdleMode(mode)
	ffi.C.SparkMax_SetIdleMode(self.motor, mode)
end

-- You should not call this directly. Instead, call SparkMax:getEncoder.
function SparkMaxEncoder:new(rawEncoder)
	local o = {
		encoder = rawEncoder,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function SparkMaxEncoder:getPosition()
	return ffi.C.SparkMaxEncoder_GetPosition(self.encoder)
end

function SparkMaxEncoder:getVelocity()
	return ffi.C.SparkMaxEncoder_GetVelocity(self.encoder)
end

function SparkMaxEncoder:setPosition(position)
	return ffi.C.SparkMaxEncoder_SetPosition(self.encoder, position)
end

function SparkMaxEncoder:setPositionConversionFactor(factor)
	return ffi.C.SparkMaxEncoder_SetPositionConversionFactor(self.encoder, factor)
end

function SparkMaxEncoder:setVelocityConversionFactor(factor)
	return ffi.C.SparkMaxEncoder_SetVelocityConversionFactor(self.encoder, factor)
end

function SparkMaxEncoder:getPositionConversionFactor()
	return ffi.C.SparkMaxEncoder_GetPositionConversionFactor(self.encoder)
end

function SparkMaxEncoder:getVelocityConversionFactor()
	return ffi.C.SparkMaxEncoder_GetVelocityConversionFactor(self.encoder)
end

function SparkMaxEncoder:setInverted(inverted)
	return ffi.C.SparkMaxEncoder_SetInverted(self.encoder, inverted)
end

function SparkMaxEncoder:getInverted()
	return ffi.C.SparkMaxEncoder_GetInverted(self.encoder)
end

-- Differential Drive

DifferentialDrive = {}

function DifferentialDrive:new(leftMotor, rightMotor)
	local leftSC = leftMotor.toSpeedController(leftMotor.motor)
	local rightSC = rightMotor.toSpeedController(rightMotor.motor)
	local o = {
		drive = ffi.C.DifferentialDrive_new(leftSC, rightSC),
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function DifferentialDrive:arcadeDrive(xSpeed, zRotation, squareInputs)
	local squareInputs = squareInputs == nil and true or squareInputs
	ffi.C.DifferentialDrive_ArcadeDrive(self.drive, xSpeed, zRotation, squareInputs)
end
