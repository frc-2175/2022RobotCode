require("utils.vector")
require("utils.math")
local json = require("utils.json")
local dir = getDeployDirectory() .. "/paths/"
print(getDeployDirectory())

local EXTRA_POINTS = 24 -- this should probably equal LOOKAHEAD_DISTANCE

-- Oh boyo, here we go!

--- A way of moving a robot from a starting speed to a middle speed and then to an ending speed, ramping inbetween.
--- A graph of velocity over time would look like \_|/‾\\\_ with the `|` symbol representing time = 0.
---
--- This function takes 7 arguments:
--- - `startSpeed`, `middleSpeed`, and `endSpeed` are pretty self-explanatory.
--- - `totalDistance` is the total distance you want the 'trapezoid' shape to occur over.
--- - `rampUpDistance` and `rampDownDistance` are the distances along the 'trapezoid'
--- that the robot will start accelerating or decelerating.
--- - `currentDistance` is how far along the 'trapezoid' the robot already is.
---
--- Examples:
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, -1)` returns the startSpeed `0`
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 0)` returns the startSpeed `0`
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 0.5)` returns `0.5` which is halfway between the startSpeed `0` and the
--- middleSpeed `1` because currentDistance `0.5` is half of the rampUpDistance `1`
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 1.5)` returns the middleSpeed `1` because the currentDistance `1.5` is
--- after the rampUpDistance but before the totalDistance - rampDownDistance
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 2.5)` returns `0.75` which is halfway between the middleSpeed `1` and
--- endSpeed `0.5` because currentDistance `2.5` is halfway between totalDistance - rampDownDistance and totalDistance
--- - `getTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 3)` returns the endSpeed `0.5`
---@param startSpeed number
---@param middleSpeed number
---@param endSpeed number
---@param totalDistance number
---@param rampUpDistance number
---@param rampDownDistance number
---@param currentDistance number
---@return number speed
function getTrapezoidSpeed(
    startSpeed,
    middleSpeed,
    endSpeed,
    totalDistance,
    rampUpDistance,
    rampDownDistance,
    currentDistance
)
	if rampDownDistance + rampUpDistance > totalDistance then
		if currentDistance < 0 then
			return startSpeed
		elseif currentDistance < totalDistance then
			return endSpeed
		end

		return lerp(startSpeed, endSpeed, currentDistance / totalDistance)
	end

	if currentDistance < 0 then
		return startSpeed
	elseif currentDistance < rampUpDistance then
		return lerp(startSpeed, middleSpeed, currentDistance / rampUpDistance)
	elseif currentDistance < totalDistance - rampDownDistance then
		return middleSpeed
	elseif currentDistance < totalDistance then
		local rampDownStartDistance = (totalDistance - rampDownDistance)
		return lerp(middleSpeed, endSpeed, (currentDistance - rampDownStartDistance) / rampDownDistance)
	else
		return endSpeed
	end
end

---@class PathSegment
---@field endAng number
---@field path Vector[]
PathSegment = {}

--- Creates a new path segment, given an ending angle
--- in degrees, `endAng`, and a list of vectors, `path`.
---
--- Examples:
---  - `mySegment = newPathSegment(90, {})` creates
--- a new path segment(with an empty path table).
---  - `mySegment.path = {Vector:new(0, 0), Vector:new(1, 1)}`
--- sets the path of the new segment you made.
---  - `mySegment.path[1]` returns `Vector:new(0, 0)`.
---@param endAng number
---@param path Vector[]
---@return PathSegment
function PathSegment:new(endAng, path)
	local p = {
		endAng = endAng,
		path = path,
	}
	setmetatable(p, self)
	self.__index = self

	return p
end

---@return Vector
function PathSegment:getEndPoint()
	return self.path[#self.path]
end

---@param startpoint Vector
---@param endpoint Vector
---@return Vector[] path
function makePathLine(startpoint, endpoint)
	local numPoints = math.floor((endpoint - startpoint):length() + 0.5)
	local pathVector = (endpoint - startpoint):normalized()
	local path = {}
	for i = 1, numPoints, 1 do
		path[i] = pathVector * (i - 1) + startpoint
	end
	path[numPoints + 1] = endpoint
	return path
end

---@param dist number
---@return PathSegment
function makeLinePathSegment(dist)
	return PathSegment:new(0, makePathLine(Vector:new(0, 0), Vector:new(0, dist)))
end

---@param radius number
---@param deg number
---@return PathSegment PathSegment
function makeRightArcPathSegment(radius, deg)
	local circumfrence = 2 * math.pi * radius
	local distanceOfPath = circumfrence * (deg / 360)
	local yEndpoint = radius * math.sin(math.rad(deg))
	local xEndpoint = radius - (radius * math.cos(math.rad(deg)))
	local degreesPerInch = 360 / circumfrence
	local numPoints = math.floor(distanceOfPath + 2)
	local path = {}
	for i = 1, numPoints - 1 do
		local angle = (i - 1) * degreesPerInch
		local yPosition = radius * math.sin(math.rad(angle))
		local xPosition = radius - (radius * math.cos(math.rad(angle)))
		path[i] = Vector:new(xPosition, yPosition)
	end
	path[numPoints] = Vector:new(xEndpoint, yEndpoint)

	return PathSegment:new(-deg, path)
end

---@param radius number
---@param deg number
---@return PathSegment
function makeLeftArcPathSegment(radius, deg)
	local rightPath = makeRightArcPathSegment(radius, deg).path
	local leftPath = {}
	for i = 1, #rightPath do
		leftPath[i] = Vector:new(-rightPath[i].x, rightPath[i].y)
	end
	return PathSegment:new(deg, leftPath)
end

---@class Path
---@field path Vector[]
---@field numberOfActualPoints integer
Path = {}

---@param path Vector[]
---@param numberOfActualPoints integer
---@return Path path
function Path:new(path, numberOfActualPoints)
	local p = {
		path = path,
		numberOfActualPoints = numberOfActualPoints,
	}
	setmetatable(p, self)
	self.__index = self

	return p
end

function Path:print()
	for index, value in ipairs(self.path) do
		print(value)
	end
end

---@param isBackwards boolean
---@param startingAng number
---@param startingPos Vector
---@param pathSegments PathSegment[]
---@return Path path
function makePath(isBackwards, startingAng, startingPos, pathSegments)
	local finalPath = {}
	local previousAng = 0
	local previousPos = Vector:new(0, 0)
	-- add 25 points to the end so the robot knows where to look ahead
	local endingPoints = makeLinePathSegment(24)

	-- create table with all the pathSegments elements and add a new element for endingPoints
	local pathSegmentsList = pathSegments
	pathSegmentsList[#pathSegmentsList + 1] = endingPoints

	-- create one big table of vectors
	for index, aPathSegment in ipairs(pathSegmentsList) do
		for subindex, subvalue in ipairs(aPathSegment.path) do
			table.insert(finalPath, subvalue:rotate(previousAng) + previousPos)
		end
		previousPos = previousPos + aPathSegment:getEndPoint():rotate(previousAng)
		previousAng = previousAng + aPathSegment.endAng
	end

	if isBackwards then
		for i = 1, #finalPath do
			finalPath[i] = finalPath[i] * -1
		end
	end
	for i = 1, #finalPath do
		finalPath[i] = finalPath[i]:rotate(math.rad(startingAng)) + startingPos
	end

	local pathResult = Path:new(finalPath, #finalPath - #endingPoints.path)

	return pathResult
end

---@param fileName string
---@return Path
function readPath(fileName)
	---@type Vector[]
	local fileContents = json.decode(io.open(dir .. fileName .. ".path"):read("a")).points
	---@type Vector[]
	local resultPath = {}

	local a = Vector:new(fileContents[1].x,fileContents[1].y)
	local b = Vector:new(fileContents[2].x,fileContents[2].y)

	local firstSegment = b-a
	-- local start = Vector:new(fileContents[2].x, fileContents[2].y)
	-- local angleOffset = math.atan2(start.y, start.x)
	local angleOffset = math.atan2(-firstSegment.x, firstSegment.y)

	for i, value in ipairs(fileContents) do
		resultPath[i] = (Vector:new(value.x, value.y) - firstSegment):rotate(angleOffset)
	end

	local finalPoint = resultPath[#resultPath]
	local finalAng = math.atan2(finalPoint.y, finalPoint.x)

	for i = 1, EXTRA_POINTS do
		resultPath[#resultPath + 1] = resultPath[#resultPath] + Vector:new(math.cos(finalAng), math.sin(finalAng))
		finalPoint = resultPath[#resultPath]
	end

	return Path:new(resultPath, #resultPath - EXTRA_POINTS)
end
