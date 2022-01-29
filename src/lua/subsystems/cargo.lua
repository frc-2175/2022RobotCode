local rollerBar = VictorSPX:new(4) --TODO: not a real device ID
local elevator = VictorSPX:new(4) --TODO: not a real device ID
function runIn()
    rollerBar:set(0.5)
    elevator:set(0.5)
end
function runOut()
    rollerBar:set(-0.5)
    elevator:set(-0.5)
end
function stop()
    rollerBar:set(0)
    elevator:set(0)
end