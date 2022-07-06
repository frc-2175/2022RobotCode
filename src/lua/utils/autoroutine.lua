---@class AutoRoutine
---@field f function
---@field co thread
---@field done boolean
AutoRoutine = {}

---@param f? function
---@return AutoRoutine
function AutoRoutine:new(f)
	-- A little weird, but: this allows us to "clone" a routine by calling :new on it.
	if not f then
		return AutoRoutine:new(self.f)
	end

	local o = {
		f = f,
		co = nil,
		done = false,
	}
	setmetatable(o, self)
	self.__index = self

	o:reset()

	return o
end

function AutoRoutine:reset()
	self.co = coroutine.create(self.f)
	self.done = false
end

function AutoRoutine:tick()
	if self.done then
		return
	end

	local success, err = coroutine.resume(self.co)
	if not success then
		error(err)
		self.done = true
		return
	end

	if coroutine.status(self.co) == "dead" then
		self.done = true
	end
end

--
-- Tests
--

test("auto routine, one", function(t)
	local results = {}
	local auto = AutoRoutine:new(function()
		table.insert(results, 1)
		table.insert(results, 2)
		coroutine.yield()
		table.insert(results, 3)
	end)

	t:assertEqual(results, {})
	auto:tick()
	t:assertEqual(results, { 1, 2 })
	auto:tick()
	t:assertEqual(results, { 1, 2, 3 })

	-- Ticking again has no effect and no error
	auto:tick()
	t:assertEqual(results, { 1, 2, 3 })
end)

test("auto routine, error", function(t)
	local results = {}
	local auto = AutoRoutine:new(function()
		table.insert(results, 1)
		coroutine.yield()
		error("oh no")
	end)

	t:assertEqual(results, {})
	auto:tick()
	t:assertEqual(results, { 1 })

	t:assertDoesError(function()
		auto:tick()
	end)
end)

test("auto routine, nested", function(t)
	local results = {}
	local piece1 = AutoRoutine:new(function()
		for i = 1, 3 do
			table.insert(results, "p1/" .. i)
			coroutine.yield()
		end
	end)
	local piece2 = AutoRoutine:new(function()
		for i = 1, 2 do
			table.insert(results, "p2/" .. i)
			coroutine.yield()
		end
	end)
	local auto = AutoRoutine:new(function()
		local p1_1 = piece1:new()
		local p1_2 = piece1:new()
		local p2 = piece2:new()
		for i = 1, 5 do
			table.insert(results, "auto/" .. i)
			p1_1:tick()
			p1_2:tick()
			p2:tick()
			coroutine.yield()
		end
	end)

	t:assertEqual(results, {})
	auto:tick()
	t:assertEqual(results, { "auto/1", "p1/1", "p1/1", "p2/1" })
	auto:tick()
	t:assertEqual(results, { "auto/1", "p1/1", "p1/1", "p2/1", "auto/2", "p1/2", "p1/2", "p2/2" })
	auto:tick()
	t:assertEqual(results,
		{ "auto/1", "p1/1", "p1/1", "p2/1", "auto/2", "p1/2", "p1/2", "p2/2", "auto/3", "p1/3", "p1/3" })
	auto:tick()
	t:assertEqual(results,
		{ "auto/1", "p1/1", "p1/1", "p2/1", "auto/2", "p1/2", "p1/2", "p2/2", "auto/3", "p1/3", "p1/3", "auto/4" })
	auto:tick()
	t:assertEqual(results,
		{ "auto/1", "p1/1", "p1/1", "p2/1", "auto/2", "p1/2", "p1/2", "p2/2", "auto/3", "p1/3", "p1/3", "auto/4", "auto/5" })

	-- one more tick for old times' sake
	auto:tick()
	t:assertEqual(results,
		{ "auto/1", "p1/1", "p1/1", "p2/1", "auto/2", "p1/2", "p1/2", "p2/2", "auto/3", "p1/3", "p1/3", "auto/4", "auto/5" })
end)
