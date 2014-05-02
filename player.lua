require("entities")

player = 	{
				x = 1820,
				y = 700,
				x_vel = 0,
				y_vel = 0,
				acceleration = 0.1,
				airacceleration = 0.02,
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
				delay = 0,
				ability =	{ 
					delay = 0, 
					damage = 0, 
					knockback = {
						x = 0, 
						y = 0
						}, 
					enemyDelay = 0, 
					hitbox = {
						x = 0, 
						y = 0, 
						width = 0, 
						height = 0
						} 
					}
				}
function player:attack()
	--[[
	--Prequisite: set the following values: unset values are default to 0
	ability.delay
	ability.damage
	ability.knockback.x
	ability.knockback.y
	ability.enemyDekay
	ability.hitbox.x
	ability.hitbox.y
	ability.hitbox.width
	ability.hitbox.height
	--All values are set to 0 after attack is called.
	--]]
	if self.delay <= 0 then --delay is a global cooldown period where the player cannot use skills, generally this means they are still animating a skill and cant use another.
		for i, ent in pairs(ents.objects) do
			if not ent.BG then
				if self.facingright then
					--Collision Detection
					if (ent.x < self.x + self.ability.hitbox.x + self.ability.hitbox.width) and (ent.x + ent.w > self.x + self.ability.hitbox.x) and (ent.y < self.y + self.ability.hitbox.y + self.ability.hitbox.height) and (ent.y + ent.h > self.y + self.ability.hitbox.y) then
						ent.health = ent.health - self.ability.damage     --Apply Damage
						ent.y_vel = ent.y_vel + self.ability.knockback.y  --Apply Y knockback
						ent.x_vel = ent.x_vel + self.ability.knockback.x  --Apply X knockback
						--ent.delay = ent.delay + self.ability.enemyDelay   --Apply enemy delay --Not yet implemeneted in entities
					end 
				else --If facing left, invert width and x for player.  
					if (ent.x > self.x - self.ability.hitbox.x - self.ability.hitbox.width) and (ent.x + ent.w < self.x - self.ability.hitbox.x) and (ent.y < self.y + self.ability.hitbox.y + self.ability.hitbox.height) and (ent.y + ent.h > self.y + self.ability.hitbox.y) then
						ent.health = ent.health - self.ability.damage     --Apply Damage
						ent.y_vel = ent.y_vel + self.ability.knockback.y  --Apply Y knockback
						ent.x_vel = ent.x_vel - self.ability.knockback.x  --Apply X knockback
						--ent.delay = ent.delay + self.ability.enemyDelay   --Apply enemy delay --Not yet implemeneted in entities
					end 
				end
				self.delay = self.delay - self.ability.delay
			end
		end
	end
	self.ability.delay = 0
	self.ability.damage = 0 
	self.ability.knockback.x = 0
	self.ability.knockback.y = 0
	self.ability.enemyDelay = 0 
	self.ability.hitbox.x = 0
	self.ability.hitbox.y = 0
	self.ability.hitbox.width = 0
	self.ability.hitbox.height = 0
end
				
function player:jump()
	if self.standing then
		self.y_vel = self.jump_vel
		self.standing = false
	end
end
	
function player:right()
	self.facingright = true
	self.facingleft = false
	if self.standing then
		self.x_vel = self.x_vel + (self.acceleration * self.speed)
	else
		self.x_vel = self.x_vel + (self.airacceleration * self.speed)
	end
end
	
function player:left()
	self.facingleft = true
	self.facingright = false
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
	
	local sLayer = map.tl["Slopes"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local sTile = sLayer.tileData(tileX, tileY)

	if (sTile == nil) then
		return not(tile == nil)
	end 

	if(sTile.properties["Direction"] == "Right") then
		if (x - tileX > self.y - self.h - tileY) then
			return false
		else
			return true
		end
	end

	return false
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
	--love.graphics.setColor( 25, 25, 25, 255 )
	--love.graphics.rectangle( "fill", (self.x - self.w/2), (self.y - self.h/2), self.w, self.h )   --Player hitbox
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )
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
	self.ability.delay = 0
	self.ability.damage = 10
	self.ability.knockback.x = 1000
	self.ability.knockback.y = -1000
	self.ability.enemyDelay = 0
	self.ability.hitbox.x = 0
	self.ability.hitbox.y = -self.h/2
	self.ability.hitbox.width = 30
	self.ability.hitbox.height = 50
	player:attack()
	--[[
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
				end
			end
		end
	end
	--]]
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
				

