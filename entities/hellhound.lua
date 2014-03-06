local ent = ents.Derive("base")
require("player")
require("entities")
require("entities/spike")

function ent:load(x, y)
	self:setPos( x, y )
	self.image = love.graphics.newImage("sprites/hellhound.png")
	self.speed = 316
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 0.02
	self.acceleration = 0.1
	self.size = 1
	self.h = 28
	self.w = 43
	self.health = 2
	self.damage = 1
	self.invincibilityRemaining = 0
	self.maxhealth = self.health
	self.standing = false
	ent:right()
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:right()
	if self.standing then
		self.x_vel = self.x_vel + (self.acceleration * self.speed)
	else
		self.x_vel = self.x_vel + (self.airacceleration * self.speed)
	end
end
	
function ent:left()
	if self.standing then
		self.x_vel = self.x_vel - (self.acceleration * self.speed)
	else
		self.x_vel = self.x_vel - (self.airacceleration * self.speed)
	end
end
	
function ent:stop()
	self.x_vel = 0
end

function ent:kill()
	self.x = 0
	self.y = 0
	ents.Destroy( self.id )
end

function ent:Damage(n)
	if self.invincibilityRemaining <= 0 then
		if (n >= 0) then
			self.health = self.health - n
			self.invincibilityRemaining = 0
		end
		--if self.health <= 0 then
		--	ent:kill()
		--end	
	end
end

function ent:collide(event)
	if event == "floor" then
		self.y_vel = 0
		self.standing = true
	end
	if event == "ceiling" then
		self.y_vel = 0
	end
end

function ent:CheckCollision()
   for i, ent1 in pairs(ents.objects) do
      for i, ent2 in pairs(ents.objects) do
         if ent1.x < ent2.x+ent2.w and ent1.x+ent1.w > ent2.x and ent1.y < ent2.y+ent2.h and ent1.y+ent1.h > ent2.y then
            if ent1.type == "hellhound" and ent2.type == "spike" then 
				ent1:Damage(spike.damage)
				print("It worked!")
				end
            --if ent1.type == "spike" and ent2.type == "spike" then ??? end
            --if ent1.type == "hellhound" and ent2.type == "hellhound" then ??? end
         end
      end
   end
end

function ent:update(dt)
	local halfX = self.w / 2
	local halfY = self.h / 2	
	
	if self.y > world.ground + self.h then
		ents.Destroy( self.id )
	end
	
	if self.health <= 0 then
		ent:kill()
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
	
	ent:CheckCollision()
	
	if ents:CollidingWithEntity(self.x - (self.w/2), self.y - (self.h/2), self.w, self.h, player.x - (player.w/2), player.y - (player.h/2), player.w, player.h) then
		player:damage(self.damage)
		print ("Hellhound colliding with player!")
	end
	
--	if ents:CollidingWithEntity(self.x - (self.w/2), self.y - (self.h/2), self.w, self.h, getSpikeX() - (spike.w/2), getSpikeY() - (spike.h/2), spike.w, spike.h) then
--		ent:Damage(spike.damage)
--		print (self.health)
--	end
	
	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
		
	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		if not (ent:isColliding(map, self.x - halfX, nextY - halfY))
			and not (ent:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
			self.y = nextY
			self.standing = false
		else
			self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
			ent:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (ent:isColliding(map, self.x-halfX, nextY + halfY))
			and not(ent:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
				self.y = nextY
				self.standing = false
		else
			self.y = nextY - ((nextY + halfY) % map.tileHeight)
			ent:collide("floor")
		end
	end
		
	local nextX = self.x + (self.x_vel * dt)
	if self.x_vel > 0 then
		if not(ent:isColliding(map, nextX + halfX, self.y - halfY))
			and not(ent:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
			self.x = nextX
			ent:right()
		else
			self.x = nextX - ((nextX + halfX) % map.tileWidth)
			ent:left()
		end
	elseif self.x_vel < 0 then
		if not(ent:isColliding(map, nextX - halfX, self.y - halfY))
			and not(ent:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
			self.x = nextX
			ent:left()
		else
			self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
			ent:right()
		end
	end
	
end

function ent:isColliding(map, x, y)
	local layer = map.tl["Solid"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	return not(tile == nil)
end

function ent:getState()
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

function ent:draw()
	
	love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h)
	
	love.graphics.setColor( 255, 255, 255, 255)
	love.graphics.draw(self.image, (self.x - self.w/2) - 7, self.y - self.h/2, 0, self.size, self.size, 0, 0)
end

return ent;