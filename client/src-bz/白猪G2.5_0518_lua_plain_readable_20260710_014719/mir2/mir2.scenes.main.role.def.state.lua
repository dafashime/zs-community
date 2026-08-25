local states = {
	csNoDieState = 49,
	csAssCritHit = 64,
	csAttPoisonMove = 65,
	csDingShen = 45,
	StBlueDiamond = 4,
	stStone = 0,
	csRelive = 48,
	stPoisonYellow = 28,
	csTmpSSk = 50,
	csTmpStrength = 44,
	stBloodWarrior = 6,
	stNil_UsedByClient = 10,
	csVioletPoision = 53,
	StSskTaoist = 8,
	stWEBS = 24,
	csAttYLB = 67,
	csTmpHQ = 74,
	stPoisonRed = 30,
	csDominateBuf = 61,
	csSXSL = 56,
	csNB = 62,
	stReleaseStone = 18,
	stMACShield = 21,
	stHeroLongHit = 3,
	csTmpMAC = 41,
	csNoDamage = 55,
	csWJD = 59,
	csWJZQ = 43,
	csRealHide = 60,
	stACShield = 22,
	stZeroShield = 17,
	csNil_48 = 47,
	csTmpSC = 34,
	csHMSF = 57,
	csTmpNearHit = 76,
	csTmpMaxHP = 36,
	csAssLK = 69,
	csTmpMC = 33,
	csHorseRider = 52,
	csZaiMaShang = 51,
	csAssXJRS = 71,
	csNil_47 = 46,
	stPoisonStone = 26,
	stHackQuest = 25,
	stDenyMagic = 16,
	stOpenHealth = 1,
	csTmpDC = 32,
	stFreeze = 29,
	stPoisonGreen = 31,
	stJFBF = 9,
	stDragonState = 14,
	csDurativeVioletDmg = 73,
	StDzxyFull = 11,
	csTmpUnion = 75,
	csRevenge = 42,
	csTmpDCSpeed = 35,
	StSskWizard = 7,
	csDecTmpDefence = 54,
	csBurn = 78,
	csZLHT = 63,
	csTmpAM = 39,
	csJinghun = 81,
	stPoisonFuchsia = 27,
	StYellowDiamond = 5,
	stManaProtected = 15,
	csPoisonMove = 66,
	stHidden = 23,
	csTmpMaxMP = 37,
	csTmpQR = 38,
	csDurativeSdsDmg = 72,
	csBleeding = 80,
	stMagicShieldEx = 19,
	stAlwaysShowName = 2,
	csTmpAC = 40,
	csAttHLKW = 68,
	stMagicShield = 20,
	csAssRXPK = 70,
	csTmpCC = 77,
	csLieHun = 79,
	stAutoLFTrain = 12,
	csDominaterPet = 58,
	stPoisonBlue = 13
}
local def = {}

function def.stateHas(state, key)
	if type(state) == "number" then
		local stateNum = state

		state = getRecord("TAllBodyState")
		state:get("state")[1] = stateNum
	end

	local value = states[key]

	if not value then
		return
	end

	if value <= 31 then
		return ycFunction:band(state:get("state")[1], ycFunction:lshift(1, value)) ~= 0
	elseif value <= 63 then
		return ycFunction:band(state:get("state")[2], ycFunction:lshift(1, value)) ~= 0
	elseif value <= 95 then
		return ycFunction:band(state:get("state")[3], ycFunction:lshift(1, value)) ~= 0
	elseif value <= 127 then
		return ycFunction:band(state:get("state")[4], ycFunction:lshift(1, value)) ~= 0
	end
end

function def.addState(state, key)
	if type(state) == "number" then
		local stateNum = state

		state = getRecord("TAllBodyState")
		state:get("state")[1] = stateNum
	end

	local value = states[key]

	if not value then
		return
	end

	if value <= 31 then
		state:get("state")[1] = ycFunction:bor(state:get("state")[1], ycFunction:lshift(1, value))
	elseif value <= 63 then
		state:get("state")[2] = ycFunction:bor(state:get("state")[2], ycFunction:lshift(1, value))
	elseif value <= 95 then
		state:get("state")[3] = ycFunction:bor(state:get("state")[3], ycFunction:lshift(1, value))
	elseif value <= 127 then
		state:get("state")[4] = ycFunction:bor(state:get("state")[4], ycFunction:lshift(1, value))
	end
end

function def.removeState(state, key)
	if type(state) == "number" then
		local stateNum = state

		state = getRecord("TAllBodyState")
		state:get("state")[1] = stateNum
	end

	local value = states[key]

	if not value then
		return
	end

	local function remove(n)
		if ycFunction:band(state:get("state")[n], ycFunction:lshift(1, value)) then
			state:get("state")[n] = ycFunction:bxor(state:get("state")[1], ycFunction:lshift(1, value))
		end
	end

	if value <= 31 then
		remove(1)
	elseif value <= 63 then
		remove(2)
	elseif value <= 95 then
		remove(3)
	elseif value <= 127 then
		remove(4)
	end
end

return def
