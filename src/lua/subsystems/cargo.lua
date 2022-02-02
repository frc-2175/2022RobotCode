local rollerBar = VictorSPX:new(1) --TODO: not a real device ID
local elevator = VictorSPX:new(2) --TODO: not a real device ID
local shooter = VictorSPX:new(3) --TODO: not a real device ID
local intakeExtender = DoubleSolenoid:new(1, 2) --TODO: not a real device ID

function runIntakeIn()
    rollerBar:set(0.5)
    elevator:set(0.5)
end

function runIntakeOut()
    rollerBar:set(-0.5)
    elevator:set(-0.5)
end

function stopIntake()
    rollerBar:set(0)
    elevator:set(0)
end

function shootCargo()
    shooter:set(0.5)
end

function stopShooter()
    shooter:set(0)
end

function extendIntake()
    intakeExtender:set(DoubleSolenoidValue.Forward)
end

function retractIntake()
    intakeExtender:set(DoubleSolenoidValue.Reverse)
end