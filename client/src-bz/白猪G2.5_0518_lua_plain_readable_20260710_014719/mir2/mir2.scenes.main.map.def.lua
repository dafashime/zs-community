local def = {
	ET_BIRTHDAY_FIRE = 30,
	ET_SOULMATE = 79,
	ET_CAKEFIRE = 8,
	ET_WORLDBOSS = 34,
	ET_INTENTLY = 78,
	ET_ASS_BZXJ = 37,
	ET_YanHuaTextEvent = 23,
	ET_MIRMATCH_RANDBUFF = 40,
	ET_DANCEOFTHESKY = 83,
	ET_ICESEAT = 18,
	ET_Flood = 24,
	loadNum = 500,
	ET_SWEETDREAMS = 82,
	ET_DAMAGETRAP = 28,
	ET_DIGOUTZOMBI = 1,
	ET_STALL_EVENT = 41,
	ET_SWMY_PLUS = 32,
	ET_SWMY = 31,
	ET_SCULPEICE = 6,
	ET_MAGICDOOR = 9,
	CAKEFIREBASE = 320,
	ET_PILESTONES = 3,
	ET_YanChenEvent = 25,
	topTag = 7000000,
	ET_GetEXP = 19,
	ET_ROMANTICSTARRAIN = 81,
	ET_FIRE = 5,
	ET_FIREDRAG = 16,
	ET_SPRING = 14,
	ET_TBDL_FIRE = 39,
	ET_DIGINZOMBI = 7,
	ET_FLYINGFIREBALL = 80,
	ET_FootBallEvent = 22,
	ET_HOLYCURTAIN = 4,
	ET_SUCHASFOGDREAM = 84,
	ET_RELEASE_FIRE = 20,
	ET_BTFIRE = 21,
	ET_ASS_BZXJ_PLUS = 38,
	ET_revIceberg = 33,
	ET_CACHOT = 29,
	loadOutsideAreaBottom = 15,
	ET_FIVE_EARTH_ELEMENT = 36,
	loadOutsideArea = 1,
	ET_Iceberg = 27,
	ET_MAGICGATE = 17,
	ET_FIREDRAGONSTATUARY = 15,
	tile = {
		w = 48,
		h = 32
	},
	doorPoint = {}
}

scheduler.performWithDelayGlobal(function()
	local cfg = res.getfile("config/doorPoint.txt")
	local doorPoint = {}
	local datas = string.split(cfg, "\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ",")
			local id = data[1]

			doorPoint[id] = doorPoint[id] or {}
			doorPoint[id][#doorPoint[id] + 1] = {
				x = tonumber(data[2]),
				y = tonumber(data[3]),
				terminal = data[4]
			}
		end
	end

	def.doorPoint = doorPoint
end, 0)

return def
