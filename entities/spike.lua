local ent = ents.Derive("base")

spike ={ 
		x = 0,
		y = 0,
		h = 28,
		w = 28,
		damage = 10000}
			
		
function ent:load(x, y)
	self:setPos( x, y )
	self.image = love.graphics.newImage("maps/spike.png")
	self.speed = 0
	self.size = 1
	self.h = 28
	self.w = 28
	self.health = 10000
	self.damage = 10000
	self.maxhealth = self.health 
end

function getSpikeX()
	return ent.x
end

function getSpikeY()
	return ent.y
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
	spike.x = x
	spike.y = y
end

function ent:update(dt)
	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
		player:damage(self.damage)
		print("Collision with spike!")
	end
end

function ent:draw()		
	love.graphics.setColor( 255, 255, 255, 255)
	love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size, 0, 0)
end

return ent;