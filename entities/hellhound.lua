local ent = ents.Derive("base")
require("player")
require("entities")
require("entities/spike")
require("brutality")

function ent:load(x, y)
	self:setPos( x, y )
	self.image = love.graphics.newImage("sprites/warpig.png")
	self.speed = 316
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 2
	self.acceleration = 10
	self.size = 1
	self.h = 28
	self.w = 43
	self.health = 10
	self.damage = 1
	self.invincibilityRemaining = 0
	self.maxhealth = self.health
	self.standing = false
	self.spriteOffset_x = -7
	self.spriteOffset_y = 0
	self.brutality=10
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:right(dt)
	if self.standing then
		self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
	else
		self.x_vel = self.x_vel + (self.airacceleration * self.speed * dt)
	end
end

function ent:left(dt)
	if self.standing then
		self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
	else
		self.x_vel = self.x_vel - (self.airacceleration * self.speed * dt)
	end
end

function ent:stop()
	self.x_vel = 0
end

function ent:kill()
	brutality:addBrutality(self.brutality,1)
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

	ent:CheckCollision()

	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
		player:damage(1)
		print ("Hellhound colliding with player!")
	end

	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)

	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		if not (ent:isColliding(map, self.x + 1, nextY))
			and not (ent:isColliding(map, self.x + self.w - 1, nextY)) then
			self.y = nextY
			self.standing = false
		else
			self.y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			ent:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (ent:isColliding(map, self.x + 1, nextY + self.h))
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
			ent:right(dt)
		else
			self.x = nextX - ((nextX + self.w) % map.tileWidth)
			ent:left(dt)
		end
	elseif self.x_vel < 0 then
		if not(ent:isColliding(map, nextX, self.y))
			and not(ent:isColliding(map, nextX, self.y + self.h - 1)) then
			self.x = nextX
			ent:left(dt)
		else
			self.x = nextX + map.tileWidth - ((nextX) % map.tileWidth)
			ent:right(dt)
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

	--love.graphics.setColor( 25, 25, 25, 255)
	--love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h)   --Hellhound hitbox

	--love.graphics.setColor( 25, 25, 25, 255)
	--love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)   --Hellhound bounding box

	love.graphics.setColor( 255, 255, 255, 255)
	love.graphics.draw(self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, self.size, self.size, 0, 0)
end

return ent;
