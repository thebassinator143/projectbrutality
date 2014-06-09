require("player")

function setupPS()
	image = love.graphics.newImage( "sprites/part1.png" )
	attackPS = love.graphics.newParticleSystem( image, 25 )		--Creates a new particle emitter (image, buffer)
	--attackPS:setPosition( 0, 0)				--Emitter position (x, y)
	attackPS:setOffset(0, 0)									--Offset of rotation point (x, y); if 0, particles rotate around their center
	attackPS:setBufferSize(25)									--Max amount of particles allowed
	attackPS:setEmissionRate(500)								--Particles emitted per second
	attackPS:setLifetime(0.20)									--How long to emit particles (in seconds); set to -1 to emit forever
	attackPS:setParticleLife(0.20)								--Lifetime of the particles (in seconds)
	attackPS:setColors(0, 0, 0, 255)							--RGBA colors of particles; can list up to 8 colors to change between over lifetime
	attackPS:setSizes(0.5)										--Particle sizes; can list up to 8 to change between over lifetime; 1 = normal size
	attackPS:setSpeed(500, 500)									--Speed of particles (min, max)
	attackPS:setDirection(math.rad(-45))						--Direction the emitter should face, in radians; 0 = right
	attackPS:setSpread(math.rad(15))							--Amount the particles should spread after emission, in radians
	attackPS:setGravity(1000, 1000)								--Gravity affecting the particles (min, max)
	attackPS:setRotation(math.rad(0), math.rad(90))				--Initial rotation of the image upon emission, in radians (min, max)
	attackPS:setSpin(math.rad(0.5), math.rad(1), 1)				--Rate of spin, in radians per second (min, max)
	attackPS:setRadialAcceleration(0)							--Acceleration away from the emitter (min, max)
	attackPS:setTangentialAcceleration(0)						--Acceleration perpendicular to the particle's direction (min, max)	
end