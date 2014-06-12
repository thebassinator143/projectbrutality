local ent = ents.Derive("base")
require("player")
require("entities")

function ent:load(x, y)
	self.HPThreshold1=6
	self.HPThreshold2=3
	self:setPos( x, y )
	self.speed = 316
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 2
	self.acceleration = 10
	self.size = 1
	self.h = 56
	self.w = 56
	self.health = 10
	self.invincibilityRemaining = 0
	self.maxhealth = self.health
	self.image=nil
	self.standing = false
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:stop()
	self.x_vel = 0
end

function ent:kill()
	player.spawnX=self.x
	player.spawnY=self.y
	player.health=100
	ents.Destroy( self.id )
end

function ent:Damage(n)
	if self.invincibilityRemaining <= 0 then
		if (n >= 0) then
			self.health = self.health - n
			self.invincibilityRemaining = 0
		end
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


function ent:update(dt)

	if self.y > world.ground + self.h then
		ents.Destroy( self.id )
	end

	if self.health <= 0 then
		ent:kill()
	end

	self.y_vel = self.y_vel + (world.gravity * dt)

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
		if not (self:isColliding(map, self.x + 1, nextY + self.h))
			and not(self:isColliding(map, self.x + self.w - 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + self.w - 1, nextY + self.h)) then
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

function ent:isOneWayColliding(map, x, y)
	local layer = map.tl["oneWayPlatforms"]
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

function ent:changeArt()
	print("this is supposed to change the art once we have it")
end

function ent:draw()

	love.graphics.setColor( 25, 25, 25, 255)
	--love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h)

	--love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

end

return ent;
