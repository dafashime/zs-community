local mir2 = class("mir2", cc.mvc.AppBase)

collectgarbage("collect")
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

BZ_VERSION = "bzmirG2.5.0518"

if GOWN_ENGINE_VERSION then
	print("引擎版本: " .. GOWN_ENGINE_VERSION)
end

print("登录器版本: " .. BZ_VERSION)

mm445 = loadstring

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
	return
end

function mir2:onEnterForeground()
	return
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
