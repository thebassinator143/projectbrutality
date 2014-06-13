local ent = ents.Derive("base")
require("player")

function ent:load(x, y)
	self:setPos( x, y )
	self.speed = 10
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.airacceleration = 0.0
	self.acceleration = 0.0
	self.size = 1
	self.h = 30
	self.w = 60
	self.totalDistance=100
	self.currentDistance=0
	self.movingright = true
	self.deltax=0
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:update(dt)
	--makes the platform move
	if self.movingright then
		self.x_vel=self.speed
	else
		self.x_vel=-self.speed
	end
	local nextX = self.x + (self.x_vel * dt)
	self.currentDistance=self.currentDistance+(self.x_vel*dt)
	if self.currentDistance>=self.totalDistance then
		self.movingright=false
	end
	if self.currentDistance<=0 then
		self.movingright=true
	end
	self.deltax=nextX-self.x
	self.x=nextX

	--player collision
	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
		if (player.y_vel>0) then
			player:collide("floor")
			player.y=self.y-player.h
		end
	end
	if player.y==self.y-(player.h) then
		player.x=player.x+(self.deltax)
	end
end

function ent:getState()
	return self.movingright
end

function ent:draw()

	love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return ent;
