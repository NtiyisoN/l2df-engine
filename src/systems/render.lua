local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")
assert(type(love) == "table", "PhysixSystem works only under love2d environment")

local System = core.import "core.entities.system"
local settings = core.import "settings"
local UI = core.import "ui"

local BACKGROUND = 1
local GAME_OBJECTS = 2
local FOREGROUND = 3
local UI = 4

local RenderSystem = System:extend()

	function RenderSystem:init()
		self.scalex = 1
		self.scaley = 1
	end

	function RenderSystem:settingsupdated()
		self.layers = {
			love.graphics.newCanvas(settings.gameWidth, settings.gameHeight),
			love.graphics.newCanvas(settings.gameWidth, settings.gameHeight),
			love.graphics.newCanvas(settings.gameWidth, settings.gameHeight),
			love.graphics.newCanvas(settings.gameWidth, settings.gameHeight)
		}
	end

	function RenderSystem:resize(w, h)
		self.scalex = settings.global.width / settings.gameWidth
		self.scaley = settings.global.height / settings.gameHeight
	end

	function RenderSystem:draw()
		if not self.layers then return end

		self:drawEntities(BACKGROUND, self.groups.background.entities)
		self:drawEntities(GAME_OBJECTS, self.groups.objects.entities)
		self:drawEntities(FOREGROUND, self.groups.foreground.entities)
		self:drawEntities(UI, self.groups.ui.entities)

		-- Draw all canvases
		for i = 1, #self.layers do
			love.graphics.draw(self.layers[i], 0, 0, 0, self.scalex, self.scaley)
		end
	end

	function RenderSystem:drawEntities(layer, entities)
		if not self.layers then return end

		love.graphics.setCanvas(self.layers[layer])
		love.graphics.clear()
		local enumeration = { {entities, 1, #entities} }
		local current = enumeration[1]
		local node = nil
		local head = 1
		local i = 1

		while head > 1 or i <= current[3] do
			node = current[1][i]
			i = i + 1

			if node and not node.hidden and type(node.draw) == "function" then
				node.draw(node)
			end

			if node and node.childs and next(node.childs) then
				current[2] = i
				enumeration[head + 1] = { node.childs, 1, #node.childs }
				head = head + 1
				current = enumeration[head]
				i = 1
			elseif i > current[3] and head > 1 then
				head = head - 1
				current = enumeration[head]
				i = current[2]
			end
		end
		love.graphics.setCanvas()
	end

return RenderSystem