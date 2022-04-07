local taxiPath = orientPath(readPath("taxi"))

doNothingAuto = newFancyCoroutine(function()
	print("We are doing nothing in auto!!!")
end)

taxiAuto = newFancyCoroutine(function ()
	local pathPursuit = PurePursuit:new(
		taxiPath,
		true,
		0.015, 0, 0.002
	)

	while true do
		local rotation, speed = pathPursuit:run()
		putNumber("Rotation", rotation)
		Drivetrain:drive(0.6 * speed, rotation)
		coroutine.yield()
	end
end)

oneBallAuto = newFancyCoroutine(function()
	local cargoTimer = Timer:new()
	cargoTimer:start()
	while not cargoTimer:hasElapsed(2) do
		Intake:rollOut()
		coroutine.yield()
	end
	Intake:stop()

	taxiAuto:runWhile(true)
end)