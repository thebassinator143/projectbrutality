require("brutality")

ents = {}
ents.objects = {}
ents.objpath = "entities/"
local register = {}
local id = 0

function ents.Startup()
	register["spike"] = love.filesystem.load( ents.objpath .. "spike.lua" )
	register["hellhound"] = love.filesystem.load( ents.objpath .. "hellhound.lua")
	register["axethrower"] = love.filesystem.load( ents.objpath .. "axethrower.lua" )
	register["axe"] = love.filesystem.load( ents.objpath .. "axe.lua")
	register["movingplatform"] = love.filesystem.load( ents.objpath .. "movingplatform.lua" )
	register["plaguewalker"] = love.filesystem.load( ents.objpath .. "plaguewalker.lua" )
end

function ents.Derive(name)
	return love.filesystem.load( ents.objpath .. name .. ".lua" )()
end

function ents.Create(name, x, y, BG)
	if not x then
		x = 0
	end

	if not y then
		y = 0
	end

	if not BG then
		BG = false
	end

	if register[name] then
		id = id + 1
		local ent = register[name]()
		ent.type = name
		ent.x = x
		ent.y = y
		ent.id = id
		ent.BG = BG
		ent.rank = "none"
		ent.h = 0
		ent.w = 0
		ent.health = 0
		ent.damage = 0
		ent.attkSpeed = 0
		ent.walkSpeed = 0
		ent.aggroSpeed = 0
		ent.speed = 0				-- current max speed (will match either walkSpeed or aggroSpeed)
		ent.x_vel = 0
		ent.y_vel = 0
		ent.flySpeed = 0
		ent.maxhealth = ent.health
		ent.standing = false
		ent.aggroDist = 0
		ent.stack = 0
		ent.edgeDist = 0			-- how close to the edge of the floor the entity will get before stopping
		ent.brutality = 0			-- brutality on death
		ent.idleTime = 0			-- random #, counts down to zero whenever the enemy idles
		ent.walkTime = 0			-- random #, each frame subtract 1, if reaches zero, walker idles
		ent.walkDirection = 0 		-- random #, determines which direction to walk
		ent.walking = false
		ent.wallColliding = false
		ent.aggroed = false
		ent.entColliding = false
		ent:load()
		ents.objects[id] = ent
		return ents.objects[id]
	else
		print("Error: Entity " .. name .. " does not exist! FAWK!!!")
		return false
	end
end

function ents.Destroy( id )
	if ents.objects[id] then
		if ents.objects[id].Die then
			ents.objects[id]:Die()
		end
		ents.objects[id] = nil
	end
end

function ents:walk(id)
	if ents.objects[id].aggroed == false then
		ents.objects[id].speed = ents.objects[id].walkSpeed
		if ents.objects[id].walking == false then
			ents.objects[id].walking = true
			ents.objects[id].idleTime = love.math.random(IDLE_MIN, IDLE_MAX)
			ents.objects[id].walkTime = love.math.random(WALK_MIN, WALK_MAX)
			ents.objects[id].walkDirection = love.math.random(0,1)
		else
			if ents.objects[id].wallColliding then		--turn around if colliding with a wall
				if ents.objects[id].walkDirection == 0 then
					ents.objects[id].walkDirection = 1
				else
					ents.objects[id].walkDirection = 0
				end
			end
			if ents.objects[id].walkTime > 0 then			--walking
				if ents.objects[id].walkDirection == 0 then
					ents.objects[id].x_vel = -ents.objects[id].walkSpeed
				else
					ents.objects[id].x_vel = ents.objects[id].walkSpeed
				end
				ents.objects[id].walkTime = ents.objects[id].walkTime - 1
			else								--idleing
				ents.objects[id].x_vel = 0
				if ents.objects[id].idleTime > 0 then
					ents.objects[id].idleTime = ents.objects[id].idleTime - 1
				else
					ents.objects[id].walking = false 		--restart cycle (begin walk again)
				end
			end
		end			
	end		
end

function ents:aggro(id)
	x_diff = (player.x + player.w/2) - (ents.objects[id].x + ents.objects[id].w/2)
	y_diff = (player.y + player.h/2) - (ents.objects[id].y + ents.objects[id].h/2)
	playerDist = math.sqrt(x_diff * x_diff + y_diff * y_diff)
	if playerDist <= ents.objects[id].aggroDist then
		ents.objects[id].aggroed = true
		ents.objects[id].speed = ents.objects[id].aggroSpeed
		if x_diff > (ents.objects[id].w/2 + player.w/2) then
			ents.objects[id].x_vel = ents.objects[id].aggroSpeed
		elseif x_diff < -(ents.objects[id].w/2 + player.w/2) then
			ents.objects[id].x_vel = -ents.objects[id].aggroSpeed
		else
			ents.objects[id].x_vel = 0
		end
	else
		ents.objects[id].aggroed = false
		ents.objects[id].speed = ents.objects[id].walkSpeed
	end	
end

function ents:stop(id)
	ents.objects[id].x_vel = 0
end

function ents:kill(id)
	brutality.addBrutality(ents.objects[id].brutality,1)
	ents.Destroy(ents.objects[id].id)
end

function ents:Damage(id, n)
	if (n >= 0) then
		ents.objects[id].health = ents.objects[id].health - n
	end
end

function ents:collide(id, event)
	if event == "floor" then
		ents.objects[id].y_vel = 0
		ents.objects[id].standing = true
	end
	if event == "ceiling" then
		ents.objects[id].y_vel = 0
	end
end

function ents:CheckCollision(id)
	for i, ent2 in pairs(ents.objects) do
		if ents.objects[id].id ~= ent2.id then
			if ent2.x + ent2.w > ents.objects[id].x and ent2.x < ents.objects[id].x + ents.objects[id].w 
			and ent2.y + ent2.h > ents.objects[id].y and ent2.y < ents.objects[id].y + ents.objects[id].h then
				if ent2.type == "spike" then
					ent:Damage(id, spike.damage)
				elseif ent2.rank ~= "none" then
					if ents.objects[id].aggroed and ent2.aggroed then
						if ent2.x + ent2.w <= ents.objects[id].x + ents.objects[id].w/2 then
							ent2.x = math.clamp(ent2.x, 0, ents.objects[id].x + 0.25*ents.objects[id].w - ent2.w)
						else
							ent2.x = math.clamp(ent2.x, ents.objects[id].x + 0.75*ents.objects[id].w, MAP_WIDTH)
						end
					end
				end
			end
		end
	end
	
	if ents:CollidingWithEntity(ents.objects[id].x, ents.objects[id].y, ents.objects[id].w, ents.objects[id].h, player.x, player.y, player.w, player.h) then
		player:damage(ents.objects[id].damage)
	end
end

function ents:addFrictionAndGravity(id, dt)
	ents.objects[id].y_vel = ents.objects[id].y_vel + (world.gravity * dt)	
	if ents.objects[id].standing then
		if ents.objects[id].x_vel > 0 then
			if ents.objects[id].x_vel <= (world.friction * dt) then
				ents.objects[id].x_vel = 0
			else
				ents.objects[id].x_vel = ents.objects[id].x_vel + (world.friction * dt)
			end
		elseif ents.objects[id].x_vel < 0 then
			if ents.objects[id].x_vel >= (world.friction * dt) then
				ents.objects[id].x_vel = 0
			else
				ents.objects[id].x_vel = ents.objects[id].x_vel - (world.friction * dt)
			end
		else
			ents.objects[id].x_vel = 0
		end
	end
end

function ents:movement(id, dt)
	ents:walk(id)
	ents:aggro(id)
	
	ents.objects[id].x_vel = math.clamp(ents.objects[id].x_vel, -ents.objects[id].speed, ents.objects[id].speed)
	ents.objects[id].y_vel = math.clamp(ents.objects[id].y_vel, -ents.objects[id].flySpeed, ents.objects[id].flySpeed)

	local nextY = ents.objects[id].y + (ents.objects[id].y_vel*dt)
	if ents.objects[id].y_vel < 0 then
		if not (ents:isColliding(map, ents.objects[id].x + 1, nextY))
			and not (ents:isColliding(map, ents.objects[id].x + ents.objects[id].w - 1, nextY)) then
			ents.objects[id].y = nextY
			ents.objects[id].standing = false
		else
			ents.objects[id].y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			ents:collide(id, "ceiling")
		end
	end
	if ents.objects[id].y_vel > 0 then
		if not (ents:isColliding(map, ents.objects[id].x + 1, nextY + ents.objects[id].h))
			and not(ents:isColliding(map, ents.objects[id].x + ents.objects[id].w - 1, nextY + ents.objects[id].h)) then
				ents.objects[id].y = nextY
				ents.objects[id].standing = false
		else
			ents.objects[id].y = nextY - ((nextY + ents.objects[id].h) % map.tileHeight)
			ents:collide(id, "floor")
		end
	end

	local nextX = ents.objects[id].x + (ents.objects[id].x_vel * dt)
	if ents.objects[id].x_vel > 0 then
		if not(ents:isColliding(map, nextX + ents.objects[id].w, ents.objects[id].y))
			and not(ents:isColliding(map, nextX + ents.objects[id].w, ents.objects[id].y + ents.objects[id].h - 1)) then
			ents.objects[id].x = nextX
			ents.objects[id].wallColliding = false
		else
			ents.objects[id].x = nextX - ((nextX + ents.objects[id].w) % map.tileWidth)
			ents.objects[id].wallColliding = true
		end
	elseif ents.objects[id].x_vel < 0 then
		if not(ents:isColliding(map, nextX, ents.objects[id].y))
			and not(ents:isColliding(map, nextX, ents.objects[id].y + ents.objects[id].h - 1)) then
			ents.objects[id].x = nextX
			ents.objects[id].wallColliding = false
		else
			ents.objects[id].x = nextX + map.tileWidth - ((nextX) % map.tileWidth)
			ents.objects[id].wallColliding = true
		end
	end
end

function ents:checkHealth(id)
	if ents.objects[id].health <= 0 then
		ents:kill(id)
	end
end

function ents:isColliding(map, x, y)
	local layer = map.tl["Solid"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	return not(tile == nil)
end

function ents:update(dt)
	for i, ent in pairs(ents.objects) do
		if ent.update then
			ent:update(dt)
		end
	end
end

function ents:draw()
	for i, ent in pairs(ents.objects) do
		if not ent.BG then
			if ent.draw then
				ent:draw()
			end
		end
	end
end

function ents:drawBG()
	for i, ent in pairs(ents.objects) do
		if ent.BG then
			if ent:draw() then
				ent:draw()
			end
		end
	end
end

function ents:CollidingWithEntity(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
