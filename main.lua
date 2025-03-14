-- This file is the entry point of the game. It initializes the game environment, loads necessary modules, and starts the game loop.

local game = require("game")
local utils = require("utils")
local config = require("config")

function love.load()
	-- Initialize game settings
	love.window.setTitle("Lava Cube")
	love.window.setMode(config.windowWidth, config.windowHeight)
	game.initialize()
end

function love.update(dt)
	game.update(dt)
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	game.keypressed(key)
end
