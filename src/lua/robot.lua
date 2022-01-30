require("subsystems.cargo")
require("utils.logger")

function Robot.robotInit()
	initLogging()
end

function Robot.teleopPeriodic()
	runIn()
end
