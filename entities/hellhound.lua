local ent = ents.Derive("base")

function ent:load(x, y)
	self:setPos( x, y )
	self.image = love.graphics.newImage("sprites/hellhound.png")
	self.speed = 0
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 0
	self.size = 1
	self.height = 28
	self.width = 43
	self.health = 2
	self.damage = 1
	self.maxhealth = self.health
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:update(dt)
	local halfX = self.w / 2
	local halfY = self.h / 2
		
	if self.y > world.ground + self.h then
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
		else
			self.x = nextX - ((nextX + halfX) % map.tileWidth)
		end
	elseif self.x_vel < 0 then
		if not(ent:isColliding(map, nextX - halfX, self.y - halfY))
			and not(ent:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
		end
	end
		
	self.state = self:getState()
end
function ent:draw()
	love.graphics.setColor( 255, 255, 255, 255)
	love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size, 0, 0)
end

return ent;