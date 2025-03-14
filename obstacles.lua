local obstacles = {}
local config = require("config")
math.randomseed(os.time())

obstacles.list = {}
local spawnTimer = 0
local spawnInterval = 0.0625  -- quadruple the quantity by spawning every 0.0625 seconds

function obstacles.initialize()
	-- Reset the obstacle list and spawn timer.
	obstacles.list = {}
	spawnTimer = 0
end

function obstacles.update(dt)
	-- Increase spawn timer.
	spawnTimer = spawnTimer + dt
	-- When it's time, spawn a new obstacle.
	if spawnTimer >= spawnInterval then
		spawnTimer = 0
		-- Random width and height.
		local obsWidth = math.random(20, 50)
		local obsHeight = math.random(20, 50)
		-- Spawn at a random x position, and just above the visible screen.
		local newObs = {
			x = math.random(0, config.windowWidth - obsWidth),
			y = -obsHeight,  -- just above the screen
			width = obsWidth,
			height = obsHeight,
			speed = math.random(250, 400)  -- falling speed for more aggression
		}
		table.insert(obstacles.list, newObs)
	end

	-- Update obstacles positions using a while loop.
	local i = 1
	while i <= #obstacles.list do
		local obs = obstacles.list[i]
		-- Move each obstacle downwards.
		obs.y = obs.y + obs.speed * dt
		-- Remove obstacles that have fallen off the bottom of the screen.
		if obs.y > config.windowHeight then
			table.remove(obstacles.list, i)
		else
			i = i + 1
		end
	end
end

function obstacles.draw()
	-- Draw obstacles using a while loop.
	local i = 1
	while i <= #obstacles.list do
		local obs = obstacles.list[i]
		-- Set color to match lava (orange).
		love.graphics.setColor(1, 0.3, 0)
		love.graphics.rectangle("fill", obs.x, obs.y, obs.width, obs.height)
		i = i + 1
	end
end

return obstacles
