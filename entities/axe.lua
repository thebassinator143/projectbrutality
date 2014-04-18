local ent = ents.Derive("base")
					
function ent:load(x, y)
	self:setPos( x, y )
	self.speed = 1000
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 1
	self.acceleration = 1
	self.size = 1
	self.h = 7
	self.w = 7
	self.health = 10000
	self.damage = 2
	self.maxhealth = self.health 
	self.axetime = 0
end
function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:setVelocity(x, y)
	self.x_vel = x
	self.y_vel = y
end

function ent:getVelocity( x, y )
	return self.x_vel, self.y_vel;
end

function ent:update(dt)
	local halfX = self.w / 2
	local halfY = self.h / 2
	
	--print(self.x_vel)
	--print(self.y_vel)
	
	self.axetime = self.axetime - dt
	if self.y >= 812 then
		print(self.axetime)
	end
	
	if self.y > world.ground + self.h then
		ents.Destroy( self.id )
	end
	
	self.y_vel = self.y_vel + (world.gravity * dt)
	
	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)
	
	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		self.y = nextY
	end
	
	if self.y_vel > 0 then
		self.y = nextY	
	end
		
	local nextX = self.x + (self.x_vel * dt)
	if self.x_vel > 0 then
		self.x = nextX
	elseif self.x_vel < 0 then
		self.x = nextX
	end
	
	if ents:CollidingWithEntity(self.x, self.y - 1, self.w, self.h, player.x - (player.w/2), player.y - (player.h/2), player.w, player.h) then
		player:damage(self.damage)
		print("Axed!!")
	end
end

function ent:draw()		
	love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return ent;