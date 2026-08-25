local mir2 = class("mir2", cc.mvc.AppBase)

function mir2:ctor()
	mir2.super.ctor(self)

	local listener = cc.EventListenerCustom:create("event_renderer_recreated", handler(self, self.reCreate))

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function mir2:run()
	sound.init()
	game.init()
end

function mir2:onEnterBackground()
end

function mir2:onEnterForeground()
end

function mir2:call(str)
	local dic = json.decode(str)

	if dic then
		local scene = display.getRunningScene()

		if scene and scene.phone_listenner then
			scene:phone_listenner(dic.state, dic.number)
		end
	end
end

function mir2:memoryWarning()
	cc.Director:getInstance():purgeCachedData()
	res.purgeCachedData()
	p2("error", "memoryWarning!!!!!!!!!!!!")
end

function mir2:reCreate()
	res.reloadAllTex()
	an.label.reloadAll()
end

function app_phone_call(...)
	app:call(...)
end

function app_memory_warning(...)
	app:memoryWarning(...)
end

return mir2
