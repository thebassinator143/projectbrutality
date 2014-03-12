local AdvTiledLoader = require("AdvTiledLoader.Loader")
require("camera")
require("entities")
require("player")

function love.load()
	love.graphics.setBackgroundColor( 220, 220, 255 )
	ents.Startup()
	
	AdvTiledLoader.path = "maps/"
	map = AdvTiledLoader.load("map.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
	
	camera:setBounds(0, 0, (map.width * map.tileWidth - (0.5 * love.graphics.getWidth())), (map.height * map.tileHeight - (0.5*love.graphics.getHeight())) )

	world = 	{
				gravity = 1536,
				ground = 896,
				friction = -2000
				}
	ents.Create( "hellhound", 130, 784, false )
	ents.Create( "hellhound", 2576, 784, false )
	ents.Create( "hellhound", 1960, 684, false )

	ents.Create( "spike", 1120, 868, false )
	ents.Create( "spike", 1148, 868, false )
	ents.Create( "spike", 1176, 868, false )
	
	ents.Create( "axethrower", 1680, 756, false )
	--ents.Create( "axe", 1820, 600, false )
end

function love.draw()
	camera:set()
	
	love.graphics.setColor( 255, 255, 255 )
	map:draw()
	
	player:draw()
	
	ents:draw()
	
	--player:draw()
	
	camera:unset()
	
	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Health: " .. player.health, 16, 16, 0, 1, 1 )
	
	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Lives: " .. player.lives, 16, 32, 0, 1, 1 )
	
	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Brutality: " .. player.brutality, 16, 48, 0, 1, 1 )
end

function love.update(dt)
	if dt > 0.05 then
		dt = 0.05
	end
	if love.keyboard.isDown("d") then
		player:right()
	end
	if love.keyboard.isDown("a") then
		player:left()
	end
	--if love.keyboard.isDown(" ") and not(hasJumped) then
	--	player:jump()
	--end
	
	player:update(dt)
	
	ents:update(dt)
	
	camera:setPosition( player.x - (love.graphics.getWidth()/(2/0.5)), player.y - (love.graphics.getHeight()/(2/0.5)))
end

function love.keypressed(key)
	if key == " " then
		player:jump()
	end
	if key == "v" then
		player:melee()
	end
	if key == "b" then
		player:teleport()
	end
end