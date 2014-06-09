require("player")

function setupPS()
	image = love.graphics.newImage( "sprites/part1.png" )
	attackPS = love.graphics.newParticleSystem( image, 25 )		--Creates a new particle emitter (image, buffer)
	attackPS:setPosition(0, 0)									--Emitter position (x, y)
	attackPS:setOffset(0, 0)									--Offset of rotation point (x, y); if 0, particles rotate around their center
	attackPS:setBufferSize(50)									--Max amount of particles allowed
	attackPS:setEmissionRate(1000)								--Particles emitted per second
	attackPS:setLifetime(0.15)									--How long to emit particles (in seconds); set to -1 to emit forever
	attackPS:setParticleLife(0.15)								--Lifetime of the particles (in seconds)
	attackPS:setColors(148, 148, 148, 255, 0, 0, 0, 100)		--RGBA colors of particles; can list up to 8 colors to change between over lifetime
	attackPS:setSizes(0.1)										--Particle sizes; can list up to 8 to change between over lifetime; 1 = normal size
	attackPS:setSpeed(500, 500)									--Speed of particles (min, max)
	attackPS:setDirection(math.rad(15))							--Direction the emitter should face, in radians; 0 = right
	attackPS:setSpread(math.rad(5))								--Amount the particles should spread after emission, in radians
	attackPS:setGravity(-2000, -2000)							--Gravity affecting the particles (min, max)
	attackPS:setRotation(math.rad(0), math.rad(0))				--Initial rotation of the image upon emission, in radians (min, max)
	attackPS:setSpin(math.rad(180), math.rad(180), 1)			--Rate of spin, in radians per second (min, max)
	attackPS:setRadialAcceleration(0)							--Acceleration away from the emitter (min, max)
	attackPS:setTangentialAcceleration(0)						--Acceleration perpendicular to the particle's direction (min, max)	
	
	--Explosion
	--image = love.graphics.newImage( "sprites/part1.png" )
	--attackPS = love.graphics.newParticleSystem( image, 25 )	--Creates a new particle emitter (image, buffer)
	--attackPS:setPosition(0, 0)								--Emitter position (x, y)
	--attackPS:setOffset(0, 0)									--Offset of rotation point (x, y); if 0, particles rotate around their center
	--attackPS:setBufferSize(25)								--Max amount of particles allowed
	--attackPS:setEmissionRate(500)								--Particles emitted per second
	--attackPS:setLifetime(0.20)								--How long to emit particles (in seconds); set to -1 to emit forever
	--attackPS:setParticleLife(0.20)							--Lifetime of the particles (in seconds)
	--attackPS:setColors(255, 0, 0, 255, 255, 128, 0, 255, 255, 255, 255, 255)		--RGBA colors of particles; can list up to 8 colors to change between over lifetime
	--attackPS:setSizes(0.3, 0.2, 0.1)							--Particle sizes; can list up to 8 to change between over lifetime; 1 = normal size
	--attackPS:setSpeed(500, 500)								--Speed of particles (min, max)
	--attackPS:setDirection(math.rad(-45))						--Direction the emitter should face, in radians; 0 = right
	--attackPS:setSpread(math.rad(360))							--Amount the particles should spread after emission, in radians
	--attackPS:setGravity(1000, 1000)							--Gravity affecting the particles (min, max)
	--attackPS:setRotation(math.rad(0), math.rad(90))			--Initial rotation of the image upon emission, in radians (min, max)
	--attackPS:setSpin(math.rad(0.5), math.rad(1), 1)			--Rate of spin, in radians per second (min, max)
	--attackPS:setRadialAcceleration(0)							--Acceleration away from the emitter (min, max)
	--attackPS:setTangentialAcceleration(0)						--Acceleration perpendicular to the particle's direction (min, max)	
end