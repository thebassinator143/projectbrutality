local ent = ents.Derive("base")

function ent:load(x, y)
	self:setPos( x, y )
	self.image = love.graphics.newImage("maps/spike.png")
	self.speed = 0
	self.size = 1
	self.height = 28
	self.width = 28
	self.health = 10000
	self.damage = 10000
	self.maxhealth = self.health
end

function ent:setPos( x, y )
	self.x = x
	self.y = y
end

function ent:draw()
	love.graphics.setColor( 255, 255, 255, 255)
	love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size, 0, 0)
end

return ent;