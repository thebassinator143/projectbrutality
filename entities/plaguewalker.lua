local ent = ents.Derive("base")
require("player")
require("entities")
require("entities/spike")
require("brutality")

IDLE_MIN = 10	-- Min # of frames to idle
IDLE_MAX = 20	-- Max # of frames to idle
WALK_MIN = 75	-- Min # of frames to walk
WALK_MAX = 125	-- Max # of frames to walk

MAP_WIDTH = 10000000

function ent:load()
	self.rank = "ultra-light"
	self.h = 50
	self.w = 20
	self.health = 1
	self.damage = 1
	self.attkSpeed = 20		-- attack delay?
	self.walkSpeed = 50 	-- max walk speed
	self.aggroSpeed = 100 	-- max aggro speed
	self.speed = 150		-- current max speed (will match either walkSpeed or aggroSpeed)
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.maxhealth = self.health
	self.standing = false
	self.aggroDist = 150
	self.stack = 0.25
	self.edgeDist = 5			-- how close to the edge of the floor the entity will get before stopping
	self.brutality = 1			-- brutality on death
	self.idleTime = IDLE_MIN	-- random #, counts down to zero whenever the enemy idles
	self.walkTime = WALK_MIN	-- random #, each frame subtract 1, if reaches zero, walker idles
	self.walkDirection = 0 		-- random #, determines which direction to walk
	self.walking = false
	self.wallColliding = false
end

function ent:update(dt)	

	if self.y > world.ground + self.h then
		ents.Destroy(self.id)
	end
	
	ents:checkHealth(self.id)
	
	ents:addFrictionAndGravity(self.id, dt)

	ents:CheckCollision(self.id)
	
	ents:movement(self.id, dt)
	
end

function ent:draw()

	love.graphics.setColor( 50, 81, 3, 255)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

	--love.graphics.setColor( 255, 255, 255, 255)
	--love.graphics.draw(self.image, self.x, self.y, 0, self.w, self.h, 0, 0)
end

return ent;