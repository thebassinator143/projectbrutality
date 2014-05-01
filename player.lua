require("entities")

player = 	{
				x = 1820,
				y = 673,
				x_vel = 0,
				y_vel = 0,
				acceleration = 15, 
				airacceleration = 4,
				jump_vel = -1024,
				speed = 366,
				flySpeed = 580,
				state = "",
				h = 54,
				w = 16,
				standing = false,
				health = 10,
				lives = 3,
				invincibilityRemaining = 0,
				damage = 1,
				image = love.graphics.newImage( "sprites/playersprite.png" ),
				facingright = true,
				facingleft = false,
				brutality = 0,
				meleeHitboxSize = 1.5,	-- * player.w
				teleHitboxSize = 7,	-- * player.w
				spriteOffset_x = -24,
				spriteOffset_y = -4
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
	if self.standing then
		self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
	else
		self.x_vel = self.x_vel + (self.airacceleration * self.speed * dt)
	end
end
	
function player:left(dt)
	self.facingleft = true
	self.facingright = false
	if self.standing then
		self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
	else
		self.x_vel = self.x_vel - (self.airacceleration * self.speed * dt)
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
	   if self.x_vel <= (world.friction * dt) then
	     self.x_vel = 0
     else
       self.x_vel = self.x_vel + (world.friction * dt)
     end
   elseif self.x_vel < 0 then
     if self.x_vel >= (world.friction * dt) then
       self.x_vel = 0
     else
       self.x_vel = self.x_vel - (world.friction * dt)
     end
   else
     self.x_vel = 0
   end
  end
		
	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
	
	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		if not (self:isColliding(map, self.x, nextY))
			and not (self:isColliding(map, self.x + self.w - 1, nextY)) then
			self.y = nextY
			self.standing = false
		else
			self.y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			self:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (self:isColliding(map, self.x, nextY + self.h))
			and not(self:isColliding(map, self.x + self.w - 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + self.w - 1, nextY + self.h)) then
				self.y = nextY
				self.standing = false
		else
			self.y = nextY - ((nextY + self.h) % map.tileHeight)
			self:collide("floor")
		end
	end
		
	local nextX = self.x + (self.x_vel * dt)
	if self.x_vel > 0 then
		if not(self:isColliding(map, nextX + self.w, self.y))
			and not(self:isColliding(map, nextX + self.w, self.y + self.h - 1)) then
			self.x = nextX
		else
			self.x = nextX - ((nextX + self.w) % map.tileWidth)
		end
	elseif self.x_vel < 0 then
		if not(self:isColliding(map, nextX, self.y)) 
			and not(self:isColliding(map, nextX, self.y + self.h - 1)) then 
			self.x = nextX
		else
			self.x = nextX + map.tileWidth - ((nextX) % map.tileWidth) 	
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
	love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )   --Player bounding box
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 1, 0, 0, 0, 0 ) --Player sprite
	
	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x - (self.w*self.meleeHitboxSize), self.y, self.w*self.meleeHitboxSize, self.h)   --Left melee hitbox
	
	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x + self.w, self.y, self.w*self.meleeHitboxSize, self.h)  --Right melee hitbox
	
	love.graphics.setColor( 0, 255, 0, 255)
	love.graphics.rectangle("fill", self.x - (self.w*self.teleHitboxSize), self.y, self.w*self.teleHitboxSize, self.h)   --Left teleport hitbox
	 
	love.graphics.setColor( 0, 255, 0, 255 )
	love.graphics.rectangle("fill", self.x + self.w, self.y, self.w*self.teleHitboxSize, self.h)   --Right teleport hitbox
end

function player:melee()
	if self.facingright then
		print("swing right!")
		for i, ent in pairs(ents.objects) do
			if ent.x > self.x + self.w and ent.x < self.x + self.w*(self.meleeHitboxSize + 1)
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then				
				if ent.type == "hellhound" or "axethrower" then	
					ent:Damage(1)
					print("hit!")
				end
			end
		end
	elseif self.facingleft then
		print("swing left!")
		for i, ent in pairs(ents.objects) do
			if ent.x + ent.w > self.x - self.w*self.meleeHitboxSize and ent.x + ent.w < self.x
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then
				if ent.type == "hellhound" or "axethrower" then
					ent:Damage(1)
					print("hit!")
				end
			end
		end
	end
end

function player:teleport()
	if self.facingright then
		print("teleport right!")
		for i, ent in pairs(ents.objects) do
			if ent.x > self.x + self.w and ent.x < self.x + self.w*(self.teleHitboxSize + 1)
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then	
				if ent.type == "hellhound" then
					ydiff = self.h - ent.h
					xdiff = ent.w - self.w
					ent.x, self.x = self.x, ent.x + xdiff
					ent.y, self.y = self.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
	if self.facingleft then
		print("teleport left!")
		for i, ent in pairs(ents.objects) do
			if ent.x + ent.w > self.x - self.w*self.teleHitboxSize and ent.x + ent.w < self.x
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then
				if ent.type == "hellhound" then
					ydiff = self.h - ent.h
					xdiff = ent.w - self.w
					ent.x, self.x = self.x - xdiff, ent.x
					ent.y, self.y = self.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
end