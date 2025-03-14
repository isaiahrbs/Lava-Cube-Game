-- This file provides utility functions that can be used throughout the game.

local utils = {}

function utils.randomInRange(min, max)
    return math.random(min, max)
end

function utils.checkCollision(obj1, obj2)
	return obj1.x < obj2.x + obj2.width and
			obj1.x + obj1.width > obj2.x and
			obj1.y < obj2.y + obj2.height and
			obj1.y + obj1.height > obj2.y
end

function utils.clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

return utils
