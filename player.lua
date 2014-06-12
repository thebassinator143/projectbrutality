require("entities")
require("brutality")

WALK = 285
WALKACCEL = 13 + 1/3
WALKAIRACCEL = 2.60

RUNRATIO = 1.3509									 --Ratio based on WALK that determines RUN
RUN = WALK * RUNRATIO
RUNACCEL = (WALK/RUN) * WALKACCEL					 --Formula ensures rate of acceleration remains fixed whether walking or running
RUNAIRACCEL = (WALK/RUN) * WALKAIRACCEL

REACTIVITY = 0.75									 --Modifies running deceleration without affecting acceleration

WALLFRIC = 1.16										 --Modifies gravity while player is wallsliding

HEIGHT = 54
DUCKHEIGHT = HEIGHT/2


BASE_MELEE_DAMAGE = 1

player = 	{
				image = love.graphics.newImage( "sprites/playersprite.png" ),
				x = 532,
				y = 616,
				h = 54,
				w = 16,
				spriteOffset_x = -24,
				spriteOffset_y = -4,
				teleHitboxSize = 100,
				spawnX=256,
				spawnY=256,
				x_vel = 0,
				y_vel = 0,
				acceleration = WALKACCEL,
				airacceleration = WALKAIRACCEL,
				reactivity = REACTIVITY * (WALKACCEL - RUNACCEL),
				acceleration = 15,
				airacceleration = 4,
				jump_vel = -495,
				doublejump_vel = 0.86,							--Multiplies by jump_vel
				walljump_vel = 0.86,							--Multiplies by jump_vel
				speed = WALK,
				flySpeed = 580,
				slidefriction = 0.25,
				state = "",
				brutality=brutality,
				brutalityTier=nil,
				running = false,
				standing = false,
				ducking = false,
				standing = false,
				facingright = true,
				facingleft = false,
				charging = false,
				charge = 0,
				health = 10,
				lives = 3,
				invincibilityRemaining = 0,
				damage = 1,
				cooldown = 0,
				x_knockback = 0,
				y_knockback = 0,
				enemyAttackDelay = 0,
				meleeHitboxSize = 24,
				delay = 0,
				ability =	{
					delay = 0,
					damage = 0,
					knockback = {
						x = 0,
						y = 0
						},
					enemyDelay = 0,
					hitbox = {
						x = 0,
						y = 0,
						width = 0,
						height = 0
						}
					},
				wallslide = false,
				wallJump = false,
				doubleJump = false,
				swallLeft = false,
				wallFric = 1,
				wallTimer = 0,
				isWallJumping = false
			}


function player:attack()
	--[[
	--Prequisite: unset values are default to 0
	--set ability.delay
	--set ability.damage
	--set ability.knockback.x
	--set ability.knockback.y
	--set ability.enemyDelay
	--set ability.hitbox.x
	--set ability.hitbox.y
	--set ability.hitbox.width
	--set ability.hitbox.height
	--All values are set to 0 after attack is called.
	--]]
	if self.delay <= 0 then --delay is a global cooldown period where the player cannot use skills, generally this means they are still animating a skill and cant use another.
		print("derp")
		print (self.brutalityTier.hitboxBoost)
		print("/derp")
		for i, ent in pairs(ents.objects) do
			if not ent.BG then --why??
				if self.facingright then
					--Collision Detection
					if (ent.x < self.x + self.ability.hitbox.x + self.ability.hitbox.width) and (ent.x + ent.w > self.x + self.ability.hitbox.x+self.ability.hitbox.width)
					and (ent.y < self.y + self.ability.hitbox.y + self.ability.hitbox.height) and (ent.y + ent.h > self.y + self.ability.hitbox.y) then
						ent.health = ent.health - (self.ability.damage+self.brutalityTier.damageBoost)     --Apply Damage
						ent.y_vel = ent.y_vel + (self.ability.knockback.y+self.brutalityTier.yKnockbackBoost)  --Apply Y knockback
						ent.x_vel = ent.x_vel + (self.ability.knockback.x+self.brutalityTier.xKnockbackBoost)  --Apply X knockback
						--ent.delay = ent.delay + self.ability.enemyDelay   --Apply enemy delay --Not yet implemeneted in entities
						print("Right attack on "..ent.type.."!")
						self.brutality:resetDecayTimer()
						self.health=self.health+self.brutalityTier.lifeSteal
					end
				else --If facing left, invert width and x for player.
					if (ent.x < self.x + self.w - self.ability.hitbox.x) and (ent.x + ent.w > self.x + self.w - self.ability.hitbox.width)
					and (ent.y < self.y + self.ability.hitbox.y + self.ability.hitbox.height) and (ent.y + ent.h > self.y + self.ability.hitbox.y) then
						ent.health = ent.health - (self.ability.damage+self.brutalityTier.damageBoost)     --Apply Damage
						ent.y_vel = ent.y_vel + (self.ability.knockback.y+self.brutalityTier.yKnockbackBoost)  --Apply Y knockback
						ent.x_vel = ent.x_vel - (self.ability.knockback.x+self.brutalityTier.xKnockbackBoost)  --Apply X knockback
						--ent.delay = ent.delay + self.ability.enemyDelay   --Apply enemy delay --Not yet implemeneted in entities
						print("Left attack on "..ent.type.."!")
						self.brutality:resetDecayTimer()
						self.health=self.health+self.brutalityTier.lifeSteal
					end
				end
				self.delay = self.delay - self.ability.delay
			end
		end
	end
	self.ability.delay = 0
	self.ability.damage = 0
	self.ability.knockback.x = 0
	self.ability.knockback.y = 0
	self.ability.enemyDelay = 0
	--self.ability.hitbox.x = 0
	--self.ability.hitbox.y = 0
	--self.ability.hitbox.width = 0
	--self.ability.hitbox.height = 0
end

function player:jump(dt)
	print("attempting Jump")
 	if self.wallJump then
		print("Is Wallslide")
 		if love.keyboard.isDown("a") then
			print("a down")
 			if self.wallLeft == true then
 				print("walljump right")
 				self:right(dt)
				self.y_vel = self.jump_vel * self.walljump_vel
				self.wallslide = false
				self.wallJump = false
				self.isWallJumping = true
				self.wallFric = 1
				self.wallTimer = 10
			end
 		elseif love.keyboard.isDown("d") then
			print("d down")
 			if self.wallLeft == false then
 				print("walljump left")
 				self:left(dt)
				self.y_vel = self.jump_vel * self.walljump_vel
				self.wallslide = false
				self.wallJump = false
				self.wallFric = 1
				self.wallTimer = 10
			end
		end
	elseif self.standing then
		print("Is Standing")
		self.y_vel = self.jump_vel
		self.standing = false
	elseif self.doubleJump then
		print ("doubleJumping")
		if self.wallJump == false then
			self.y_vel = self.jump_vel * self.doublejump_vel
			self.doubleJump = false
		end
  	end
end

function player:right(dt)
	self.facingright = true
	self.facingleft = false
	if not self.ducking and not self.charging then
		if self.standing then
			if self.running then
				if self.x_vel < 0 then
					self.x_vel = self.x_vel + ((self.acceleration + self.reactivity) * self.speed * dt)
				else
					self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
				end
			else
				self.x_vel = self.x_vel + (self.acceleration * self.speed * dt)
			end
		else
			if isWallJumping then
				self.x_vel = self.x_vel + (self.airacceleration * self.speed * dt*2)
			else
				self.x_vel = self.x_vel + (self.airacceleration * self.speed * dt)
			end
		end
	end
end

function player:left(dt)
	self.facingleft = true
	self.facingright = false
	if not self.ducking and not self.charging then
		if self.standing then
			if self.running then
				if self.x_vel > 0 then
					self.x_vel = self.x_vel - ((self.acceleration + self.reactivity) * self.speed * dt)
				else
					self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
				end
			else
				self.x_vel = self.x_vel - (self.acceleration * self.speed * dt)
			end
		else
			if isWallJumping then
				self.x_vel = self.x_vel - (self.airacceleration * self.speed * dt*2)
			else
				self.x_vel = self.x_vel - (self.airacceleration * self.speed * dt)
			end
		end
	end
end

function player:duck()
	if self.standing then
		self.h = DUCKHEIGHT
		self.y = self.y + self.h
		self.ducking = true
	end
end

function player:stand()
	self.h = HEIGHT
	self.ducking = false
end

function player:stop()
	self.x_vel = 0
end

function player:collide(event)
	--print("Event:", event)
	if event == "floor" then
		self.y_vel = 0
		self.standing = true
		self.doubleJump = true
		self.isWallJumping = false
		self.wallslide = false
		self.wallJump = false
		self.wallTimer = 0

		wallFric = 1
	end
 	if event == "ceiling" then
		self.y_vel = 0
		self.wallFric = 1
		self.wallTimer = 0
		self.isWallJumping = false
	end
 	if event == "wall" then
			if self.wallLeft == true then
				if love.keyboard.isDown("a") then
					if self.y_vel >0 or self.y_vel < 0 then
						self.wallJump = true
						self.doubleJump = true
					end
					if self.y_vel > 0 then
						self.wallslide = true
						if self.wallFric == 1 then
							self.wallFric = WALLFRIC
							print ("wallslide after:", self.wallslide)
						end
					end
				end
			else
				if love.keyboard.isDown("d") then
					if self.y_vel >0 or self.y_vel < 0 then
						self.wallJump = true
						self.doubleJump = true
					end
					if self.y_vel > 0 then
						self.wallslide = true
						self.doubleJump = true
						if self.wallFric == 1 then
							self.wallFric = WALLFRIC
							print ("wallslide after:", self.wallslide)
						end
					end
				end
			end
			self.isWallJumping = false
	end
 	if event == "none" then
 		self.wallFric = 1
		self.wallslide = false
		self.wallJump = false
		--print ("none")
  	end
end

function player:die()
	self.x = self.spawnX
	self.y = self.spawnY
	self.lives = self.lives - 1
	self.health = 10

	--self.x_vel = 0  --Freeze for better visual collision check
	--self.y_vel = 0
end

function player:damage(n)
	if self.invincibilityRemaining <= 0 then
		if (n >= 0) then
			self.health = self.health - (n-self.brutalityTier.defenseBoost)
			self.invincibilityRemaining = 1
		end
	end
	if self.health <= 0 then
		self.health = 0
		self:die()
	end
end

function player:update(dt)
	self.brutality:update(dt)
	self.brutalityTier=self.brutality:getCurrentTier()
	--print(self.x_vel)

	if love.keyboard.isDown("lshift") then
		self.speed = RUN
		self.acceleration = RUNACCEL
		self.airacceleration = RUNAIRACCEL
		self.running = true
	else
		self.speed = WALK
		self.acceleration = WALKACCEL
		self.airacceleration = WALKAIRACCEL
		self.running = false
	end
	local halfX = self.w / 2
	local halfY = self.h / 2

	if love.keyboard.isDown("d") then
		--print("timer: ",  self.wallTimer)
		if isWallJumping == false then
			self:right(dt)
		else
			if self.wallTimer <= 0 then
				self:right(dt)
			else
				self.wallTimer = self.wallTimer - 1
			end
		end
	elseif love.keyboard.isDown("a") then
	--print("timer: ",  self.wallTimer)
		if isWallJumping == false then
			self:left(dt)
		else
			if self.wallTimer <= 0 then
				self:left(dt)
			else
				self.wallTimer = self.wallTimer - 1
			end
		end
	else
		if self.wallTimer > 0 then
			self.wallTimer = self.wallTimer - 1
		end
	end
	--if love.keyboard.isDown(" ") and not(hasJumped) then
	--	self:jump()
	--end

	if self.invincibilityRemaining <= 0 then
		self.invincibilityRemaining = 0
	else
		self.invincibilityRemaining = self.invincibilityRemaining - dt
	end

	if self.y > world.ground + self.h then
		self:die()
	end
	self.y_vel = (self.y_vel + (world.gravity * dt)) / self.wallFric
 	if self.wallFric >= 1.2 then
		self.wallFric = self.wallFric - 0.2
		--print (self.wallFric)
	end

	if self.standing then
		if self.x_vel > 0 then
			if self.ducking or self.charging then
				if self.x_vel <= (self.slidefriction * world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel + (self.slidefriction * world.friction * dt)
				end
			else
				if self.x_vel <= (world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel + (world.friction * dt)
				end
			end
		elseif self.x_vel < 0 then
			if self.ducking or self.charging then
				if self.x_vel >= (self.slidefriction * world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel - (self.slidefriction * world.friction * dt)
				end
			else
				if self.x_vel >= (world.friction * dt) then
					self.x_vel = 0
				else
					self.x_vel = self.x_vel - (world.friction * dt)
				end
			end
		else
			self.x_vel = 0
		end
	end

	self.x_vel = math.clamp(self.x_vel, -self.speed, self.speed)
	self.y_vel = math.clamp(self.y_vel, -self.flySpeed, self.flySpeed)

	local nextY = self.y + (self.y_vel*dt)
	if self.y_vel < 0 then
		if not (self:isColliding(map, self.x + 1, nextY))
			and not (self:isColliding(map, self.x + self.w - 1, nextY)) then
			self.y = nextY
			self.standing = false
			self:collide("none")

		else
			self.y = nextY + map.tileHeight - ((nextY) % map.tileHeight)
			self:collide("ceiling")
		end
	end
	if self.y_vel > 0 then
		if not (self:isColliding(map, self.x + 1, nextY + self.h))
			and not(self:isColliding(map, self.x + self.w - 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + 1, nextY + self.h))
			and not(self:isOneWayColliding(map, self.x + self.w - 1, nextY + self.h)) then
				self.y = nextY
				self.standing = false
				self:collide("none")
		else
			self.y = nextY - ((nextY + self.h) % map.tileHeight)
			self:collide("floor")
		end
	end

	local nextX = self.x + (self.x_vel * dt)
	if self.x_vel > 0 then
		if not(self:isColliding(map, nextX + self.w, self.y))
			and not(self:isColliding(map, nextX + self.w, self.y + self.h - 1)) then
			self.x = nextX
			self:collide("none")
		else
			self.x = nextX - ((nextX + self.w) % map.tileWidth)
			self:collide("wall")
			self.wallLeft = false
		end
	elseif self.x_vel < 0 then
		if not(self:isColliding(map, nextX, self.y))
			and not(self:isColliding(map, nextX, self.y + self.h - 1)) then
			self.x = nextX
			self:collide("none")
		else
			self.x = nextX + map.tileWidth - ((nextX) % map.tileWidth)
			self:collide("wall")
			self.wallLeft = true
		end
	end

	if self.charging==true then
		self.charge=self.charge+dt
		print(self.charge)
	end

	self.state = self:getState()
end

function player:isColliding(map, x, y)
	local layer = map.tl["Solid"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	return not(tile == nil)
end

function player:isOneWayColliding(map, x, y)
	local layer = map.tl["oneWayPlatforms"]
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
	local tile = layer.tileData(tileX, tileY)
	return not(tile == nil)
end

function player:getState()
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

function player:draw()

	--love.graphics.setColor( 25, 25, 25, 255 )
	--love.graphics.rectangle( "fill", (self.x - self.w/2), (self.y - self.h/2), self.w, self.h )   --Player hitbox

	love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )   --Player bounding box

	if self.ducking then
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		end
	else
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 1, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 1, 0, 0, 0, 0 )
		end
	end


	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x - self.meleeHitboxSize, self.y, self.meleeHitboxSize, self.h)   --Left melee hitbox

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x + self.w, self.y, self.meleeHitboxSize, self.h)  --Right melee hitbox

	--love.graphics.setColor( 0, 255, 0, 255)
	--love.graphics.rectangle("fill", self.x - self.teleHitboxSize, self.y, self.teleHitboxSize, self.h)   --Left teleport hitbox

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x + self.w - self.ability.hitbox.width, self.y, self.ability.hitbox.width, self.ability.hitbox.height)   --Left melee hitbox

	--love.graphics.setColor( 255, 0, 0, 255)
	--love.graphics.rectangle("fill", self.x, self.y, self.ability.hitbox.width, self.ability.hitbox.height)  --Right melee hitbox

	--love.graphics.setColor( 0, 255, 0, 255)
	--love.graphics.rectangle("fill", self.x - self.teleHitboxSize, self.y, self.teleHitboxSize, self.h)   --Left teleport hitbox

	--love.graphics.setColor( 0, 255, 0, 255 )
	--love.graphics.rectangle("fill", self.x + self.w, self.y, self.teleHitboxSize, self.h)   --Right teleport hitbox

	if self.ducking then
		if self.facingright then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		elseif self.facingleft then
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.draw( self.image, self.x + self.spriteOffset_x, self.y + self.spriteOffset_y, 0, 1, 0.5, 0, 0, 0, 0 )
		end
	end
end

--function player:melee()
--	print("MELEE")
--	self.ability.delay = 0
--	self.ability.damage = 10
--	self.ability.knockback.x = 1000
--	self.ability.knockback.y = -1000
--	self.ability.enemyDelay = 02
--	self.ability.hitbox.x = 0
--	self.ability.hitbox.y = -25
--	self.ability.hitbox.width = 30
--	self.ability.hitbox.height = 50
--	player:attack()
--end

function player:setChargeTimer()
	print("CHARGING")
	self.charging=true
end

function player:chargedMelee()
	print(self.charge)
	if self.charge>2 then
		self.ability.delay = 0
		self.ability.damage = 20
		self.ability.knockback.x = 1000
		self.ability.knockback.y = -2000
		self.ability.enemyDelay = 0
		self.ability.hitbox.x = 0
		self.ability.hitbox.y = 0
		self.ability.hitbox.width = 40
		self.ability.hitbox.height = 54
		player:attack()
	end
	self.charging=false
	self.charge=0
end

function player:setBasicAttack()
	self.ability.cooldown = 0
	self.ability.delay = 0
	self.ability.enemyDelay = 0
	self.ability.damage = BASE_MELEE_DAMAGE
	self.ability.knockback.x = 0
	self.ability.knockback.y = 0
	self.ability.hitbox.x = 0
	self.ability.hitbox.y = 0
	self.ability.hitbox.width = 40
	self.ability.hitbox.height = 54
end

function player:setSequenceAttack(count)
	if count == 4 then
		self.ability.cooldown = 0
		self.ability.delay = 0
		self.ability.enemyDelay = 0
		self.ability.damage = 2 * BASE_MELEE_DAMAGE
		self.ability.knockback.x = 0
		self.ability.knockback.y = 0
		self.ability.hitbox.x = 0
		self.ability.hitbox.y = 0
		self.ability.hitbox.width = 40
		self.ability.hitbox.height = 54
		print("Executing special attack 1!")
	elseif count == 5 then
		self.ability.cooldown = 0
		self.ability.delay = 0
		self.ability.enemyDelay = 0
		self.ability.damage = 2 * BASE_MELEE_DAMAGE
		self.ability.knockback.x = 0
		self.ability.knockback.y = 0
		self.ability.hitbox.x = 0
		self.ability.hitbox.y = 0
		self.ability.hitbox.width = 40
		self.ability.hitbox.height = 54
		self.brutality:addBrutality(1,1)
		print("Executing special attack 2!")
	elseif count == 6 then
		self.ability.cooldown = 0
		self.ability.delay = 0
		self.ability.enemyDelay = 0
		self.ability.damage = 3 * BASE_MELEE_DAMAGE
		self.ability.knockback.x = 50
		self.ability.knockback.y = -1000
		self.ability.hitbox.x = 0
		self.ability.hitbox.y = 0
		self.ability.hitbox.width = 40
		self.ability.hitbox.height = 54
		self.brutality:addBrutality(2,1)
		print("Executing special attack 3!")
	end
end

function player:teleport()
	if self.facingright then
		print("teleport right!")
		for i, ent in pairs(ents.objects) do
			if ent.x > self.x + self.w and ent.x < self.x + self.w + self.teleHitboxSize
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then
				if ent.type == "hellhound" then
					ydiff = self.h - ent.h
					xdiff = ent.w - self.w
					ent.x, self.x = self.x, ent.x + xdiff
					ent.y, self.y = self.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
	if self.facingleft then
		print("teleport left!")
		for i, ent in pairs(ents.objects) do
			if ent.x + ent.w > self.x - self.teleHitboxSize and ent.x + ent.w < self.x
			and ent.y < self.y + self.h	and ent.y + ent.h > self.y then
				if ent.type == "hellhound" then
					ydiff = self.h - ent.h
					xdiff = ent.w - self.w
					ent.x, self.x = self.x - xdiff, ent.x
					ent.y, self.y = self.y, ent.y
					print("teleport successful!")
				end
			end
		end
	end
end
