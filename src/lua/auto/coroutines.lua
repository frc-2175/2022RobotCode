require("utils.path")
local taxiPath = orientPath(readPath("taxi"))
local pprint = require("utils.pprint")

doNothingAuto = FancyCoroutine:new(function()
	print("We are doing nothing in auto!!!")
end)

taxiAuto = FancyCoroutine:new(function ()
	local pathPursuit = PurePursuit:new(
		taxiPath,
		true,
		0.015, 0, 0.002
	)

	while true do
		local rotation, speed = pathPursuit:run()
		putNumber("Rotation", rotation)
		Drivetrain:drive(0.6 * speed, rotation)
		coroutine.yield(speed ~= 0)
	end
end)

shootBall = FancyCoroutine:new(function ()
	local cargoTimer = Timer:new()
	cargoTimer:start()
	while not cargoTimer:hasElapsed(1) do
		Intake:rollOut()
		coroutine.yield(true)
	end
	Intake:stop()
	coroutine.yield(false)
end)

oneBallAuto = FancyCoroutine:new(function()
	shootBall:reset()
	while shootBall:run() do coroutine.yield(true) end

	taxiAuto:reset()
	while taxiAuto:run() do coroutine.yield(true) end

	coroutine.yield(false)
end)

test("FancyCoroutine", function (t)
	local testTable = {}
	local appendOne = FancyCoroutine:new(function ()
		for i = 1, 3 do
			table.insert(testTable, 1)
			coroutine.yield(true)
		end
		coroutine.yield(false)
	end)
	local appendTwo = FancyCoroutine:new(function ()
		for i = 1, 3 do
			table.insert(testTable, 2)
			coroutine.yield(true)
		end
		coroutine.yield(false)
	end)
	local appendBoth = FancyCoroutine:new(function ()
		appendOne:reset()
		while appendOne:run() do
			coroutine.yield()
		end

		appendTwo:reset()
		while appendTwo:run() do
			coroutine.yield()
		end
	end)
	appendBoth:run()
	appendBoth:run()
	appendBoth:run()
	appendBoth:run()
	appendBoth:run()
	appendBoth:run()
	pprint(testTable)
end)