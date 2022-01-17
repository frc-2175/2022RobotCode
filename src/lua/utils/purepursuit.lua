require("utils.vector")
require("utils.math")
require("utils.pid")
require("wpilib.ahrs")
require("wpilib.motors")

local previousClosestPoint = 0;
local purePursuitPID = NewPIDController(0.02, 0, 0.002);
local position = NewVector(0, 0)
local navx = NewAHRS(PortList.kMXP)

---@param pathResult table - a pure pursuit path
---@param fieldPosition any - the robot's current position on the field
---@param previousClosestPoint number
---@return number indexOfClosestPoint
--[[
    looks through all points on the list, finds & returns the point
    closest to current robot position 
--]]
function FindClosestPoint(pathResult, fieldPosition, previousClosestPoint)
    local indexOfClosestPoint = 0
    local startIndex = previousClosestPoint - 36 --36 lookahead distance (in)
    local endIndex = previousClosestPoint + 36
    --making sure indexes make sense
    if startIndex < 1 then
        startIndex = 1
    end
    if endIndex > pathResult.numberOfActualPoints then
        endIndex = pathResult.numberOfActualPoints
    end
    local minDistance = (pathResult.path[1] - fieldPosition):length() -- minimum distance you will have to travel
    for i = startIndex, endIndex do --check through each point in list, and ...
        local distanceToPoint = (pathResult.path[i] - fieldPosition):length()
        if distanceToPoint <= minDistance then
            indexOfClosestPoint = i
            minDistance = distanceToPoint --if we find a closer one, that becomes the new minDist
        end
    end
    return indexOfClosestPoint
end

---@param pathResult table - a pure pursuit path
---@param fieldPosition any - current robot position
---@param lookAhead number - number of indexes to look ahead in path
---@param closestPoint number - INDEX OF closest point in path to current position, basically where we are, ish
---@return number goalPoint - returns the index we should be aiming for

function FindGoalPoint(pathResult, fieldPosition, lookAhead, closestPoint)
    closestPoint = closestPoint or 0 --default 0
    return math.min(closestPoint + lookAhead, #pathResult.path) --# is length operator
    --in case we are aiming PAST the end of the path, just aim at the end instead
end 

---@param point any
---@return number degAngle
function GetAngleToPoint(point)
    if point:length() == 0 then
        return 0
    end
    local angle = math.acos(point.y / point:length())
    return sign(point.x) * math.deg(angle)
end

---@param indexOfClosestPoint number
---@param indexOfGoalPoint number
---@param goalPoint any
---@return table result
function NewPurePursuitResult(indexOfClosestPoint, indexOfGoalPoint, goalPoint)
    local p = {
        indexOfClosestPoint = indexOfClosestPoint,
        indexOfGoalPoint = indexOfGoalPoint,
        goalPoint = goalPoint
    }
    return p
end

---@param pathResult table - the path we want to drive
---@param isBackwards boolean
---@return table result
function PurePursuit(pathResult, isBackwards)
    local indexOfClosestPoint = FindClosestPoint(pathResult, position, previousClosestPoint)
    local indexOfGoalPoint = FindGoalPoint(pathResult, position, 25, indexOfClosestPoint)
    local goalPoint = (pathResult.path[indexOfGoalPoint] - position):rotate(math.rad(navx:getAngle()))
    local angle
    if isBackwards then
        angle = -GetAngleToPoint(-goalPoint)
    else
        angle = GetAngleToPoint(goalPoint)
    end
    local turnValue = purePursuitPID:pid(-angle, 0)
    local speed = GetTrapezoidSpeed(0.5, 0.75, 0.5, pathResult.numberOfActualPoints, 4, 20, indexOfClosestPoint)
    if isBackwards then
        DifferentialDrive:arcadeDrive(-speed, -turnValue, false)
    else
        DifferentialDrive:arcadeDrive(speed, turnValue, false)
    end
    previousClosestPoint = indexOfClosestPoint

    return NewPurePursuitResult(indexOfClosestPoint, indexOfGoalPoint, goalPoint)
end
