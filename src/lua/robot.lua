require("subsystems.cargo")
require("subsystems.drivetrain")
require("utils.logger")

function Robot.robotInit()
	initLogging()
end

function Robot.teleopPeriodic()
	runIn()
end
