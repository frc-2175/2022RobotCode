local winchMotor = DummyMotor:new(1) -- TODO: not a real device ID

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
