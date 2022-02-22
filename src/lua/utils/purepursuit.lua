require("utils.vector")
require("utils.math")
require("utils.pid")
require("wpilib.ahrs")
require("wpilib.motors")

local TICKS_TO_INCHES = (6 * math.pi) / (2048 * 10)
navx = AHRS:new(4)
position = Vector:new(0, 0)
local angleOffset = navx:getAngle()

---@param path table - a pure pursuit path
---@param fieldPosition any - the robot's current position on the field
---@param previousClosestPoint number
---@return number indexOfClosestPoint
--[[
    looks through all points on the list, finds & returns the point
    closest to current robot position 
--]]
function findClosestPoint(path, fieldPosition, previousClosestPoint)
	local indexOfClosestPoint = 0
	local startIndex = previousClosestPoint - 36 -- 36 lookahead distance (in)
	local endIndex = previousClosestPoint + 36
	-- making sure indexes make sense
	if startIndex < 1 then   
		startIndex = 1
	end
	if endIndex > path.numberOfActualPoints then
		endIndex = path.numberOfActualPoints
	end
	local minDistance = (path.path[1] - fieldPosition):length() -- minimum distance you will have to travel
	for i = startIndex, endIndex do -- check through each point in list, and ...
		local distanceToPoint = (path.path[i] - fieldPosition):length()
		if distanceToPoint <= minDistance then
			indexOfClosestPoint = i
			minDistance = distanceToPoint -- if we find a closer one, that becomes the new minDist
		end
	end
	return indexOfClosestPoint
end

---@param path table - a pure pursuit path
---@param fieldPosition any - current robot position
---@param lookAhead number - number of indexes to look ahead in path
---@param closestPoint number - INDEX OF closest point in path to current position, basically where we are, ish
---@return number goalPoint - returns the index we should be aiming for

function findGoalPoint(path, fieldPosition, lookAhead, closestPoint)
	closestPoint = closestPoint or 0 -- default 0
	return math.min(closestPoint + lookAhead, #path.path) -- # is length operator
	-- in case we are aiming PAST the end of the path, just aim at the end instead
end

---@param point any
---@return number degAngle
function getAngleToPoint(point)
	if point:length() == 0 then
		return 0
	end
	local angle = math.acos(point.y / point:length())
	return sign(point.x) * math.deg(angle)
end

-- function getAverageEncoderDistance() 
-- 	return ((rightMotor:getSelectedSensorPosition() + leftMotor:getSelectedSensorPosition())/2)*TICKS_TO_INCHES
-- end

function trackLocation(leftMotor, rightMotor)
	-- first, get the distance we've traveled since last time trackLocation was called
	lastEncoderDistanceLeft = lastEncoderDistanceLeft or 0
	lastEncoderDistanceRight = lastEncoderDistanceRight or 0
	distanceLeft = leftMotor:getSelectedSensorPosition() * TICKS_TO_INCHES - lastEncoderDistanceLeft
	distanceRight = rightMotor:getSelectedSensorPosition() * TICKS_TO_INCHES - lastEncoderDistanceRight
	-- calculates avg distance traveled
	distance = (distanceLeft + distanceRight) / 2
	-- get our heading in radians
	angle = math.rad(navx:getAngle() - angleOffset)

	-- make a vector representing our change in position since last time
	x = math.sin(angle) * distance
	y = math.cos(angle) * distance

	changeInPosition = Vector:new(x, y)
	position = position + changeInPosition

	-- setting the "lastEncoderDistance" for next time
	lastEncoderDistanceLeft = leftMotor:getSelectedSensorPosition() * TICKS_TO_INCHES
	lastEncoderDistanceRight = rightMotor:getSelectedSensorPosition() * TICKS_TO_INCHES
end

function resetTracking()
	lastEncoderDistanceLeft = 0
	lastEncoderDistanceRight = 0
	zeroEncoderLeft = leftMotor:setSelectedSensorPosition(0)
	zeroEncoderRight = rightMotor:setSelectedSensorPosition(0)
	position = Vector:new(0, 0)
	angleOffset = navx:getAngle()
end

PurePursuit = {}
PurePursuit.__index = PurePursuit

function PurePursuit:new(path, isBackwards, p, i, d)
	local x = {
		path = path,
		isBackwards = isBackwards,
		previousClosestPoint = 0,
		purePursuitPID = PIDController:new(p, i, d),
	}
	setmetatable(x, PurePursuit)

	return x
end

---@return number turnValue, number speed
function PurePursuit:run()
	local indexOfClosestPoint = findClosestPoint(self.path, position, self.previousClosestPoint)
	local indexOfGoalPoint = findGoalPoint(self.path, position, 12, indexOfClosestPoint)
	local goalPoint = (self.path.path[indexOfGoalPoint] - position):rotate(math.rad(navx:getAngle()))
	local angle
	if self.isBackwards then
		angle = -getAngleToPoint(-goalPoint)
	else
		angle = getAngleToPoint(goalPoint)
	end
	local turnValue = self.purePursuitPID:pid(-angle, 0)
	local speed = getTrapezoidSpeed(
		0.5, 0.75, 0.5, self.path.numberOfActualPoints, 4, 20, indexOfClosestPoint
	)
	if self.isBackwards then
		turnValue = -turnValue
	end
	self.previousClosestPoint = indexOfClosestPoint

	local done = indexOfClosestPoint >= self.path.numberOfActualPoints

	return turnValue, speed, done
end
