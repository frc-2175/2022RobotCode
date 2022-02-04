local winchMotor = VictorSPX:new(1) -- TODO: not a real device ID

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
