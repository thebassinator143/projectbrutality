require("entities")

WALK = 300
WALKACCEL = 13 + 1/3
WALKAIRACCEL = 4 + 2/3

RUNRATIO = 1 + 1/3									 --Ratio based on WALK that determines RUN
RUN = (RUNRATIO) * WALK                              
RUNACCEL = (WALK/RUN) * WALKACCEL					 --Formula ensures rate of acceleration remains fixed whether walking or running
RUNAIRACCEL = (WALK/RUN) * WALKAIRACCEL

REACTIVITY = 0.75									 --Modifies running deceleration without affecting acceleration

HEIGHT = 54
DUCKHEIGHT = HEIGHT/2

player = 	{
				x = 1820,
				y = 700,
				x_vel = 0,
				y_vel = 0,
				acceleration = WALKACCEL, 
				airacceleration = WALKAIRACCEL,
				reactivity = REACTIVITY * (WALKACCEL - RUNACCEL),
				jump_vel = -1024,
				speed = WALK,
				flySpeed = 580,
				slidefriction = 0.25,
				state = "",
				h = HEIGHT,
				w = 16,
				running = false,
				standing = false,
				ducking = false,
				health = 10,
				lives = 3,
				invincibilityRemaining = 0,
				damage = 1,
				image = love.graphics.newImage( "sprites/playersprite.png" ),
				facingright = true,
				facingleft = false,
				brutality = 0,
				}
				
function player:jump()
	if self.standing then
		self.y_vel = self.jump_vel
		self.standing = false
	end
end
	
function player:right(dt)
	self.facingright = true
	self.facingleft = false
	if not self.ducking then
		if self.standing then
			if self.running then
				if self.x_vel < 0 then
					self.x_vel = self.x_vel + ((self.acceleration + self.reactivity) * self.speed * dt)
				else
					self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
				end
			else	
				self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
			end
		else
			self.x_vel = self.x_vel + (self.airacceleration * self.speed * dt)
		end
	end
end
	
function player:left(dt)
	self.facingleft = true
	self.facingright = false
	if not self.ducking then
		if self.standing then
			if self.running then
				if self.x_vel > 0 then
					self.x_vel = self.x_vel - ((self.acceleration + self.reactivity) * self.speed * dt)
				else
					self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
				end
			else
				self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
			end
		else
			self.x_vel = self.x_vel - (self.airacceleration * self.speed * dt)
		end
	end
end

function player:duck()
	if self.standing then
		self.h = DUCKHEIGHT
		self.y = self.y + self.h
		self.ducking = true
	end
end

function player:stand()
	self.h = HEIGHT
	self.ducking = false
end
	
function player:stop()
	self.x_vel = 0
end
	
function player:collide(event)
	if event == "floor" then
		self.y_vel = 0
		self.standing = true
	end
	if event == "ceiling" then
		self.y_vel = 0
	end
end
	
function player:die()
	self.x = 256
	self.y = 256
	self.lives = self.lives - 1
	self.health = 10
	
	--self.x_vel = 0  --Freeze for better visual collision check
	--self.y_vel = 0
end
	
function player:damage(n)
	if self.invincibilityRemaining <= 0 then
		if (n >= 0) then
			self.health = self.health - n
			self.invincibilityRemaining = 1
		end
	end
	if self.health <= 0 then
		self.health = 0
		self:die()
	end
end
		
function player:update(dt)
	local halfX = self.w / 2
	local halfY = self.h / 2
	
	print(self.x_vel)
	
	if love.keyboard.isDown("lshift") then
		self.speed = RUN
		self.acceleration = RUNACCEL
		self.airacceleration = RUNAIRACCEL
		self.running = true
	else
		self.speed = WALK
		self.acceleration = WALKACCEL
		self.airacceleration = WALKAIRACCEL
		self.running = false
	end
	
	if love.keyboard.isDown("d") then
		self:right(dt)
	end
	if love.keyboard.isDown("a") then
		self:left(dt)
	end
	--if love.keyboard.isDown(" ") and not(hasJumped) then
	--	self:jump()
	--end
	
	if self.brutality >= 100 then
		self.brutality = 100
	end
	
	if self.invincibilityRemaining <= 0 then
		self.invincibilityRemaining = 0
	else 
		self.invincibilityRemaining = self.invincibilityRemaining - dt
	end
	
	if self.y > world.ground + self.h then
		self:die()
	end
		
	self.y_vel = self.y_vel + (world.gravity * dt)
	
	if self.standing then
		if self.x_vel > 0 then
			if self.ducking then
				if self.x_vel <= (self.slidefriction * world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel + (self.slidefriction * world.friction * dt)
				end
			else
				if self.x_vel <= (world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel + (world.friction * dt)
				end
			end
		elseif self.x_vel < 0 then
			if self.ducking then
				if self.x_vel >= (self.slidefriction * world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel - (self.slidefriction * world.friction * dt)
				end
			else	
				if self.x_vel >= (world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel - (world.friction * dt)
				end
			end	
		else
			self.x_vel = 0
		end
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
			self:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (self:isColliding(map, self.x-halfX, nextY + halfY))
			and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY))
			and not(self:isOneWayColliding(map, self.x-halfX, nextY + halfY))
			and not(self:isOneWayColliding(map, self.x + halfX - 1, nextY + halfY)) then
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

function player:isOneWayColliding(map, x, y)
	local layer = map.tl["oneWayPlatforms"]
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

function player:draw()
	love.graphics.setColor( 25, 25, 25, 255 )
	love.graphics.rectangle( "fill", (self.x - self.w/2), (self.y - self.h/2), self.w, self.h )   --Player hitbox
	
	if self.ducking then
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 0.5, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 0.5, 0, 0, 0, 0 )
		end
	else
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )
		end
	end
	
	
	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", (self.x - (self.w*2)), (self.y - self.h/2), (self.w*1.5), (self.h))   --Left melee hitbox
	
	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", (self.x + self.w/2), (self.y - self.h/2), (self.w*1.5), (self.h))  --Right melee hitbox
	
	--love.graphics.setColor( 0, 255, 0, 255)
	--love.graphics.rectangle("fill", (self.x - (self.w*1.5)-81), (self.y - self.h/4), self.w+81, self.h/2)   --Left teleport hitbox
	 
	--love.graphics.setColor( 0, 255, 0, 255 )
	--love.graphics.rectangle("fill", (self.x + self.w/2), (self.y - self.h/4), self.w + 81, self.h/2)   --Right teleport hitbox
end

function player:melee()
	if self.facingright then
		print("swing right!")
		for i, ent in pairs(ents.objects) do
			if (self.x + self.w/2)+22 < ent.x + ent.w 
			and ((self.x + self.w/2)+22 + (self.w * 1.5)) > ent.x
			and (self.y - self.h/2) < ent.y + ent.h
			and ((self.y - self.h/2) + self.h) > ent.y then
				if ent.type == "hellhound" or "axethrower" then
					ent:Damage(1)
					print("hit!")
				else
					ent:Damage(0)
					print("If you really were a boss, you would've deflected it. But you're not.")
				end
			end
		end
	elseif self.facingleft then
		print("swing left!")
		for i, ent in pairs(ents.objects) do
			if (self.x - (self.w*2)) < ent.x + ent.w 
			and ((self.x - (self.w*2)) + (self.w * 1.5)) > ent.x
			and (self.y - self.h/2) < ent.y + ent.h
			and ((self.y - self.h/2) + self.h) > ent.y then
				if ent.type == "hellhound" or "axethrower" then
					ent:Damage(1)
					print("hit!")
				else
					ent:Damage(0)
					print("If you really were a boss, you would've deflected it. But you're not.")
				end
			end
		end
	end
end

function player:teleport()
	if self.facingright then
		print("teleport right!")
		for i, ent in pairs(ents.objects) do
			if ((self.x + self.w/2) + 21) < ent.x + ent.w
			and (((self.x + self.w/2) + 21) + (self.w + 81)) > ent.x
			and (self.y - (self.h/4)) < ent.y + ent.h
			and ((self.y - (self.h/4)) + self.h/2) > ent.y then
				if ent.type == "hellhound" then
					ent.x, player.x = player.x, ent.x
					ent.y, player.y = player.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
	if self.facingleft then
		print("teleport left!")
		for i, ent in pairs(ents.objects) do
			if (self.x - 83) < ent.x + ent.w
			and (((self.x - 83) - (self.w * 1.5)) + (self.w + 81)) > ent.x
			and (self.y - (self.h/4)) < ent.y + ent.h
			and ((self.y - (self.h/4)) + self.h/2) > ent.y then
				if ent.type == "hellhound" then
					ent.x, player.x = player.x, ent.x
					ent.y, player.y = player.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
end
