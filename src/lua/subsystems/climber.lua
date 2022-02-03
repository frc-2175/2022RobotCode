local winchMootor VictorSPX:new(1) --TODO: not a real device ID

function winchIn()
    winchMootor:set(0.5)
end

function winchOut
    winchMootor:set(-0.5)
end

function stop()
    winchMotor:set(0)
end