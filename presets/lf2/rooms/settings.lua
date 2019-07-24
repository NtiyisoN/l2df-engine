local l2df = l2df
local ui = l2df.ui
local i18n = l2df.i18n
local settings = l2df.settings

local fnt_caption = l2df.font.list.setting_header
local fnt_button = l2df.font.list.setting_element

local room = { }

	local list = ui.List(512, 32, {
			ui.Button(ui.Text("settings.language", fnt_button), 0, 0):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () i18n:setLocale() end),

			ui.Button(ui.Text("settings.music", fnt_button), 0, 64):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end),

			ui.Button(ui.Text("settings.effects", fnt_button), 0, 128):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end),

			ui.Button(ui.Text("settings.save", fnt_button), 0, 192):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () settings:save() end),

			ui.Button(ui.Text("settings.back", fnt_button), 0, 256):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () l2df.rooms:set("menu") end),
		})

	room.nodes = {
		ui.Text("settings.caption", fnt_caption, 250, 20, { 0, 0, 0, 1 }):show(),
		ui.Image("sprites/UI/background.png", 0, 0, nil, "linear"),
		list,
	}

	function room:load()
		self.selected = 1
		self.opacity = 0.1
		self.opacity_change = 0.0015
		self.selected_size = 1
		self.list = { }
		self.saved_timer = 0

		-- local setting = {
		-- 	option = locale.settings.language,
		-- 	status = locale.language
		-- }
		-- function setting:action_left()
		-- 	local local_id = loc.id - 1
		-- 	if local_id < 1 then local_id = #loc.list end
		-- 	loc:Set(local_id)
		-- 	rooms:Reload()
		-- end
		-- function setting:action_right()
		-- 	local local_id = loc.id + 1
		-- 	if local_id > #loc.list then local_id = 1 end
		-- 	loc:Set(local_id)
		-- 	rooms:Reload()
		-- end


		-- local setting = {
		-- 	option = locale.settings.music,
		-- 	status = ""
		-- }
		-- function setting:update()	
		-- 	self.status = ""	
		-- 	for i = 1, settings.window.music_vol * 0.2 do
		-- 		self.status = self.status .. "I"
		-- 	end
		-- end
		-- function setting:action_left()
		-- 	if settings.window.music_vol > 0 then settings.window.music_vol = settings.window.music_vol - 5 end
		-- 	sounds.setVolume(settings.window.music_vol)
		-- end
		-- function setting:action_right()
		-- 	if settings.window.music_vol < 100 then settings.window.music_vol = settings.window.music_vol + 5 end
		-- 	sounds.setVolume(settings.window.music_vol)
		-- end
		-- table.insert(self.list, setting)



		-- local setting = {
		-- 	option = locale.settings.effects,
		-- 	status = ""
		-- }
		-- function setting:update()	
		-- 	self.status = ""	
		-- 	for i = 1, settings.window.sound_vol * 0.2 do
		-- 		self.status = self.status .. "I"
		-- 	end
		-- end
		-- function setting:action_left()
		-- 	if settings.window.sound_vol > 0 then settings.window.sound_vol = settings.window.sound_vol - 5 end
		-- end
		-- function setting:action_right()
		-- 	if settings.window.sound_vol < 100 then settings.window.sound_vol = settings.window.sound_vol + 5 end
		-- end
		-- table.insert(self.list, setting)


		-- local setting = {
		-- 	option = locale.settings.graphic,
		-- 	status = ""
		-- }
		-- function setting:update()
		-- 	if settings.quality then
		-- 		self.status = locale.settings.normal
		-- 	else
		-- 		self.status = locale.settings.low
		-- 	end
		-- end
		-- function setting:action_left()
		-- 	settings.quality = not settings.quality
		-- end
		-- function setting:action_right()
		-- 	settings.quality = not settings.quality
		-- end
		-- table.insert(self.list, setting)




		-- local setting = {
		-- 	option = locale.settings.fullscreen,
		-- 	status = ""
		-- }
		-- function setting:update()
		-- 	if settings.window.fullscreen == true then setting.status = locale.settings.on
		-- 	else setting.status = locale.settings.off end
		-- end
		-- function setting:action_left()
		-- 	settings.window.fullscreen = not settings.window.fullscreen
		-- 	helper.SetWindowSize()
		-- end
		-- function setting:action_right()
		-- 	settings.window.fullscreen = not settings.window.fullscreen
		-- 	helper.SetWindowSize()
		-- end
		-- table.insert(self.list, setting)


		-- local setting = {
		-- 	option = locale.settings.window_size,
		-- 	status = ""
		-- }
		-- function setting:update()
		-- 	self.status = settings.windowSizes[room.selected_size].width .." x ".. settings.windowSizes[room.selected_size].height
		-- 	if settings.window.fullscreen then
		-- 		self.hidden = true
		-- 	else
		-- 		self.hidden = false
		-- 	end
		-- end
		-- function setting:action_left()
		-- 	room.selected_size = room.selected_size - 1
		-- 	if room.selected_size < 1 then room.selected_size = #settings.windowSizes end
		-- end
		-- function setting:action_right()
		-- 	room.selected_size = room.selected_size + 1
		-- 	if room.selected_size > #settings.windowSizes then room.selected_size = 1 end
		-- end
		-- function setting:action_click()
		-- 	settings.window.selectedSize = room.selected_size
		-- 	helper.SetWindowSize()
		-- end
		-- table.insert(self.list, setting)


		-- local setting = {
		-- 	option = locale.settings.controls,
		-- 	status = ""
		-- }
		-- function setting:action_click ()
		-- 	rooms:Set("controls")
		-- end
		-- table.insert(self.list, setting)

		-- local setting = {
		-- 	option = locale.settings.save
		-- }
		-- function setting:update()
		-- 	if room.saved_timer > 0 then
		-- 		room.saved_timer = room.saved_timer - 1
		-- 		self.option = locale.settings.saved
		-- 	else
		-- 		self.option = locale.settings.save
		-- 	end
		-- end
		-- function setting:action_click ()
		-- 	room.saved_timer = 30
		-- 	settings:Save()
		-- end
		-- table.insert(self.list, setting)

		-- local setting = {
		-- 	option = locale.settings.back
		-- }
		-- function setting:action_click()
		-- 	rooms:Set("main_menu")
		-- end
		-- table.insert(self.list, setting)

	end

	function room:update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity < 0.05 or self.opacity > 0.15 then
			self.opacity_change = -self.opacity_change
		end
	end

	function room:draw()		
		local width = 750
		local height = 50
		local x_pos = 250
		local y_pos = 60
		local margin = 10

		for i = 1, #self.list do
			local y = y_pos + (height + margin) * i
			if self.selected == i then
				love.graphics.setColor(0, 0, 0, self.opacity)
				love.graphics.rectangle("fill", x_pos, y - height * 0.05, width, height)
				love.graphics.setColor(1, 1, 1, 1)
			end
			local text_opacity = 1
			if self.list[i].hidden == true then
				text_opacity = 0.5
			end
			if self.list[i].option ~= nil then
				font.print(self.list[i].option, x_pos + 50, y, nil, font.list.setting_element, 0, width, 0, 0, 0, text_opacity)
			end
			if self.list[i].status ~= nil then
				font.print(self.list[i].status, x_pos + 450, y, nil, font.list.setting_element, true, width, 0, 0, 0, text_opacity)
			end
			love.graphics.setColor(1, 1, 1, 1)
		end
	end


	-- function room:keypressed(key)

	-- 	if key == settings.controls[1].up or key == settings.controls[2].up then
	-- 		self.selected = self.selected - 1
	-- 		if self.selected < 1 then self.selected = #self.list end
	-- 		local hidden_exit = true
	-- 		while hidden_exit do 
	-- 			if self.list[self.selected].hidden then
	-- 				self.selected = self.selected - 1
	-- 				if self.selected < 1 then self.selected = #self.list end
	-- 			else hidden_exit = false end
	-- 		end
	-- 	end

	-- 	if key == settings.controls[1].down or key == settings.controls[2].down then
	-- 		self.selected = self.selected + 1
	-- 		if self.selected > #self.list then self.selected = 1 end
	-- 		local hidden_exit = true
	-- 		while hidden_exit do 
	-- 			if self.list[self.selected].hidden then
	-- 				self.selected = self.selected + 1
	-- 				if self.selected > #self.list then self.selected = 1 end
	-- 			else hidden_exit = false end
	-- 		end
	-- 	end

	-- 	if key == settings.controls[1].attack or key == settings.controls[2].attack then
	-- 		if self.list[self.selected].action_click ~= nil then
	-- 			self.list[self.selected]:action_click()
	-- 		end
	-- 	end

	-- 	if key == settings.controls[1].left or key == settings.controls[2].left then
	-- 		if self.list[self.selected].action_left ~= nil then
	-- 			self.list[self.selected]:action_left()
	-- 		end
	-- 	end

	-- 	if key == settings.controls[1].right or key == settings.controls[2].right then
	-- 		if self.list[self.selected].action_right ~= nil then
	-- 			self.list[self.selected]:action_right()
	-- 		end
	-- 	end

	-- 	if key == "f1" then rooms:Set("controls") end
	-- 	if key == "escape" or key == settings.controls[1].jump or key == settings.controls[2].jump then
	-- 		rooms:Set("main_menu")
	-- 	end
	-- end

return room