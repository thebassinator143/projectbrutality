local ent = ents.Derive("base")
require("player")

function ent:load(x, y)
	self:setPos(x, y)
	self.speed = 0
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 2
	self.acceleration = 10
	self.size = 1
	self.h = 56
	self.w = 28
	self.health = 3
	self.damage = 1
	self.invincibilityRemaining = 0
	self.maxhealth = self.health
	self.facingright = true
	self.facingleft = false
	self.axethrown = 0
	self.throwRange = 500
	self.axe_x_vel = 300
	self.axe_y_vel = 800
	self.spriteOffset_x = 0
	self.spriteOffset_y = 0
	self.brutality=15
end

function ent:setPos(x, y)
	self.x = x
	self.y = y
end

function ent:Damage(n)
	if self.invincibilityRemaining <= 0 then
		if (n >= 0) then
			self.health = self.health - n
			self.invincibilityRemaining = 0
		end
		if self.health <= 0 then
			ent:kill()
		end
	end
end

function ent:kill()
	brutality.addBrutality(self.brutality,1)
	ents.Destroy( self.id )
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
   for i, ent2 in pairs(ents.objects) do
      if self.id ~= ent2.id then
         if ((self.x < ent2.x+ent2.w and self.x > ent2.x) or (self.x+self.w < ent2.x+ent2.w and self.x+self.w > ent2.x)) and
			(self.y+self.h < ent2.y and self.y+self.h > ent2.y+ent2.h) then
            if ent2.type == "spike" then
               self:Damage(spike.damage)
               print("It worked!")
            --elseif ent2.type == "hellhound" then ???
			end
         end
      end
   end
end

function ent:update(dt)

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

	if player.x + player.w >= self.x - self.throwRange or player.x <= self.x + self.w + self.throwRange then
		if self.axethrown == 0 then
			self:throwAxe()
			self.axethrown = 5
		end
	end

	if player.x >= self.x - self.throwRange and player.x + player.w/2 < self.x + self.w/2 then
		self.facingleft = true
		self.facingright = false
	elseif player.x <= self.x + self.throwRange and player.x + player.w/2 > self.x + self.w/2 then
		self.facingright = true
		self.facingleft = false
	end

	if self.axethrown <= 0 then
		self.axethrown = 0
	else
		self.axethrown = self.axethrown - dt
	end

	ent:CheckCollision()

	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
		player:damage(1)
		--print ("Axethrower colliding with player!")
	end

	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)

	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		if not (ent:isColliding(map, self.x, nextY))
			and not (ent:isColliding(map, self.x + self.w - 1, nextY)) then
			self.y = nextY
			self.standing = false
		else
			self.y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			ent:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (ent:isColliding(map, self.x, nextY + self.h))
			and not(ent:isColliding(map, self.x + self.w - 1, nextY + self.h)) then
				self.y = nextY
				self.standing = false
		else
			self.y = nextY - ((nextY + self.h) % map.tileHeight)
			ent:collide("floor")
		end
	end

	local nextX = self.x + (self.x_vel * dt)
	if self.x_vel > 0 then
		if not(ent:isColliding(map, nextX + self.w, self.y))
			and not(ent:isColliding(map, nextX + self.w, self.y + self.h - 1)) then
			self.x = nextX
		else
			self.x = nextX - ((nextX + self.w) % map.tileWidth)
		end
	elseif self.x_vel < 0 then
		if not(ent:isColliding(map, nextX, self.y))
			and not(ent:isColliding(map, nextX, self.y + self.h - 1)) then
			self.x = nextX
		else
			self.x = nextX + map.tileWidth - ((nextX) % map.tileWidth)
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

function ent:throwAxe()
	if self.facingright then
		local axe = ents.Create("axe", self.x + self.w - 7, self.y, false)
		axe:setVelocity(self.axe_x_vel, -self.axe_y_vel)
	elseif self.facingleft then
		local axe = ents.Create("axe", self.x , self.y, false)
		axe:setVelocity(-self.axe_x_vel, -self.axe_y_vel)
	end
end

function ent:draw()

	love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)		--Axethrower bounding box

end

return ent;

