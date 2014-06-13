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
	self.speed = self.walkSpeed		-- current max speed (will match either walkSpeed or aggroSpeed)
	self.x_vel = 0
	self.y_vel = 0
	self.flySpeed = 700
	self.maxhealth = self.health
	self.standing = false
	self.aggroDist = 150
	self.stack = 0.25
	self.edgeDist = 5			-- how close to the edge of the floor the entity will get before stopping
	self.brutality = 2			-- brutality on death
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
	
	ent:checkHealth()
	
	ent:addFrictionAndGravity(dt)

	ent:CheckCollision()
	
	ent:movement(dt)
	
end

function ent:draw()

	love.graphics.setColor( 50, 81, 3, 255)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

	--love.graphics.setColor( 255, 255, 255, 255)
	--love.graphics.draw(self.image, self.x, self.y, 0, self.w, self.h, 0, 0)
end

function ent:checkHealth()
	if self.health <= 0 then
		ent:kill()
	end
end

function ent:kill()
	brutality:addBrutality(self.brutality,1)
	ents.Destroy(self.id)
end

function ent:addFrictionAndGravity(dt)
	
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
end

function ent:CheckCollision()
	for i, ent2 in pairs(ents.objects) do
		if self.id ~= ent2.id then
			if ent2.x + ent2.w > self.x and ent2.x < self.x + self.w 
			and ent2.y + ent2.h > self.y and ent2.y < self.y + self.h then
				if ent2.type == "spike" then
					ent:Damage(spike.damage)
				elseif ent2.rank ~= "none" then
					if self.aggroed and ent2.aggroed then
						if ent2.x + ent2.w <= self.x + self.w/2 then
							ent2.x = math.clamp(ent2.x, 0, self.x + 0.25*self.w - ent2.w)
						else
							ent2.x = math.clamp(ent2.x, self.x + 0.75*self.w, MAP_WIDTH)
						end
					end
				end
			end
		end
	end
	
	if ents:CollidingWithEntity(self.x, self.y, self.w, self.h, player.x, player.y, player.w, player.h) then
		player:damage(self.damage)
	end
end

function ent:Damage(n)
	if (n >= 0) then
		self.health = self.health - n
	end
end

function ent:movement(dt)
	
	if self.standing then
		ent:walk()
		ent:aggro()
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
			self.wallColliding = false
		else
			self.x = nextX - ((nextX + self.w) % map.tileWidth)
			self.wallColliding = true
		end
	elseif self.x_vel < 0 then
		if not(ent:isColliding(map, nextX, self.y))
			and not(ent:isColliding(map, nextX, self.y + self.h - 1)) then
			self.x = nextX
			self.wallColliding = false
		else
			self.x = nextX + map.tileWidth - ((nextX) % map.tileWidth)
			self.wallColliding = true
		end
	end
end

function ent:walk()
	if self.aggroed == false then
		self.speed = self.walkSpeed
		if self.walking == false then
			self.walking = true
			self.idleTime = love.math.random(IDLE_MIN, IDLE_MAX)
			self.walkTime = love.math.random(WALK_MIN, WALK_MAX)
			self.walkDirection = love.math.random(0,1)
		else
			if self.wallColliding then		--turn around if colliding with a wall
				if self.walkDirection == 0 then
					self.walkDirection = 1
				else
					self.walkDirection = 0
				end
			end
			if self.walkTime > 0 then			--walking
				if self.walkDirection == 0 then
					self.x_vel = -self.walkSpeed
				else
					self.x_vel = self.walkSpeed
				end
				self.walkTime = self.walkTime - 1
			else								--idleing
				self.x_vel = 0
				if self.idleTime > 0 then
					self.idleTime = self.idleTime - 1
				else
					self.walking = false 		--restart cycle (begin walk again)
				end
			end
		end			
	end		
end

function ent:aggro()
	x_diff = (player.x + player.w/2) - (self.x + self.w/2)
	y_diff = (player.y + player.h/2) - (self.y + self.h/2)
	playerDist = math.sqrt(x_diff * x_diff + y_diff * y_diff)
	if playerDist <= self.aggroDist then
		self.aggroed = true
		self.speed = self.aggroSpeed
		if x_diff > (self.w/2 + player.w/2) then
			self.x_vel = self.aggroSpeed
		elseif x_diff < -(self.w/2 + player.w/2) then
			self.x_vel = -self.aggroSpeed
		else
			self.x_vel = 0
		end
	else
		self.aggroed = false
		self.speed = self.walkSpeed
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

function ent:isColliding(map, x, y)
	local layer = map.tl["Solid"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	return not(tile == nil)
end

return ent;