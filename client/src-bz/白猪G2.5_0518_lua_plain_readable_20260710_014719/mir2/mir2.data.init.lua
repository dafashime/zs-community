print("gameData.init")

local gameData = {}

gameData.player = import(".player")
gameData.map = import(".map")
gameData.serverConfig = import(".serverConfig")
gameData.bag = import(".bag")
gameData.guild = import(".guild")
gameData.equip = import(".equip")
gameData.chat = import(".chat")
gameData.client = import(".client")
gameData.hero = import(".hero")
gameData.heroBag = import(".heroBag")
gameData.heroEquip = import(".heroEquip")
gameData.relation = import(".relation")
gameData.stall = import(".stall")
gameData.stallOther = import(".stallOther")
gameData.mail = import(".mail")
gameData.ybdeal = import(".ybdeal")
gameData.voice = import(".voice")
gameData.mark = import(".mark")
gameData.credit = import(".credit")
gameData.mixingDrug = import(".mixingDrug")
gameData.hotKey = import(".hotKey")
g_data = {}
g_data.login = import(".login")
g_data.select = import(".select")
g_data.setting = import(".setting")
g_data.bigmap = import(".bigmap")
g_data.security = import(".security")
g_data.shop = import(".shop")
g_data.reconnct = {}

function g_data.cleanup()
	for k, v in pairs(g_data) do
		if type(v) == "table" and v.cleanup then
			v:cleanup()
		end
	end
end

function g_data.reset()
	for k, v in pairs(gameData) do
		gameData[k]._data_reset = function()
			g_data[k] = clone(v)
		end

		gameData[k]._data_reset()
	end
end

g_data.reset()
