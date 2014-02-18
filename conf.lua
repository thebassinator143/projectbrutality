function love.conf(t)
	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.thead = true
	t.modules.physics = true
	t.console = true
	t.title = "Platformer"
	t.author = "Evan Boss"
	t.screen.fullscreen = false
	t.screen.vsync = false
	t.screen.fsaa = 0
	t.screen.height = 600
	t.screen.width = 800
end