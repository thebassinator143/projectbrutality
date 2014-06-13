local ent = ents.Derive("base")
require("player")
require("entities")

function ent:load(x, y)
	self:setPos( x, y )
	self.h = 112
	self.w = 56
	self.arenaX=600
	self.arenaY=500
	self.arenaH=100
	self.arenaW=100
	self.soulCounter=100
	self.open=false
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:update(dt)
	if self.soulCounter<=0 then
		self.open=true
	end
	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
			player:collide("wall")
			player.x=player.x-(player.x_vel*dt)
	end
end

function ent:draw()
	love.graphics.setColor( 25, 25, 25, 255)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

return ent;
