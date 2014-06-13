local AdvTiledLoader = require("AdvTiledLoader.Loader")
require("camera")
require("entities")
require("player")
require("particlesystem")
Gamestate = require ("gamestate")

local menu = {}
local game = {}
dt = 0

function love.load()
	Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function menu:draw()
	love.graphics.print("I made a menu state for Project Brutality!", 300, 300)
    love.graphics.print("Press Enter to switch to game state.", 300, 320)
	love.graphics.print("Press Esc in game state to pause game and switch back to menu state.", 300, 340)
end

function menu:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(game)
    end
end

function game:init()
	love.graphics.setBackgroundColor( 220, 220, 255 )
	ents.Startup()
	setupPS()
	attackPS:stop()

	AdvTiledLoader.path = "maps/"
	map = AdvTiledLoader.load("map.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)

	camera:setBounds(0, 0, (map.width * map.tileWidth - (camera.sx * love.graphics.getWidth())), (map.height * map.tileHeight - (camera.sx * love.graphics.getHeight())) )
	
	world = 	{
				gravity = 1350,
				ground = 896,
				friction = -2500,
				}

	timer = 	{
				gameTime = 0,
				lastAttack = 0,
				attackCount = 1
				}

	ents.Create( "hellhound", 130, 784, false )
	ents.Create( "hellhound", 588, 784, false )
	ents.Create( "plaguewalker", 532, 784, false )
	ents.Create( "plaguewalker", 2576, 784, false )
	ents.Create( "hellhound", 1960, 684, false )

	ents.Create( "spike", 1120, 868, false )
	ents.Create( "spike", 1148, 868, false )
	ents.Create( "spike", 1176, 868, false )

	ents.Create( "movingplatform", 1680, 700, false)
	ents.Create("healthcheckpoint",308,532,false)
	ents.Create("soulgate",336+28,532-56,false)

	ents.Create( "axethrower", 1680, 756, false )
	--ents.Create( "axe", 1820, 600, false )
	ents.Create( "movingplatform", 1680, 700, false)

end

function game:draw()
	camera:set()

	love.graphics.setColor( 255, 255, 255 )
	map:draw()

	player:draw()

	ents:draw()

	love.graphics.draw(attackPS, player.x -  player.w, player.y + player.h/2)

	camera:unset()

	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Health: " .. player.health, 16, 16, 0, 1, 1 )

	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Lives: " .. player.lives, 16, 32, 0, 1, 1 )

	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.print ( "Brutality: " .. player.brutality.currentBrutality, 16, 48, 0, 1, 1 )
end

function game:update(dt)
	dt = dt
	timer.gameTime = timer.gameTime + dt

	if dt > 0.05 then
		dt = 0.05
	end
	
	player:update(dt)
	
	ents:update(dt)

	attackPS:update(dt)

	camera:setPosition( player.x - (love.graphics.getWidth()/(2/camera.sx)), player.y - (love.graphics.getHeight()/(2/camera.sx)))
end

function game:keypressed(key)
	print(dt)
	if key == " " then
		print(dt)
		player:jump(dt)
	end
	if key == "v" then
		attackPS:start()
		interval = timer.gameTime - timer.lastAttack
		print(interval)
		if interval <= 1.7 and interval >= 1.3 and timer.attackCount < 6 then
			timer.attackCount = timer.attackCount + 1
			print("Sequential attack "..timer.attackCount..".")
			if timer.attackCount >= 3 then
				player:setSequenceAttack(timer.attackCount)
				player:attack()
			else
				player:setBasicAttack()
				player:attack()
			end
		else
			timer.attackCount = 1
			player:setBasicAttack()
			player:attack()
		end
		timer.lastAttack = timer.gameTime
		player:setChargeTimer()
	end
	if key == "b" then
		player:teleport()
	end
	if key == "s" then
		player:duck()
	end
end

function game:keyreleased(key, code)
    if key == 'escape' then
        Gamestate.switch(menu)
    end
	if key == "s" then
		player:stand()
	end
	if key == "v" then
		player:chargedMelee()
	end
	if key == "q" then
		love.event.quit()
	end
end
