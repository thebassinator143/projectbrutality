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
				image = love.graphics.newImage( "sprites/playersprite.png" ),
				x = 1820,
				y = 700,
				h = 54,
				w = 16,
				spriteOffset_x = -24,
				spriteOffset_y = -4,
				teleHitboxSize = 100,
				x_vel = 0,
				y_vel = 0,
				acceleration = WALKACCEL,
				airacceleration = WALKAIRACCEL,
				reactivity = REACTIVITY * (WALKACCEL - RUNACCEL),
				acceleration = 15,
				airacceleration = 4,
				jump_vel = -1024,
				speed = WALK,
				flySpeed = 580,
				slidefriction = 0.25,
				state = "",
				running = false,
				standing = false,
				ducking = false,
				standing = false,
				facingright = true,
				facingleft = false,
				health = 10,
				brutality = 0,
				lives = 3,
				invincibilityRemaining = 0,
				damage = 1,
				cooldown = 0,
				x_knockback = 0,
				y_knockback = 0,
				enemyAttackDelay = 0,
				meleeHitboxSize = 24,
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
	--Prequisite: unset values are default to 0
	--set ability.delay
	--set ability.damage
	--set ability.knockback.x
	--set ability.knockback.y
	--set ability.enemyDekay
	--set ability.hitbox.x
	--set ability.hitbox.y
	--set ability.hitbox.width
	--set ability.hitbox.height
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
	
	local halfX = self.w / 2
	local halfY = self.h / 2

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
		if not (self:isColliding(map, self.x + 1, nextY))
			and not (self:isColliding(map, self.x + self.w - 1, nextY)) then
			self.y = nextY
			self.standing = false
		else
			self.y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			self:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (self:isColliding(map, self.x + 1, nextY + self.h))
			and not(self:isColliding(map, self.x + self.w - 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + 1, nextY + self.h))
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
	--love.graphics.setColor( 25, 25, 25, 255 )
	--love.graphics.rectangle( "fill", (self.x - self.w/2), (self.y - self.h/2), self.w, self.h )   --Player hitbox

	love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )   --Player bounding box

if self.ducking then
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		end
	else
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 1, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 1, 0, 0, 0, 0 )
		end
	end

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x - self.meleeHitboxSize, self.y, self.meleeHitboxSize, self.h)   --Left melee hitbox

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x + self.w, self.y, self.meleeHitboxSize, self.h)  --Right melee hitbox

	--love.graphics.setColor( 0, 255, 0, 255)
	--love.graphics.rectangle("fill", self.x - self.teleHitboxSize, self.y, self.teleHitboxSize, self.h)   --Left teleport hitbox

	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", (self.x - (self.w*2)), (self.y - self.h/2), (self.w*1.5), (self.h))   --Left melee hitbox

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", (self.x + self.w/2), (self.y - self.h/2), (self.w*1.5), (self.h))  --Right melee hitbox

	--love.graphics.setColor( 0, 255, 0, 255)
	--love.graphics.rectangle("fill", (self.x - (self.w*1.5)-81), (self.y - self.h/4), self.w+81, self.h/2)   --Left teleport hitbox

	--love.graphics.setColor( 0, 255, 0, 255 )
	--love.graphics.rectangle("fill", self.x + self.w, self.y, self.teleHitboxSize, self.h)   --Right teleport hitbox
end

function player:melee()
	self.ability.delay = 0
	self.ability.damage = 10
	self.ability.knockback.x = 1000
	self.ability.knockback.y = -1000
	self.ability.enemyDelay = 0
	self.ability.hitbox.x = 0
	self.ability.hitbox.y = -25
	self.ability.hitbox.width = 30
	self.ability.hitbox.height = 50
	player:attack()
end

function player:setBasicAttack()
	self.damage = 1
	self.cooldown = 0
	self.x_knockback = 0
	self.y_knockback = 0
	self.enemyAttackDelay = 1
	self.meleeHitboxSize = 24
	
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
end

function player:teleport()
	if self.facingright then
		print("teleport right!")
		for i, ent in pairs(ents.objects) do
			if ent.x > self.x + self.w and ent.x < self.x + self.w + self.teleHitboxSize
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
			if ent.x + ent.w > self.x - self.teleHitboxSize and ent.x + ent.w < self.x     
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
