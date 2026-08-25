print("gameData.init")

local gameData = {
	player = import(".player"),
	map = import(".map"),
	serverConfig = import(".serverConfig"),
	bag = import(".bag"),
	guild = import(".guild"),
	equip = import(".equip"),
	chat = import(".chat"),
	client = import(".client"),
	hero = import(".hero"),
	heroBag = import(".heroBag"),
	heroEquip = import(".heroEquip"),
	relation = import(".relation"),
	stall = import(".stall"),
	stallOther = import(".stallOther"),
	mail = import(".mail"),
	ybdeal = import(".ybdeal"),
	voice = import(".voice"),
	mark = import(".mark"),
	credit = import(".credit"),
	mixingDrug = import(".mixingDrug"),
	hotKey = import(".hotKey")
}
g_data = {
	login = import(".login"),
	select = import(".select"),
	setting = import(".setting"),
	bigmap = import(".bigmap"),
	security = import(".security"),
	shop = import(".shop"),
	reconnct = {},
	cleanup = function ()
		for k, v in pairs(g_data) do
			if type(v) == "table" and v.cleanup then
				v:cleanup()
			end
		end
	end
}

function g_data.reset()
	for k, v in pairs(gameData) do
		gameData[k]._data_reset = function ()
			g_data[k] = clone(v)
		end

		gameData[k]._data_reset()
	end
end

g_data.reset()
