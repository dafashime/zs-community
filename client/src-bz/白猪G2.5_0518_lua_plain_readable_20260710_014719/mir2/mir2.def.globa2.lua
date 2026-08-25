local def = {
	TClientMessage = {
		{
			"uint",
			"sign"
		},
		{
			"byte",
			"reservationByte"
		},
		{
			"byte",
			"cmd"
		},
		{
			"short",
			"dataLength"
		},
		{
			"uint",
			"dataIndex"
		}
	},
	TDefaultMessage = {
		{
			"int",
			"recog"
		},
		{
			"short",
			"ident"
		},
		{
			"short",
			"param"
		},
		{
			"short",
			"tag"
		},
		{
			"short",
			"series"
		}
	},
	TGSDateLen = {
		{
			"short",
			"itemLen"
		},
		{
			"short",
			"magicLen"
		},
		{
			"record",
			"gsTime",
			"TDateTime"
		},
		{
			"uint",
			"gsVersionEx"
		}
	},
	TServerGroupInfo = {
		{
			"char*",
			"groupName",
			15
		},
		{
			"char*",
			"groupDesc",
			23
		}
	},
	TClientNearbyGroupInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"string",
			"guildName",
			15
		}
	},
	TClientGroupMemInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"isonline"
		},
		{
			"string",
			"guildName",
			31
		},
		{
			"byte",
			"isCaptain"
		}
	},
	TSelectServerMsg = {
		{
			"int",
			"areaID"
		},
		{
			"int",
			"groupID"
		},
		{
			"byte",
			"sdoa"
		},
		{
			"byte",
			"other1"
		},
		{
			"byte",
			"other2"
		},
		{
			"byte",
			"other3"
		},
		{
			"char*",
			"suffix",
			7
		}
	},
	TSelectServerMsg2 = {
		{
			"record",
			"oldMsg",
			"TSelectServerMsg"
		},
		{
			"char*",
			"serverName",
			15
		}
	},
	TLoginIdResult = {
		{
			"char*",
			"ptID",
			20
		},
		{
			"char*",
			"digitID",
			20
		},
		packed = true
	},
	TLoginIdResult2 = {
		{
			"char*",
			"oldMsg",
			20
		},
		{
			"char*",
			"serverName",
			20
		},
		{
			"int",
			"areaID"
		},
		{
			"int",
			"groupID"
		},
		{
			"string",
			"reconnectID",
			36
		},
		packed = true
	},
	TLoginIdLast = {
		{
			"int",
			"areaID"
		},
		{
			"int",
			"groupID"
		},
		{
			"string",
			"reconnectID",
			36
		},
		packed = true
	},
	TMirCharInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"hair"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"level"
		}
	},
	TMirCharinfoEx = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"hair"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"sex"
		},
		{
			"short",
			"level"
		}
	},
	TOsVersion3 = {
		{
			"int",
			"major"
		},
		{
			"int",
			"minor"
		},
		{
			"int",
			"build"
		},
		{
			"int",
			"memSize"
		},
		{
			"int",
			"usingIGW"
		},
		{
			"int",
			"oemID"
		},
		{
			"char*",
			"cpuName",
			47
		},
		{
			"int",
			"videoMemorySize"
		},
		{
			"int",
			"isVirtualMachine"
		},
		packed = true
	},
	TMessageCapitalInfo = {
		{
			"int",
			"linfu"
		},
		{
			"int",
			"yuanbao"
		},
		{
			"int",
			"diamon"
		},
		{
			"int",
			"limitLf"
		},
		{
			"int",
			"silver"
		},
		{
			"int",
			"silverExp"
		}
	},
	TFeature = {
		{
			"short",
			"race"
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"hair"
		},
		{
			"short",
			"weapon"
		},
		{
			"short",
			"dress"
		},
		{
			"short",
			"riding"
		},
		packed = true
	},
	TAllBodyState = {
		{
			"array",
			"state",
			4,
			"int"
		}
	},
	TPlayerState = {
		{
			"uint",
			"outs"
		},
		{
			"record",
			"allBodyState",
			"TAllBodyState"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"resv"
		}
	},
	TPlayerStateEx = {
		{
			"uint",
			"outs"
		},
		{
			"record",
			"allBodyState",
			"TAllBodyState"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"resv"
		},
		{
			"record",
			"feature",
			"TFeature"
		}
	},
	TCharDesc = {
		{
			"int",
			"feature"
		},
		{
			"record",
			"status",
			"TAllBodyState"
		}
	},
	TNewCharDesc = {
		{
			"uint",
			"outlook"
		},
		{
			"record",
			"status",
			"TAllBodyState"
		},
		{
			"record",
			"feature",
			"TFeature"
		}
	},
	TNewStateRec = {
		{
			"short",
			"len"
		},
		{
			"uint",
			"outlook"
		},
		{
			"record",
			"status",
			"TAllBodyState"
		},
		{
			"uint",
			"nameClr"
		},
		{
			"int",
			"specState"
		},
		{
			"record",
			"feature",
			"TFeature"
		},
		{
			"byte",
			"job"
		},
		packed = true
	},
	TClientPhyAttRec = {
		{
			"short",
			"hitMode"
		},
		{
			"short",
			"skillLv"
		},
		{
			"short",
			"specEffect"
		},
		{
			"short",
			"dir"
		},
		{
			"short",
			"x"
		},
		{
			"short",
			"y"
		}
	},
	TSubAbility = {
		{
			"short",
			"hitPoint"
		},
		{
			"byte",
			"speedPoint"
		},
		{
			"short",
			"antiPoison"
		},
		{
			"short",
			"poisonRecover"
		},
		{
			"byte",
			"healthRecover"
		},
		{
			"byte",
			"spellRecover"
		},
		{
			"byte",
			"antiMagic"
		}
	},
	TSub2Ability = {
		{
			"short",
			"eqShareRate"
		},
		{
			"short",
			"equipForceResume"
		},
		{
			"short",
			"equipForceDC"
		},
		{
			"short",
			"equipForceAC"
		}
	},
	TSub3Ability = {
		{
			"short",
			"attackLuck"
		},
		{
			"short",
			"equipHolyVal"
		},
		{
			"int",
			"suckBloodVal"
		},
		{
			"int",
			"hpLevel"
		},
		{
			"int",
			"mpLevel"
		},
		{
			"short",
			"unBreakVal"
		},
		{
			"short",
			"breakHitVal"
		},
		{
			"int",
			"prestige"
		},
		{
			"short",
			"pkValue"
		},
		{
			"short",
			"forceDmgVal"
		},
		{
			"int",
			"unionAttPower"
		},
		{
			"short",
			"freezeAntiAbil"
		},
		{
			"short",
			"directAttProb"
		},
		{
			"short",
			"mp_restore"
		},
		{
			"short",
			"hp_restore"
		},
		{
			"short",
			"hpmp_restore"
		},
		{
			"short",
			"hq_fastness"
		},
		{
			"short",
			"union_fastness"
		},
		{
			"short",
			"near_fastness"
		},
		{
			"short",
			"lj_fastness"
		},
		{
			"int",
			"cc"
		},
		{
			"int",
			"maxcc"
		}
	},
	TAbility = {
		{
			"short",
			"level"
		},
		{
			"short",
			"hitRate"
		},
		{
			"short",
			"quickRate"
		},
		{
			"short",
			"hpResume"
		},
		{
			"short",
			"mpResume"
		},
		{
			"short",
			"poisAC"
		},
		{
			"short",
			"poisResume"
		},
		{
			"short",
			"antiMagic"
		},
		{
			"short",
			"attSpeed"
		},
		{
			"byte",
			"age"
		},
		{
			"int",
			"AC"
		},
		{
			"int",
			"maxAC"
		},
		{
			"int",
			"MAC"
		},
		{
			"int",
			"maxMAC"
		},
		{
			"int",
			"DC"
		},
		{
			"int",
			"maxDC"
		},
		{
			"int",
			"MC"
		},
		{
			"int",
			"maxMC"
		},
		{
			"int",
			"SC"
		},
		{
			"int",
			"maxSC"
		},
		{
			"int",
			"HP"
		},
		{
			"int",
			"maxHP"
		},
		{
			"int",
			"MP"
		},
		{
			"int",
			"maxMP"
		},
		{
			"uint",
			"Exp"
		},
		{
			"uint",
			"maxExp"
		},
		{
			"int",
			"weight"
		},
		{
			"int",
			"maxWeight"
		},
		{
			"int",
			"wearWeight"
		},
		{
			"int",
			"maxWearWeight"
		},
		{
			"int",
			"handWeight"
		},
		{
			"int",
			"maxHandWeight"
		},
		{
			"short",
			"buPoisResume"
		}
	},
	TAllAbility = {
		{
			"short",
			"level"
		},
		{
			"short",
			"hitRate"
		},
		{
			"short",
			"quickRate"
		},
		{
			"short",
			"hpResume"
		},
		{
			"short",
			"mpResume"
		},
		{
			"short",
			"poisAC"
		},
		{
			"short",
			"poisResume"
		},
		{
			"short",
			"antiMagic"
		},
		{
			"short",
			"magHit"
		},
		{
			"short",
			"attSpeed"
		},
		{
			"byte",
			"age"
		},
		{
			"int",
			"AC"
		},
		{
			"int",
			"maxAC"
		},
		{
			"int",
			"MAC"
		},
		{
			"int",
			"maxMAC"
		},
		{
			"int",
			"DC"
		},
		{
			"int",
			"maxDC"
		},
		{
			"int",
			"MC"
		},
		{
			"int",
			"maxMC"
		},
		{
			"int",
			"SC"
		},
		{
			"int",
			"maxSC"
		},
		{
			"int",
			"HP"
		},
		{
			"int",
			"maxHP"
		},
		{
			"int",
			"MP"
		},
		{
			"int",
			"maxMP"
		},
		{
			"uint",
			"Exp"
		},
		{
			"uint",
			"maxExp"
		},
		{
			"int",
			"weight"
		},
		{
			"int",
			"maxWeight"
		},
		{
			"int",
			"wearWeight"
		},
		{
			"int",
			"maxWearWeight"
		},
		{
			"int",
			"handWeight"
		},
		{
			"int",
			"maxHandWeight"
		},
		{
			"short",
			"buPoisResume"
		},
		{
			"short",
			"eqShareRate"
		},
		{
			"short",
			"equipForceResume"
		},
		{
			"short",
			"equipForceDC"
		},
		{
			"short",
			"equipForceAC"
		},
		{
			"short",
			"attackLuck"
		},
		{
			"short",
			"equipHolyVal"
		},
		{
			"int",
			"suckBloodVal"
		},
		{
			"int",
			"hpLevel"
		},
		{
			"int",
			"mpLevel"
		},
		{
			"short",
			"unBreakVal"
		},
		{
			"short",
			"breakHitVal"
		},
		{
			"int",
			"prestige"
		},
		{
			"short",
			"pkValue"
		},
		{
			"short",
			"forceDmgVal"
		},
		{
			"int",
			"unionAttPower"
		},
		{
			"short",
			"freezeAntiAbil"
		},
		{
			"short",
			"directAttProb"
		},
		{
			"short",
			"mp_restore"
		},
		{
			"short",
			"hp_restore"
		},
		{
			"short",
			"hpmp_restore"
		},
		{
			"short",
			"hq_fastness"
		},
		{
			"short",
			"union_fastness"
		},
		{
			"short",
			"near_fastness"
		},
		{
			"short",
			"lj_fastness"
		},
		{
			"int",
			"cc"
		},
		{
			"int",
			"maxcc"
		}
	},
	TOldClientAbility = {
		{
			"byte",
			"level"
		},
		{
			"byte",
			"hitRate"
		},
		{
			"byte",
			"quickRate"
		},
		{
			"byte",
			"hpResume"
		},
		{
			"byte",
			"mpResume"
		},
		{
			"byte",
			"poisAC"
		},
		{
			"byte",
			"poisResume"
		},
		{
			"byte",
			"antiMagic"
		},
		{
			"short",
			"attSpeed"
		},
		{
			"byte",
			"age"
		},
		{
			"short",
			"AC"
		},
		{
			"short",
			"maxAC"
		},
		{
			"short",
			"MAC"
		},
		{
			"short",
			"maxMAC"
		},
		{
			"short",
			"DC"
		},
		{
			"short",
			"maxDC"
		},
		{
			"short",
			"MC"
		},
		{
			"short",
			"maxMC"
		},
		{
			"short",
			"SC"
		},
		{
			"short",
			"maxSC"
		},
		{
			"int",
			"HP"
		},
		{
			"int",
			"maxHP"
		},
		{
			"int",
			"MP"
		},
		{
			"int",
			"maxMP"
		},
		{
			"uint",
			"Exp"
		},
		{
			"uint",
			"maxExp"
		},
		{
			"short",
			"weight"
		},
		{
			"short",
			"maxWeight"
		},
		{
			"short",
			"wearWeight"
		},
		{
			"short",
			"maxWearWeight"
		},
		{
			"short",
			"handWeight"
		},
		{
			"short",
			"maxHandWeight"
		},
		{
			"short",
			"eqShareRate"
		},
		{
			"short",
			"eqiupForceResume"
		},
		{
			"short",
			"eqiupForceDC"
		},
		{
			"short",
			"eqiupForceAC"
		},
		{
			"short",
			"attackLuck"
		},
		{
			"short",
			"equipHolyVal"
		},
		{
			"short",
			"suckBloodVal"
		},
		{
			"short",
			"hpLevel"
		},
		{
			"short",
			"mpLevel"
		},
		{
			"short",
			"unBreakVal"
		},
		{
			"short",
			"breakHitVal"
		},
		{
			"short",
			"prestige"
		},
		{
			"short",
			"pkValue"
		},
		{
			"short",
			"forceDmgVal"
		},
		{
			"short",
			"unionAttPower"
		},
		{
			"short",
			"freezeAntiAbil"
		}
	},
	TClientAbility = {
		{
			"short",
			"level"
		},
		{
			"short",
			"hitRate"
		},
		{
			"short",
			"quickRate"
		},
		{
			"short",
			"hpResume"
		},
		{
			"short",
			"mpResume"
		},
		{
			"short",
			"poisAC"
		},
		{
			"short",
			"poisResume"
		},
		{
			"short",
			"antiMagic"
		},
		{
			"short",
			"attSpeed"
		},
		{
			"byte",
			"age"
		},
		{
			"int",
			"AC"
		},
		{
			"int",
			"maxAC"
		},
		{
			"int",
			"MAC"
		},
		{
			"int",
			"maxMAC"
		},
		{
			"int",
			"DC"
		},
		{
			"int",
			"maxDC"
		},
		{
			"int",
			"MC"
		},
		{
			"int",
			"maxMC"
		},
		{
			"int",
			"SC"
		},
		{
			"int",
			"maxSC"
		},
		{
			"int",
			"HP"
		},
		{
			"int",
			"maxHP"
		},
		{
			"int",
			"MP"
		},
		{
			"int",
			"maxMP"
		},
		{
			"uint",
			"Exp"
		},
		{
			"uint",
			"maxExp"
		},
		{
			"int",
			"weight"
		},
		{
			"int",
			"maxWeight"
		},
		{
			"int",
			"wearWeight"
		},
		{
			"int",
			"maxWearWeight"
		},
		{
			"int",
			"handWeight"
		},
		{
			"int",
			"maxHandWeight"
		},
		{
			"short",
			"eqShareRate"
		},
		{
			"short",
			"eqiupForceResume"
		},
		{
			"short",
			"eqiupForceDC"
		},
		{
			"short",
			"eqiupForceAC"
		},
		{
			"short",
			"attackLuck"
		},
		{
			"short",
			"equipHolyVal"
		},
		{
			"int",
			"suckBloodVal"
		},
		{
			"int",
			"hpLevel"
		},
		{
			"int",
			"mpLevel"
		},
		{
			"short",
			"unBreakVal"
		},
		{
			"short",
			"breakHitVal"
		},
		{
			"int",
			"prestige"
		},
		{
			"short",
			"pkValue"
		},
		{
			"short",
			"forceDmgVal"
		},
		{
			"int",
			"unionAttPower"
		},
		{
			"short",
			"freezeAntiAbil"
		}
	},
	TStdItem = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"stdMode"
		},
		{
			"byte",
			"shape"
		},
		{
			"byte",
			"need"
		},
		{
			"byte",
			"source"
		},
		{
			"short",
			"looks"
		},
		{
			"short",
			"weight"
		},
		{
			"short",
			"duraMax"
		},
		{
			"short",
			"aniCount"
		},
		{
			"short",
			"needIdentify"
		},
		{
			"short",
			"needLevel"
		},
		{
			"uint",
			"AC"
		},
		{
			"uint",
			"MAC"
		},
		{
			"uint",
			"DC"
		},
		{
			"uint",
			"MC"
		},
		{
			"uint",
			"SC"
		},
		{
			"byte",
			"tPrice1"
		},
		{
			"byte",
			"tPrice2"
		},
		{
			"byte",
			"tPrice3"
		},
		{
			"byte",
			"tPrice4"
		}
	},
	TAbilKeyValue = {
		{
			"byte",
			"abilType"
		},
		{
			"byte",
			"abilVal"
		},
		packed = true
	},
	TAbilKeyValue_Word = {
		{
			"short",
			"abilType"
		},
		{
			"short",
			"abilVal"
		}
	},
	TAssCC = {
		{
			"short",
			"xCC"
		},
		{
			"short",
			"xMaxCC"
		}
	},
	TDateTime = {
		{
			"int",
			"param1"
		},
		{
			"int",
			"param2"
		},
		double = function(self)
			local byteArray = require("framework.cc.utils.ByteArray").new():writeInt(self.param1):writeInt(self.param2):setPos(1)

			return byteArray.readDouble(byteArray)
		end
	},
	TSteelNewName = {
		{
			"string",
			"newName",
			15
		},
		{
			"record",
			"nameChgAbil",
			"TAbilKeyValue_Word"
		},
		packed = true
	},
	THunLianRec = {
		{
			"byte",
			"runeId"
		},
		{
			"array",
			"hunLianAbil",
			3,
			"record",
			"TAbilKeyValue_Word"
		},
		packed = true
	},
	TELementInfo = {
		{
			"byte",
			"EquipType"
		},
		{
			"byte",
			"ElementMaxLv"
		},
		{
			"byte",
			"ElementCurrLv"
		},
		{
			"array",
			"elementABil",
			5,
			"record",
			"TAbilKeyValue_Word"
		},
		packed = true
	},
	TClientElementInfo = {
		{
			"short",
			"activeAttElement"
		},
		{
			"short",
			"activeDefElement"
		},
		{
			"array",
			"elementAttAbilArr",
			5,
			"short"
		},
		{
			"array",
			"elementAttAbilArr",
			5,
			"short"
		}
	},
	TCleverSteel = {
		{
			"short",
			"steelID"
		},
		{
			"array",
			"stealUpAbils",
			5,
			"record",
			"TAbilKeyValue_Word"
		},
		packed = true
	},
	TSteelNewShape = {
		{
			"short",
			"newShape"
		},
		{
			"short",
			"newLooks"
		},
		{
			"array",
			"addAbils",
			2,
			"record",
			"TAbilKeyValue_Word"
		},
		packed = true
	},
	TClientSteelInfo = {
		{
			"byte",
			"lv"
		},
		{
			"byte",
			"maxLv"
		},
		{
			"byte",
			"veinsLv"
		},
		{
			"byte",
			"maxVeinsLv"
		},
		{
			"int",
			"veinsLv"
		},
		{
			"int",
			"stealVeinsMaxExp"
		},
		{
			"int",
			"stealDura"
		},
		{
			"record",
			"newNameInfo",
			"TSteelNewName"
		},
		{
			"record",
			"newShapeInfo",
			"TSteelNewShape"
		},
		{
			"array",
			"stealUpAbils",
			14,
			"record",
			"TAbilKeyValue_Word"
		}
	},
	TAntiqueAbil = {
		{
			"byte",
			"checkCnt"
		},
		{
			"byte",
			"checkMaxCnt"
		},
		{
			"byte",
			"mysteryNum"
		},
		{
			"byte",
			"maxMysteryNum"
		},
		{
			"byte",
			"spiritVal"
		},
		{
			"byte",
			"maxSpiritVal"
		},
		{
			"byte",
			"normalAbilCnt"
		},
		{
			"byte",
			"_reserv1"
		},
		{
			"array",
			"abilValues",
			8,
			"record",
			"TAbilKeyValue"
		},
		{
			"int",
			"specAbils"
		}
	},
	TClientItem = {
		{
			"uint",
			"makeIndex"
		},
		{
			"short",
			"Index"
		},
		{
			"short",
			"dura"
		},
		{
			"short",
			"duraMax"
		},
		{
			"short",
			"KeyValueSize"
		},
		{
			"uint",
			"_Reserved"
		},
		{
			"dynamicArray",
			"extendFields",
			0,
			"record",
			"TClientKeyValue",
			function(self)
				return self.get(self, "KeyValueSize")
			end
		},
		packed = true,
		isPileUp = function(self)
			if self.getVar("name") ~= "" and self.get(self, "makeIndex") ~= 0 then
				return self.getVar("stdMode") > 150
			end
		end,
		isBinded = function(self)
			if self.getVar("normalStateSet") then
				return ycFunction:band(self.getVar("normalStateSet"), 2) ~= 0
			elseif self.getVar("stdMode") == 2 then
				return self.getVar("shape") == 10 or self.getVar("shape") == 23 or self.getVar("shape") == 31
			elseif self.getVar("stdMode") == 3 then
				return self.getVar("shape") == 30
			end
		end,
		isNeedResetPos = function(self, target)
			if self.get(self, "duraMax") < self.get(self, "dura") + target.get(target, "dura") then
				return true
			end
		end,
		isCanPileUp = function(self, target)
			if not target then
				return false
			end

			if not self.isPileUp(self) or not target.isPileUp(target) then
				return false
			end

			if self.isBinded(self) ~= target.isBinded(target) then
				return false
			end

			if self.getVar("stdMode") ~= target.getVar("stdMode") then
				return false
			end

			if self.getVar("shape") ~= target.getVar("shape") then
				return false
			end

			if self.getVar("name") ~= target.getVar("name") then
				return false
			end

			if self.get(self, "makeIndex") == target.get(target, "makeIndex") then
				return false
			end

			if self.get(self, "duraMax") <= self.get(self, "dura") or target.get(target, "duraMax") <= target.get(target, "dura") then
				return false
			end

			if self.get(self, "dura") <= 0 or target.get(target, "dura") <= 0 then
				return false
			end

			return true
		end,
		getStd = function(self)
			return _G.def.items[tonumber(self.get(self, "Index"))] or _G.def.items.defaultItem
		end,
		getVar = function(self, name)
			local value = self.extendField and self.extendField[name]

			if value == nil then
				if not self._item then
					self._item = self.getStd()
				end

				value = self._item and self._item[name]
			end

			return value
		end,
		setIndex = function(self, index)
			self.set(self, "index", index)

			self._item = self.getStd()

			assert(self._item, "item should be exist")
		end,
		decodedCallback = function(self)
			self._item = self.getStd()

			if not self._item then
				return
			end

			self.extendField = {}

			local keyValueRecords = self.get(self, "extendFields")

			for _, v in ipairs(keyValueRecords) do
				local valueType = v.get(v, "ValueType")
				local value = v.get(v, "ValueNumber")

				if _G.def.items.valueType2Key[valueType] then
					self.extendField[_G.def.items.valueType2Key[valueType]] = value
				end
			end
		end
	},
	TClientKeyValue = {
		{
			"short",
			"ValueType"
		},
		{
			"short",
			"ValueNumber"
		}
	},
	TClientEquip = {
		{
			"int",
			"nPos"
		},
		{
			"record",
			"cliEquip",
			"TClientItem"
		}
	},
	PNewMarketInfo = {
		{
			"string",
			"kindName",
			15
		},
		{
			"int",
			"nextFlag"
		},
		{
			"int",
			"mPrice"
		},
		{
			"int",
			"mCount"
		},
		{
			"int",
			"itemIndex"
		}
	},
	TNewClientGoods = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"subMenu"
		},
		{
			"int",
			"price"
		},
		{
			"int",
			"stock"
		},
		{
			"int",
			"grade"
		},
		{
			"record",
			"deatil",
			"TStdItem"
		}
	},
	TMessageBodyW = {
		{
			"short",
			"param1"
		},
		{
			"short",
			"param2"
		},
		{
			"short",
			"tag1"
		},
		{
			"short",
			"tag2"
		}
	},
	TMessageBodyWL = {
		{
			"int",
			"param1"
		},
		{
			"int",
			"param2"
		},
		{
			"int",
			"tag1"
		},
		{
			"int",
			"tag2"
		}
	},
	TStruckInfo = {
		{
			"short",
			"unUse1"
		},
		{
			"short",
			"unUse2"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"param"
		},
		{
			"int",
			"flag"
		},
		{
			"int",
			"hp"
		},
		{
			"int",
			"maxHp"
		},
		{
			"int",
			"mp"
		},
		{
			"int",
			"maxMp"
		}
	},
	TNewClientMagic = {
		{
			"string",
			"magicName",
			14
		},
		{
			"byte",
			"magicType"
		},
		{
			"byte",
			"effectType"
		},
		{
			"byte",
			"effect"
		},
		{
			"short",
			"magicId"
		},
		{
			"short",
			"level"
		},
		{
			"short",
			"key"
		},
		{
			"short",
			"needMp"
		},
		{
			"short",
			"spellTick"
		},
		{
			"short",
			"nextNeedLv"
		},
		{
			"int",
			"coldTick"
		},
		{
			"int",
			"curTrain"
		},
		{
			"int",
			"maxTrain"
		},
		{
			"int",
			"delayTime"
		},
		packed = true
	},
	TClientSkillExp = {
		{
			"short",
			"skillID"
		},
		{
			"byte",
			"isSuper"
		},
		{
			"byte",
			"_reserved"
		},
		{
			"uint",
			"curExp"
		},
		{
			"uint",
			"nextExp"
		},
		{
			"int",
			"skillLv"
		}
	},
	TShortMessage = {
		{
			"short",
			"ident"
		},
		{
			"short",
			"msg"
		}
	},
	TXinfaNormalOrderItem = {
		{
			"string",
			"charName",
			15
		},
		{
			"int",
			"value"
		},
		{
			"int",
			"xinfaLv"
		}
	},
	THeroOrderItem = {
		{
			"string",
			"masterName",
			15
		},
		{
			"string",
			"heroName",
			14
		},
		{
			"byte",
			"level"
		}
	},
	THeroOrderItem = {
		{
			"string",
			"masterName",
			15
		},
		{
			"string",
			"heroName",
			14
		},
		{
			"short",
			"level"
		}
	},
	TXFHeroOrderItem = {
		{
			"string",
			"masterName",
			15
		},
		{
			"string",
			"heroName",
			14
		},
		{
			"short",
			"level"
		},
		{
			"int",
			"xinfaLv"
		}
	},
	TsmGuildInfo = {
		{
			"string",
			"gName",
			31
		},
		{
			"short",
			"maxUser"
		},
		{
			"short",
			"realUser"
		},
		{
			"short",
			"onlineUser"
		},
		{
			"short",
			"gLevel"
		},
		{
			"uint",
			"currExp"
		},
		{
			"uint",
			"nextExp"
		},
		{
			"record",
			"gsTime",
			"TDateTime"
		},
		{
			"short",
			"rankID"
		},
		{
			"short",
			"conferRight"
		},
		{
			"uint",
			"contribution"
		},
		{
			"uint",
			"etChannelID"
		},
		{
			"byte",
			"guildFlag"
		},
		{
			"byte",
			"_bResv"
		},
		{
			"short",
			"_wResv"
		},
		{
			"uint",
			"guildScore"
		},
		{
			"uint",
			"_Resv"
		},
		packed = true
	},
	TsmGuildRecuritEntry = {
		{
			"string",
			"gName",
			31
		},
		{
			"short",
			"onlineCount"
		},
		{
			"short",
			"memberCount"
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"job"
		},
		{
			"short",
			"level"
		},
		{
			"short",
			"xfLevel"
		},
		packed = true
	},
	TGuildPrivilegeSet = {
		{
			"short",
			"rankID"
		},
		{
			"short",
			"maxUser"
		},
		{
			"string",
			"rankName",
			15
		},
		packed = true
	},
	TsmGuildMemberEntry = {
		{
			"string",
			"chrName",
			15
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"job"
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"isOnline"
		},
		{
			"byte",
			"resvb"
		},
		{
			"short",
			"rankID"
		},
		{
			"short",
			"conferRight"
		},
		{
			"short",
			"sfLevel"
		},
		{
			"uint",
			"contribution"
		},
		{
			"record",
			"LogoutTime",
			"TDateTime"
		},
		{
			"uint",
			"totalContribution"
		},
		{
			"uint",
			"castleScore"
		},
		packed = true
	},
	TOldsmGuildMemberEntry = {
		{
			"string",
			"chrName",
			15
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"job"
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"isOnline"
		},
		{
			"byte",
			"resvb"
		},
		{
			"short",
			"rankID"
		},
		{
			"short",
			"conferRight"
		},
		{
			"short",
			"sfLevel"
		},
		{
			"uint",
			"contribution"
		},
		{
			"record",
			"LogoutTime",
			"TDateTime"
		},
		packed = true
	},
	TsmGuildRankEntry = {
		{
			"short",
			"rankID"
		},
		{
			"short",
			"maxUser"
		},
		{
			"string",
			"rankName",
			15
		},
		packed = true
	},
	TRankInfo = {
		{
			"short",
			"memVer"
		},
		{
			"record",
			"rankEntry",
			"TsmGuildRankEntry"
		}
	},
	TsmJoinGuildEntry = {
		{
			"string",
			"chrName",
			15
		},
		{
			"byte",
			"sex"
		},
		{
			"byte",
			"job"
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"isOnline"
		},
		{
			"record",
			"logoutTime",
			"TDateTime"
		},
		{
			"short",
			"sfLevel"
		},
		packed = true
	},
	TClientFriendRelation = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"string",
			"guildName",
			15
		},
		{
			"byte",
			"isonline"
		}
	},
	TClientAttentionRelation = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"color"
		},
		{
			"byte",
			"isonline"
		}
	},
	TClientNormalBlackRelation = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"isonline"
		}
	},
	TClientNearbyPlayerInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"sex"
		},
		{
			"string",
			"guildName",
			15
		}
	},
	TBufRec = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"color"
		}
	},
	TGuildDesc = {
		{
			"ID",
			"guildID"
		},
		{
			"string",
			"gildName",
			15
		},
		{
			"string",
			"presidentName",
			15
		},
		{
			"byte",
			"corpsCount"
		},
		{
			"byte",
			"enableUnion"
		},
		{
			"int",
			"playerCount"
		},
		{
			"int",
			"onlineCount"
		}
	},
	TCorpsDesc = {
		{
			"ID",
			"corpsID"
		},
		{
			"string",
			"corpsName",
			15
		},
		{
			"string",
			"gildName",
			15
		},
		{
			"string",
			"captainName",
			15
		},
		{
			"byte",
			"memberCount"
		},
		{
			"byte",
			"onlineCount"
		}
	},
	TRefuseRequestType = {
		{
			"byte",
			"type"
		},
		{
			"string",
			"name",
			15
		}
	},
	TCorpsDescAccept = {
		{
			"ID",
			"corpsID"
		},
		{
			"string",
			"corpsName",
			15
		},
		{
			"string",
			"gildName",
			15
		},
		{
			"string",
			"captainName",
			15
		},
		{
			"ID",
			"captainID"
		},
		{
			"ID",
			"viceCaptainID1"
		},
		{
			"ID",
			"viceCaptainID2"
		},
		{
			"byte",
			"memberCount"
		},
		{
			"byte",
			"onlineCount"
		}
	},
	TCorpsMemDesc = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"short",
			"status"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"six"
		},
		{
			"byte",
			"position"
		},
		{
			"string",
			"title",
			15
		}
	},
	TCorpsRequests = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"six"
		}
	},
	TGuildMember = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"level"
		},
		{
			"byte",
			"job"
		},
		{
			"byte",
			"six"
		},
		{
			"byte",
			"position"
		},
		{
			"short",
			"status"
		},
		packed = true
	},
	TGuildID = {
		{
			"ID",
			"ID"
		}
	},
	TMemberTitle = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"title",
			15
		}
	},
	TRecruitCondition = {
		{
			"byte",
			"job"
		},
		{
			"short",
			"level"
		},
		{
			"string",
			"notice",
			55
		}
	},
	TLogDesc = {
		{
			"record",
			"time",
			"TDateTime"
		},
		{
			"string",
			"logInfo",
			55
		}
	},
	TPresidentDesc = {
		{
			"ID",
			"mainID"
		},
		{
			"ID",
			"viceID"
		}
	},
	TGuildRequestJoinDesc = {
		{
			"ID",
			"corpsID"
		},
		{
			"ID",
			"ID"
		},
		{
			"string",
			"corpsName",
			15
		},
		{
			"string",
			"captainName",
			15
		},
		{
			"byte",
			"memberCount"
		}
	},
	TGuildSimpleDesc = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"name",
			15
		}
	},
	TGildRelation = {
		{
			"ID",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"relation"
		}
	},
	TClientShop = {
		{
			"string",
			"name",
			15
		},
		{
			"string",
			"typeName",
			15
		},
		{
			"short",
			"looks"
		},
		{
			"short",
			"page"
		},
		{
			"short",
			"price"
		},
		{
			"short",
			"curPrice"
		},
		{
			"short",
			"type"
		},
		{
			"short",
			"count"
		},
		{
			"short",
			"effCount"
		},
		{
			"uint",
			"effOffSet"
		},
		{
			"string",
			"descStr",
			127
		}
	},
	TUserStateInfo = {
		{
			"int",
			"feature"
		},
		{
			"string",
			"userName",
			15
		},
		{
			"byte",
			"nameColorIndex"
		},
		{
			"byte",
			"milrankSW"
		},
		{
			"byte",
			"b2"
		},
		{
			"byte",
			"vipFlag"
		},
		{
			"string",
			"guildName",
			15
		},
		{
			"string",
			"clanName",
			15
		},
		{
			"array",
			"userItems",
			16,
			"record",
			"TClientItem"
		},
		packed = true
	},
	TStartPoint = {
		{
			"string",
			"startMap",
			14
		},
		{
			"short",
			"x"
		},
		{
			"short",
			"y"
		},
		{
			"short",
			"rang"
		}
	},
	TNewHeroLook = {
		{
			"int",
			"outlook"
		},
		{
			"record",
			"status",
			"TAllBodyState"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"resv"
		},
		{
			"record",
			"feature",
			"TFeature"
		}
	},
	THeroLook = {
		{
			"int",
			"outlook"
		},
		{
			"record",
			"status",
			"TAllBodyState"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"resv"
		}
	},
	TClientTitleInfo = {
		{
			"short",
			"ID"
		},
		{
			"byte",
			"TitleType"
		},
		{
			"string",
			"TitleName",
			16
		},
		{
			"uint",
			"LeftTime"
		},
		{
			"short",
			"Look"
		},
		{
			"byte",
			"Add_PerAddForceValue"
		},
		{
			"byte",
			"Add_MaxMP"
		},
		{
			"byte",
			"UseTimes"
		},
		{
			"byte",
			"DisPlayType"
		},
		{
			"short",
			"Reserve"
		},
		{
			"short",
			"Add_MaxHP"
		},
		{
			"byte",
			"Add_MAC"
		},
		{
			"byte",
			"Add_AC"
		},
		{
			"byte",
			"Add_DC"
		},
		{
			"byte",
			"Add_MC"
		},
		{
			"byte",
			"Add_SC"
		},
		{
			"byte",
			"Add_MaxMAC"
		},
		{
			"byte",
			"Add_MaxAC"
		},
		{
			"byte",
			"Add_MaxDC"
		},
		{
			"byte",
			"Add_MaxMC"
		},
		{
			"byte",
			"Add_MaxSC"
		},
		{
			"byte",
			"Add_QuickRate"
		},
		{
			"byte",
			"Add_Union_Damage"
		},
		{
			"byte",
			"Add_Union_Damage_Percent"
		},
		{
			"uint",
			"Add_Exp"
		},
		{
			"byte",
			"Add_Exp_Percent"
		},
		{
			"byte",
			"Add_UnBreakValue"
		},
		packed = true
	},
	TEventMessage = {
		{
			"short",
			"ident"
		},
		{
			"short",
			"msg"
		},
		{
			"uint",
			"tickLapse"
		},
		{
			"string",
			"desc",
			3
		}
	},
	TEventMessage2 = {
		{
			"short",
			"ident"
		},
		{
			"short",
			"msg"
		},
		{
			"uint",
			"tickLapse"
		},
		{
			"string",
			"desc",
			14
		},
		{
			"string",
			"name",
			30
		},
		{
			"ID",
			"id"
		}
	},
	TPlusFocusItemInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"makeIndex"
		},
		{
			"byte",
			"pos"
		},
		{
			"byte",
			"state"
		},
		packed = true
	},
	TStallHeadInfo = {
		{
			"ID",
			"id"
		},
		{
			"string",
			"player",
			14
		},
		{
			"string",
			"name",
			30
		},
		{
			"int",
			"level"
		},
		{
			"int",
			"state"
		},
		{
			"int",
			"allTm"
		},
		{
			"int",
			"time"
		},
		{
			"double",
			"startTm"
		},
		{
			"int",
			"msgCnt"
		},
		{
			"int",
			"cnt"
		}
	},
	TStallBodyInfo = {
		{
			"uint",
			"makeIndex"
		},
		{
			"int",
			"cnt"
		},
		{
			"int",
			"type"
		},
		{
			"int",
			"price"
		}
	},
	TStallMsg = {
		{
			"ID",
			"id"
		},
		{
			"string",
			"msg",
			50
		}
	},
	TMailListInfo = {
		{
			"int",
			"id"
		},
		{
			"string",
			"title",
			20
		},
		{
			"string",
			"sender",
			14
		},
		{
			"int",
			"mailState"
		},
		{
			"int",
			"attachState"
		},
		{
			"double",
			"time"
		}
	},
	TMailInfo = {
		{
			"int",
			"id"
		},
		{
			"string",
			"sender",
			14
		},
		{
			"string",
			"title",
			20
		},
		{
			"string",
			"context",
			200
		},
		{
			"int",
			"mailState"
		},
		{
			"int",
			"attachState"
		},
		{
			"int",
			"type"
		},
		{
			"double",
			"time"
		},
		{
			"int",
			"gold"
		},
		{
			"int",
			"yb"
		},
		{
			"int",
			"cnt"
		},
		{
			"int",
			"mark"
		}
	},
	TMailMsg = {
		{
			"string",
			"name",
			14
		},
		{
			"double",
			"time"
		},
		{
			"string",
			"msg",
			50
		}
	},
	TFloorItem = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"owner"
		},
		{
			"byte",
			"state"
		}
	},
	TYBDealClientItems = {
		{
			"string",
			"name",
			15
		},
		{
			"uint",
			"id"
		},
		{
			"int",
			"num"
		},
		{
			"byte",
			"cnt"
		},
		{
			"byte",
			"timeOut"
		},
		{
			"byte",
			"getLost"
		},
		{
			"byte",
			"cancel"
		},
		{
			"short",
			"level"
		},
		{
			"double",
			"time"
		}
	},
	TYBDealDataHead = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"price"
		}
	},
	TYBDealData = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"makeIndex"
		}
	},
	TClientChannelInfo = {
		{
			"int",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"memberCount"
		},
		{
			"string",
			"creatorName",
			15
		},
		{
			"byte",
			"channelType"
		},
		{
			"byte",
			"maxMem"
		},
		{
			"short",
			"publicID"
		}
	},
	TCnlCreateParam = {
		{
			"string",
			"channelName",
			15
		},
		{
			"byte",
			"needPw"
		},
		{
			"string",
			"pw",
			6
		},
		{
			"byte",
			"memberMax"
		}
	},
	TClientChannelHeadInfo = {
		{
			"int",
			"ID"
		},
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"mode"
		},
		{
			"short",
			"publicID"
		}
	},
	TClientMemberInfo = {
		{
			"string",
			"name",
			15
		},
		{
			"byte",
			"isAdmin"
		},
		{
			"byte",
			"isMute"
		}
	},
	TNpcDesc = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"x"
		},
		{
			"short",
			"y"
		}
	},
	TGroupMemPosition = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"x"
		},
		{
			"int",
			"y"
		}
	},
	TMapPathNode = {
		{
			"string",
			"name",
			15
		},
		{
			"short",
			"x"
		},
		{
			"short",
			"y"
		}
	},
	TRetTransferAreaInfo = {
		{
			"int",
			"param"
		},
		{
			"int",
			"param1"
		},
		{
			"int",
			"param2"
		},
		{
			"string",
			"areaName",
			15
		},
		{
			"string",
			"groupName",
			15
		},
		{
			"string",
			"charName",
			15
		},
		{
			"string",
			"ptid",
			20
		},
		packed = true
	},
	TMixingDrugConfig = {
		{
			"short",
			"id"
		},
		{
			"short",
			"consume"
		},
		{
			"short",
			"generate"
		},
		{
			"short",
			"input"
		},
		{
			"short",
			"output"
		},
		{
			"short",
			"resid"
		},
		{
			"string",
			"name",
			20
		},
		{
			"string",
			"desc",
			100
		}
	},
	TMixingDrugListInfo = {
		{
			"short",
			"id"
		},
		{
			"short",
			"state"
		}
	},
	TMixingDrugBegin = {
		{
			"int",
			"time"
		},
		{
			"int",
			"price"
		}
	},
	TMixingDrugDuring = {
		{
			"int",
			"time"
		},
		{
			"int",
			"cnt"
		}
	},
	TMixingDrugLevelInfo = {
		{
			"short",
			"lv"
		},
		{
			"int",
			"curExp"
		},
		{
			"int",
			"maxExp"
		}
	},
	TBox2PrizeItem = {
		{
			"string",
			"name",
			15
		},
		{
			"int",
			"looks"
		},
		{
			"int",
			"amount"
		}
	}
}
local tables = {}
local configs = {}
local replaceRecordSizes = {}
local ioMethodsDef = {
	byte = {
		"readByte",
		"writeByte"
	},
	short = {
		"readShort",
		"writeShort"
	},
	int = {
		"readInt",
		"writeInt"
	},
	uint = {
		"readUInt",
		"writeUInt"
	},
	double = {
		"readDouble",
		"writeDouble"
	},
	ID = {
		"readDouble",
		"writeDouble"
	},
	["char*"] = {
		"readChars",
		"writeChars"
	},
	string = {
		"readString",
		"writeString"
	}
}

function baseVarSize(varType, strLen)
	if varType == "byte" then
		return 1
	elseif varType == "short" then
		return 2
	elseif varType == "int" or varType == "uint" then
		return 4
	elseif varType == "double" or varType == "ID" then
		return 8
	elseif varType == "char*" or varType == "string" then
		if not strLen then
			print("baseVarSize faild string")

			return
		end

		return strLen + 1
	end

	print("baseVarSize faild type: ", varType)
end

local function generateTables(record, name)
	local hasMemberFuncs
	local ret = {}

	for i, v in ipairs(record) do
		if v[1] == "record" then
			ret[v[2]] = generateTables(def[v[3]], v[3])

			if ret[v[2]]._hasMemberFuncs then
				hasMemberFuncs = true
			end
		elseif v[1] == "array" then
			local arr = {}

			for i2 = 1, v[3] do
				if v[4] == "record" then
					arr[#arr + 1] = generateTables(def[v[5]], v[5])

					if arr[#arr]._hasMemberFuncs then
						hasMemberFuncs = true
					end
				elseif v[4] == "string" or v[4] == "char*" then
					arr[#arr + 1] = ""
				else
					arr[#arr + 1] = 0
				end
			end

			ret[v[2]] = arr
		elseif v[1] == "string" or v[1] == "char*" then
			ret[v[2]] = ""
		else
			ret[v[2]] = 0
		end
	end

	for k, v2 in pairs(record) do
		if type(v2) == "function" then
			if not ret._member_funcs then
				ret._member_funcs = {}
			end

			ret._member_funcs[k] = v2
			hasMemberFuncs = true
		end
	end

	function ret:get(key)
		return self[key]
	end

	function ret:set(key, value)
		self[key] = value
	end

	function ret:size()
		return getRecordSize(self._name)
	end

	function ret:encode(beginpos)
		local config = configs[self._name]
		local size = config._size

		if not beginpos then
			ycByteStream:startWrite(size)
		end

		local pos = beginpos or 0

		local function writeRecord(record, config)
			for _, v in ipairs(config) do
				local k = v._key

				if type(v) == "table" then
					if v._r then
						writeRecord(record[k], v)
					elseif v._a then
						local recordArr = record[k]

						for i, v2 in ipairs(v) do
							if v2._r then
								writeRecord(recordArr[i], v2)
							elseif v2.strlen then
								v2[2](ycByteStream, v2.pos + pos, recordArr[i], #recordArr[i])
							else
								v2[2](ycByteStream, v2.pos + pos, recordArr[i])
							end
						end
					elseif v._v then
						if v.strlen then
							v[2](ycByteStream, v.pos + pos, record[k], #record[k])
						else
							v[2](ycByteStream, v.pos + pos, record[k])
						end
					end
				end
			end
		end

		writeRecord(self, config)

		if not beginpos then
			return ycByteStream:endWrite(size), size
		end

		return beginpos + size
	end

	local function readRecord(record, config, offset, bufLen)
		for _, v in ipairs(config) do
			local k = v._key

			if type(v) == "table" then
				if v._r then
					offset = readRecord(record[k], v, offset, bufLen)
				elseif v._a then
					local recordArr = record[k]

					for i, v2 in ipairs(v) do
						if v2._r then
							offset = readRecord(recordArr[i], v2, offset, bufLen)
						elseif v2.strlen then
							recordArr[i] = v2[1](ycByteStream, v2.pos + offset, v2.strlen)
						else
							recordArr[i] = v2[1](ycByteStream, v2.pos + offset)
						end
					end
				elseif v._v then
					if v.strlen then
						record[k] = v[1](ycByteStream, v.pos + offset, v.strlen)
					else
						record[k] = v[1](ycByteStream, v.pos + offset)
					end
				elseif v._d then
					local len = v.getlen and v.getlen(record) or 9999999
					local arr = {}
					local vType = v.type

					v.cfg = v.cfg or configs[v.reType]

					local cfg = v.cfg

					if cfg then
						for i2 = 1, len do
							local re = getRecord(v.reType)
							local startOffset = v.offset + offset

							if bufLen <= startOffset then
								break
							end

							offset = offset + readRecord(re, cfg, startOffset, bufLen) - startOffset
							offset = offset + cfg._size
							arr[i2] = re
						end
					else
						local startOffset2 = v.offset + offset

						if v.checkAlign and not cfg then
							startOffset2 = startOffset2 + v.subSize - startOffset2 % v.subSize
						end

						for i3 = 1, len do
							arr[i3] = v[1](ycByteStream, (i3 - 1) * v.subSize + startOffset2)
						end

						offset = offset + len * v.subSize
					end

					record[k] = arr
				end
			end
		end

		if record.decodedCallback then
			record.decodedCallback(record)
		end

		return offset
	end

	function ret:decode(buf, bufLen, returnOther)
		local config = configs[self._name]
		local size = config._size

		if bufLen and bufLen < size then
			p2("error", "record decode faild!", self._name, bufLen, size)
			p2("error", debug.traceback())

			return
		end

		ycByteStream:startRead(buf, bufLen)

		local size2 = size + readRecord(self, config, 0, bufLen)

		ycByteStream:startRead("", 0)

		if returnOther then
			return self, string.sub(buf, size2 + 1, bufLen), bufLen - size2
		end

		return self
	end

	ret._hasMemberFuncs = hasMemberFuncs
	ret._class = "record"
	ret._name = name

	return ret
end

local function generateConfigs(record, beginpos, recordName)
	beginpos = beginpos or 0

	local ret = {
		_r = true
	}
	local cnt = 0

	local function fillCheck(num)
		if cnt % num ~= 0 then
			cnt = cnt + num - cnt % num
		end
	end

	local function findMaxVarSize(r)
		local size = 1

		for i, v in ipairs(r) do
			if v[1] == "ID" or v[1] == "double" then
				return 8
			elseif v[1] == "int" or v[1] == "uint" then
				return 4
			elseif v[1] == "short" then
				size = math.max(size, 2)
			elseif v[1] == "record" then
				size = math.max(size, findMaxVarSize(def[v[3]]))
			elseif v[1] == "array" then
				if v[4] == "ID" or v[4] == "double" then
					size = math.max(size, 8)
				elseif v[4] == "int" or v[4] == "uint" then
					return 4
				elseif v[4] == "short" then
					size = math.max(size, 2)
				elseif v[4] == "record" then
					size = math.max(size, findMaxVarSize(def[v[5]]))
				end
			end

			if size == 4 then
				return size
			end
		end

		return size
	end

	local function new(vType, strlen)
		local reader = ycByteStream[ioMethodsDef[vType][1]]
		local writter = ycByteStream[ioMethodsDef[vType][2]]

		return {
			reader,
			writter,
			_v = true,
			vType = vType,
			pos = cnt + beginpos,
			strlen = strlen
		}
	end

	if record.packed then
		for i, v in ipairs(record) do
			if v[1] == "record" then
				ret[i] = generateConfigs(def[v[3]], cnt + beginpos, v[3])
				cnt = cnt + ret[i]._size
			elseif v[1] == "array" then
				local arr = {
					_a = true
				}

				for i2 = 1, v[3] do
					if v[4] == "record" then
						arr[#arr + 1] = generateConfigs(def[v[5]], cnt + beginpos, v[5])
						cnt = cnt + arr[#arr]._size
					else
						arr[#arr + 1] = new(v[4])
						cnt = cnt + baseVarSize(v[4])
					end
				end

				ret[i] = arr
			elseif v[1] == "dynamicArray" then
				local darr = {
					_d = true,
					type = v[4],
					reType = v[5],
					getlen = v[6],
					offset = cnt + beginpos
				}

				if v[4] ~= "record" then
					darr[1] = ycByteStream[ioMethodsDef[v[4]][1]]
					darr[2] = ycByteStream[ioMethodsDef[v[4]][2]]
					darr.subSize = baseVarSize(v[4])
				end

				ret[i] = darr
			else
				ret[i] = new(v[1], v[3])
				cnt = cnt + baseVarSize(v[1], v[3])
			end

			ret[i]._key = v[2]
		end
	else
		for i3, v2 in ipairs(record) do
			if v2[1] == "record" then
				fillCheck(findMaxVarSize(def[v2[3]]))

				ret[i3] = generateConfigs(def[v2[3]], cnt + beginpos, v2[3])
				cnt = cnt + ret[i3]._size
			elseif v2[1] == "array" then
				if v2[1] == "ID" or v2[1] == "double" then
					fillCheck(8)
				elseif v2[4] == "int" or v2[4] == "uint" then
					fillCheck(4)
				elseif v2[4] == "short" then
					fillCheck(2)
				elseif v2[4] == "record" then
					fillCheck(findMaxVarSize(def[v2[5]]))
				end

				local arr2 = {
					_a = true
				}

				for i4 = 1, v2[3] do
					if v2[4] == "record" then
						arr2[#arr2 + 1] = generateConfigs(def[v2[5]], cnt + beginpos, v2[5])
						cnt = cnt + arr2[#arr2]._size
					else
						arr2[#arr2 + 1] = new(v2[4])
						cnt = cnt + baseVarSize(v2[4])
					end
				end

				ret[i3] = arr2
			elseif v2[1] == "dynamicArray" then
				local darr2 = {
					_d = true,
					checkAlign = true,
					type = v2[4],
					reType = v2[5],
					getlen = v2[6],
					offset = cnt + beginpos
				}

				if v2[4] ~= "record" then
					darr2[1] = ycByteStream[ioMethodsDef[v2[4]][1]]
					darr2[2] = ycByteStream[ioMethodsDef[v2[4]][2]]
					darr2.subSize = baseVarSize(v2[4])
				end

				ret[i3] = darr2
			else
				local size = baseVarSize(v2[1], v2[3])

				if v2[1] == "short" or v2[1] == "int" or v2[1] == "uint" or v2[1] == "ID" or v2[1] == "double" then
					fillCheck(size)
				end

				ret[i3] = new(v2[1], v2[3])
				cnt = cnt + size
			end

			ret[i3]._key = v2[2]
		end

		fillCheck(findMaxVarSize(record))
	end

	ret._size = replaceRecordSizes[recordName] or cnt

	return ret
end

function fillMemberFuncs(record)
	if not record._hasMemberFuncs then
		return
	end

	for k, v in pairs(record) do
		if type(v) == "table" then
			if v._class == "record" then
				fillMemberFuncs(v)
			elseif k == "_member_funcs" then
				for methodName, func in pairs(v) do
					record[methodName] = handler(record, func)
				end

				record[k] = nil
			elseif type(v[1]) == "table" and v[1]._class == "record" then
				for i, t in ipairs(v) do
					fillMemberFuncs(t)
				end
			end
		end
	end
end

function getRecord(name, params)
	local t = tables[name]

	if t then
		t = clone(t)

		fillMemberFuncs(t)

		if params then
			for k, v in pairs(params) do
				t[k] = v
			end
		end
	end

	return t
end

function getRecordSize(name)
	local c = configs[name]

	return c and c._size
end

function setRecordSize(name, size)
	replaceRecordSizes[name] = size
end

function initRecords()
	tables = {}

	for k, v in pairs(def) do
		tables[k] = generateTables(v, k)
	end
end

function initRecordConfigs()
	configs = {}

	for k, v in pairs(def) do
		configs[k] = generateConfigs(v, 0, k)
	end
end

initRecords()
initRecordConfigs()
