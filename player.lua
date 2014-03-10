require("entities")

player = 	{
				x = 1036,
				y = 784,
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
				}
				
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
   --print("self.x_vel = " .. self.x_vel)
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
	local layer = map.tl["Platform"]
	
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
	love.graphics.rectangle( "fill", (self.x - self.w/2), (self.y - self.h/2), self.w, self.h )
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.image, (self.x - self.w/2) - 24, (self.y - self.h/2) - 4, 0, 1, 1, 0, 0, 0, 0 )
	
	love.graphics.setColor( 255, 0, 0, 255)
	love.graphics.rectangle("fill", (self.x - (self.w*2)), (self.y - self.h/2), (self.w*1.5), (self.h))
	
	love.graphics.setColor( 255, 0, 0, 255)
	love.graphics.rectangle("fill", (self.x + self.w/2), (self.y - self.h/2), (self.w*1.5), (self.h))
end

function player:melee()
	if self.facingright then
		print("swing right!")
		for i, ent in pairs(ents.objects) do
			if (self.x + self.w/2) < ent.x + ent.w 
			and ((self.x + self.w/2) + (self.w * 1.5)) > ent.x
			and (self.y - self.h/2) < ent.y + ent.h
			and ((self.y - self.h/2) + self.h) > ent.y then
				if ent.type == "hellhound" then
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
				if ent.type == "hellhound" then
					ent:Damage(1)
					print("hit!")
				end
			end
		end
	end
end
