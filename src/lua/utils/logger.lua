local json = require("utils.json")
require("wpilib.time")

local file = io.open("C:/Users/Student/Documents/Repos/2022LogViewer/TestData/2.log", "w")

io.output(file)

local currentID = -1

function uniqueID()
	currentID = currentID + 1
	return currentID
end

function writeLine(table) 
	io.write(json.encode(table), "\n")
	io.flush()
end

local logMetatable = {
	stop = function(self)
		self.time = getFPGATimestamp()
		writeLine(self)
	end
}
logMetatable.__index = logMetatable

function log(message, parent)
	parent = parent or -1

	local log = {
		type = "event",
		message = message,
		id = uniqueID(),
		time = getFPGATimestamp(),
		parent = parent
	}
	setmetatable(log, logMetatable)

	writeLine(log)

	return log
end

local dataMetatable = {
	update = function(self, value)
		self.time = getFPGATimestamp()
		self.value = value
		writeLine(self)
	end
}
dataMetatable.__index = dataMetatable

function logData(name, value)
	local data = {
		type = "data",
		name = name,
		time = getFPGATimestamp(),
		value = value
	}
	setmetatable(data, dataMetatable)

	writeLine(data)

	return data
end