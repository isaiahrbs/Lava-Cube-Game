-- creating an empty table, similar to a struct in C
local game = {}

local config = require("config")
local utils = require("utils")
local obstacles = require("obstacles")

local player = {
    x = config.windowWidth / 2,		-- Start horizontally centered.
    y = 0,							-- Will be positioned on the platform in initialize.
    width = 30,						-- Player width in pixels.
    height = 30,					-- Player height in pixels.
    speed = 300,					-- Movement speed in pixels per second.
    vy = 0,							-- Vertical velocity (for jumping/falling).
    gravity = 1000,					-- Gravity acceleration.
    jumpStrength = -400,			-- Faster jump.
    onGround = true					-- Flag to check if the player is on the ground.
}

-- New variables for lava:
local lavaHeight = 20

-- Platform dimensions and position:
local platformWidth = 300				-- Desired width of the platform.
local platformHeight = 10				-- Platform thickness.
local platformX = (config.windowWidth - platformWidth) / 2	-- Center the platform.
-- Platform is 4 cubes (player.height) above lava:
local platformY = config.windowHeight - (lavaHeight + 4 * player.height)

-- New game state variable: "playing", "gameover", or "win"
local gameState = "playing"

-- Timer to track how long the player has survived (in seconds)
local aliveTime = 0

function game.initialize()
	player.x = config.windowWidth / 2
	-- Position the player on the platform (so its bottom rests on the platform)
	player.y = platformY - player.height
	player.vy = 0
	player.onGround = true
	gameState = "playing"
	aliveTime = 0
	-- Initialize obstacles
	obstacles.initialize()
end

-- d_time means delta time, the time elapsed since the last frame
function game.update(d_time)
	if gameState == "playing" then
		-- Update survival timer.
		aliveTime = aliveTime + d_time
		if aliveTime >= 20 then
			-- Win condition: player survived 20 seconds.
			gameState = "win"
		end

		-- Handle left/right movement:
		if love.keyboard.isDown("left") then
			player.x = player.x - player.speed * d_time
		elseif love.keyboard.isDown("right") then
			player.x = player.x + player.speed * d_time
		end

		-- Apply gravity if the player is in the air:
		if not player.onGround then
			player.vy = player.vy + player.gravity * d_time
			player.y = player.y + player.vy * d_time
		end

		-- Check landing on the platform (only land if within horizontal bounds):
		if player.y + player.height >= platformY and
			player.x + player.width > platformX and
			player.x < platformX + platformWidth then
			player.y = platformY - player.height
			player.vy = 0
			player.onGround = true
		else
			player.onGround = false
		end

		-- Only check lava collision if win condition not reached.
		if aliveTime < 20 then
			if player.y + player.height > config.windowHeight - lavaHeight then
				gameState = "gameover"
			end
		end

		-- Update obstacles and check collisions.
		obstacles.update(d_time)
		local i = 1
		while i <= #obstacles.list do
			local obs = obstacles.list[i]
			if utils.checkCollision(player, obs) then
				gameState = "gameover"
			end
			i = i + 1
		end

	elseif gameState == "win" then
		-- Stop obstacles when player wins.
		obstacles.list = {}
	end
end

function game.draw()
	if gameState == "playing" then
		-- Draw the player cube.
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

		-- Draw the platform (gray with black edges).
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.rectangle("fill", platformX, platformY, platformWidth, platformHeight)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", platformX, platformY, platformWidth, platformHeight)

		-- Draw the lava (an orange rectangle) at the bottom.
		love.graphics.setColor(1, 0.3, 0)
		love.graphics.rectangle("fill", 0, config.windowHeight - lavaHeight, config.windowWidth, lavaHeight)

		-- Draw obstacles.
		obstacles.draw()

		-- Display timer at the top of the screen.
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Time: " .. string.format("%.2f", aliveTime) .. "s", 10, 10)

	elseif gameState == "gameover" then
		-- Display game over text and the record time.
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("Game Over! Press R or Down Arrow to Play Again", 0, config.windowHeight / 2 - 10, config.windowWidth, "center")
		love.graphics.printf("Your Time: " .. string.format("%.2f", aliveTime) .. "s", 0, config.windowHeight / 2 + 20, config.windowWidth, "center")

	elseif gameState == "win" then
		-- Display win text.
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("YOU WIN!", 0, config.windowHeight / 2 - 30, config.windowWidth, "center")
		love.graphics.print("Time: " .. string.format("%.2f", aliveTime) .. "s", 10, 10)
	end
end

function game.keypressed(key)
	if gameState == "playing" then
		if key == "up" and player.onGround then
			player.vy = player.jumpStrength
			player.onGround = false
		end
	elseif gameState == "gameover" or gameState == "win" then
		-- Restart the game if the user presses "r" or the down arrow.
		if key == "r" or key == "down" then
			game.initialize()
		end
	end
end

return game
