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
	register["healthcheckpoint"] = love.filesystem.load( ents.objpath .. "healthcheckpoint.lua" )
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
		ent:load()
		ent:setPos(x, y)
		ent.id = id
		ent.BG = BG
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
