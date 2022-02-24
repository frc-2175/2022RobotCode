local winchMotor = DummyMotor:new(1) -- TODO: not a real device ID
local winchFollower = DummyMotor:new(2) -- TODO: not a real device id
winchFollower:follow(winchMotor)
winchFollower:setInverted(CTREInvertType.FollowMaster)

---@class Winch
Winch = {}

function Winch:runIn()
	winchMotor:set(0.5)
end

function Winch:runOut()
	winchMotor:set(-0.5)
end

function Winch:stop()
	winchMotor:set(0)
end
