local AdvTiledLoader = require("AdvTiledLoader.Loader")
require("camera")

function love.load()
	love.graphics.setBackgroundColor( 220, 220, 255 )
	AdvTiledLoader.path = "maps/"
	map = AdvTiledLoader.load("map.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
	
	camera:setBounds(0, 0, (map.width * map.tileWidth - (0.65 * love.graphics.getWidth())), (map.height * map.tileHeight - (0.65*love.graphics.getHeight())) )

	world = 	{
				gravity = 1536,
				ground = 896,
				friction = -2000
				}
				
	player = 	{
				x = 256,
				y = 256,
				x_vel = 0,
				y_vel = 0,
				acceleration = 0.06,
				airacceleration = 0.02,
				jump_vel = -1024,
				speed = 416,
				flySpeed = 700,
				state = "",
				h = 54,
				w = 16,
				standing = false,
				health = 10,
				lives = 3,
				image = love.graphics.newImage( "sprites/playersprite.png" )
				}
	function player:jump()
		if self.standing then
			self.y_vel = self.jump_vel
			self.standing = false
		end
	end
	
	function player:right()
		if self.standing then
			self.x_vel = self.x_vel + (self.acceleration * self.speed)
		else
			self.x_vel = self.x_vel + (self.airacceleration * self.speed)
		end
	end
	
	function player:left()
		if self.standing then
			self.x_vel = self.x_vel - (self.acceleration * self.speed)
		else
			self.x_vel = self.x_vel - (self.airacceleration * self.speed)
		end
	end
	
	function player:stop()
		self.x_vel = 0
	end
	
	function player:collide(event)
		if event == "floor" then
			self.y_vel = 0
			self.standing = true
		end
		if event == "cieling" then
			self.y_vel = 0
		end
		if event == "spike" then
			self:damage(spike.damage)
		end
	end
	
	function player:die()
		self.x = 256
		self.y = 256
	end
	
	function player:damage(n)
		if (n <= 0) then
			self.health = self.health - n
		end
		if self.health <= 0 then
			self.health = 0
			self:die()
		end
	end
	
	function player:update(dt)
		local halfX = self.w / 2
		local halfY = self.h / 2
		
		if self.y > world.ground then
			self:die()
		end
		
		self.y_vel = self.y_vel + (world.gravity * dt)
		
		if self.standing and self.x_vel > 0 then
			self.x_vel = self.x_vel + (world.friction * dt)
		else 
			self.x_vel = self.x_vel
		end
		
		if self.standing and self.x_vel < 0 then
			self.x_vel = self.x_vel - (world.friction * dt)
		else
			self.x_vel = self.x_vel
		end
		
		self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
		self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
		
		local nextY = self.y + (self.y_vel*dt)
		if self.y_vel < 0 then
			if not (self:isColliding(map, self.x - halfX, nextY - halfY))
				and not (self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
				self.y = nextY
				self.standing = false
			else
				self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
				self:collide("cieling")
			end
		end
		if self.y_vel > 0 then
			if not (self:isColliding(map, self.x-halfX, nextY + halfY))
				and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
					self.y = nextY
					self.standing = false
			else
				self.y = nextY - ((nextY + halfY) % map.tileHeight)
				self:collide("floor")
			end
		end
		
		local nextX = self.x + (self.x_vel * dt)
		if self.x_vel > 0 then
			if not(self:isColliding(map, nextX + halfX, self.y - halfY))
				and not(self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
				self.x = nextX
			else
				self.x = nextX - ((nextX + halfX) % map.tileWidth)
			end
		elseif self.x_vel < 0 then
			if not(self:isColliding(map, nextX - halfX, self.y - halfY))
				and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
				self.x = nextX
			else
				self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
			end
		end
		
		self.state = self:getState()
	end
	
	function player:isColliding(map, x, y)
		local layer = map.tl["Solid"]
		local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		return not(tile == nil)
	end
	
	function player:getState()
		local tempState = ""
		if self.standing then
			if self.x_vel > 0 then
				tempState = "right"
			elseif self.x_vel < 0 then
				tempState = "left"
			else
				tempState = "stand"
			end
		end
		if self.y_vel > 0 then
			tempState = "fall"
		elseif self.y_vel < 0 then
			tempState = "jump"
		end
		return tempState
	end
	
end

function love.draw()
	camera:set()
	
	love.graphics.setColor( 255, 255, 255 )
	map:draw()
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( player.image, (player.x - player.w/2) - 24, (player.y - player.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )
	
	camera:unset()
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
	if love.keyboard.isDown(" ") and not(hasJumped) then
		player:jump()
	end
	
	player:update(dt)
	
	camera:setPosition( player.x - (love.graphics.getWidth()/(2/0.65)), player.y - (love.graphics.getHeight()/(2/0.65)))
end

function love.keyreleased(key)
end