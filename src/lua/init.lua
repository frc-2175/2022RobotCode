--[[
    This file will always be run before any other robot code is run.
    It provides the basic structure needed for the robot's Lua code
    to run.
--]]

package.path = package.path .. ";./?/init.lua;/home/lvuser/lua/?.lua;/home/lvuser/lua/?/init.lua;.\\src\\lua\\?.lua;.\\src\\lua\\?\\init.lua"

require("wpilib")

table.unpack = table.unpack or unpack
if not table.pack then
    table.pack = function(...)
        local t = {...}
        t.n = #t
        return t
    end
end

Robot = {
    --- Robot-wide initialization code should go here.
    robotInit = function() end,
    --- Periodic code for all robot modes should go here. 
    robotPeriodic = function() end,
    --- Initialization code for disabled mode should go here.
    disabledInit = function() end,
    --- Periodic code for disabled mode should go here.
    disabledPeriodic = function() end,
    --- Initialization code for autonomous mode should go here.
    autonomousInit = function() end,
    --- Periodic code for autonomous mode should go here.
    autonomousPeriodic = function() end,
    --- Initialization code for teleop mode should go here.
    teleopInit = function() end,
    --- Periodic code for teleop mode should go here.
    teleopPeriodic = function() end,
    --- Robot-wide simulation initialization code should go here.
    simulationInit = function() end,
    --- Periodic simulation code should go here.
    simulationPeriodic = function() end,
}
