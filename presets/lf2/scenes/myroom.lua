local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local Physix = core.import 'core.class.component.physix'
local event = core.import 'core.manager.event'

local RM = core.import 'core.manager.resource'

local Object = core.import 'core.class.entity.object'

local ball = Object {
	sprites = { 'sprites/test/ball.png', 50, 50, 1, 1 },
	x = 100,
	y = 200,
}

local wall = Object {
	sprites = { "sprites/test/5.png" },
	x = 100,
	y = 200,
}

local wall2 = Object {
	sprites = { "sprites/test/5.png" },
	x = 550,
	y = 200,
}

local room = Scene {
	nodes = {
		ball,
		--wall,
		--wall2
	}
}


f = function (_, key)
	if key == 'a' then
		ball.vars.dvx = -45
	elseif key == 'd' then
		ball.vars.dvx = 45
	elseif key == 'y' then
		RM:loadAsync("sprites/UI/big.png", true)
	elseif key == 'u' then
		local object_without_sprite = Object:new {
			x = 0,
			y = 0
		}
		room:attach(object_without_sprite)
	end
end

event:subscribe('keypressed', f)

return room