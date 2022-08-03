require("utils.path")
local taxiPath = orientPath(readPath("taxi"))
local autoPath1 = orientPath(readPath("auto1"))
local autoPath2 = orientPath(readPath("auto2"))
local pprint = require("utils.pprint")

doNothingAuto = FancyCoroutine:new(function()
	print("We are doing nothing in auto!!!")
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