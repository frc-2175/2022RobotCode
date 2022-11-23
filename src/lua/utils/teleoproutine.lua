require("utils.autoroutine")

---@class TeleopRoutine
---@field autoRoutine AutoRoutine
---@field wasRunning boolean
TeleopRoutine = {}

---@param routine function|AutoRoutine
---@return TeleopRoutine
function TeleopRoutine:new(routine)
	if type(routine) == "function" then
		routine = AutoRoutine:new(routine)
	end

	local t = {
		autoRoutine = routine,
		wasRunning = false,
	}
	setmetatable(t, self)
	self.__index = self

	return t
end

function TeleopRoutine:reset()
	self:runWhile(false)
end

function TeleopRoutine:run()
	return self:runWhile(true)
end

function TeleopRoutine:runWhile(running)
	if running then
		if not self.wasRunning then
			self.autoRoutine:reset()
		end
		self.autoRoutine:tick()
	end
	self.wasRunning = running
	return running
end

-- patch AutoRoutine to add the ability to "teleopify" it
-- (we have to do it here to avoid a circular import)

function AutoRoutine:teleopify()
	return TeleopRoutine:new(self)
end
