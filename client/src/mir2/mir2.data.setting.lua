local setting = {
	base = {
		touchRun = true,
		guild = false,
		firePeral = false,
		lockColor = true,
		showNameOnly = false,
		showExpValue = 20000,
		autoUnpack = true,
		showExpEnable = false,
		soundEnable = true,
		hiBlood = false,
		showOutHP = false,
		levelShow = true,
		heroShowName = true,
		hideCorpse = false,
		NPCShowName = true,
		petShowName = true,
		monShowName = true,
		quickexit = false,
		warningDura = true
	},
	protected = {
		role = {
			hp = {
				isPercent = false,
				space = 10000,
				value = 0,
				uses = "随机传送卷",
				lastTime = 0,
				enable = false
			},
			mp = {
				isPercent = false,
				space = 10000,
				value = 0,
				uses = "随机传送卷",
				lastTime = 0,
				enable = false
			},
			jiu = {
				value = 10,
				space = 500,
				isPercent = true,
				lastTime = 0,
				enable = false
			},
			yaojiu = {
				value = 10,
				space = 9000,
				isPercent = false,
				lastTime = 0,
				enable = false
			}
		},
		hero = {
			hp = {
				isPercent = false,
				space = 10000,
				value = 0,
				uses = "随机传送卷",
				lastTime = 0,
				enable = false
			},
			mp = {
				isPercent = false,
				space = 10000,
				value = 0,
				uses = "随机传送卷",
				lastTime = 0,
				enable = false
			},
			jiu = {
				value = 10,
				space = 500,
				isPercent = true,
				lastTime = 0,
				enable = false
			},
			yaojiu = {
				value = 10,
				space = 9000,
				isPercent = false,
				lastTime = 0,
				enable = false
			},
			miss = {
				value = 40,
				space = 9000,
				isPercent = false,
				lastTime = 0,
				enable = true
			}
		}
	},
	drugs = {
		roleSetting = {
			withNumber = false,
			withPercent = true
		},
		heroSetting = {
			withNumber = false,
			withPercent = true
		},
		role = {
			percentDrug = {
				normalHP = {
					lastTime = 0,
					space = 2000,
					isPercent = true,
					value = 0.75,
					enable = true
				},
				normalMP = {
					lastTime = 0,
					space = 2000,
					isPercent = true,
					value = 0.75,
					enable = true
				},
				quickHP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.5,
					enable = true
				},
				quickMP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.25,
					enable = true
				}
			},
			numberDrug = {
				normalHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				normalMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				}
			}
		},
		hero = {
			percentDrug = {
				normalHP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.75,
					enable = true
				},
				normalMP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.75,
					enable = true
				},
				quickHP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.5,
					enable = true
				},
				quickMP = {
					lastTime = 0,
					space = 500,
					isPercent = true,
					value = 0.25,
					enable = true
				}
			},
			numberDrug = {
				normalHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				normalMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				}
			}
		}
	},
	autoUnpack = {
		newbee = {
			pack = "新手金创药包",
			name = "新手金创药",
			min = 0,
			enable = true
		},
		hpMid = {
			pack = "金创药（中）包",
			name = "金创药(中量)",
			min = 0,
			enable = true
		},
		hpSmall = {
			pack = "金创药(小)包",
			name = "金创药(小量)",
			min = 0,
			enable = true
		},
		hpMid = {
			pack = "金创药(中)包",
			name = "金创药(中量)",
			min = 0,
			enable = true
		},
		hpBig = {
			pack = "超级金创药",
			name = "强效金创药",
			min = 0,
			enable = true
		},
		hpMidz = {
			pack = "金创药中包(赠)",
			name = "金创药中量(赠)",
			min = 0,
			enable = true
		},
		hpBigz = {
			pack = "超级金创药(赠)",
			name = "强效金创药(赠)",
			min = 0,
			enable = true
		},
		mpSmall = {
			pack = "魔法药(小)包",
			name = "魔法药(小量)",
			min = 0,
			enable = true
		},
		mpMid = {
			pack = "魔法药(中)包",
			name = "魔法药(中量)",
			min = 0,
			enable = true
		},
		mpBig = {
			pack = "超级魔法药",
			name = "强效魔法药",
			min = 0,
			enable = true
		},
		mpMidz = {
			pack = "魔法药中包(赠)",
			name = "魔法药中量(赠)",
			min = 0,
			enable = true
		},
		mpBigz = {
			pack = "超级魔法药(赠)",
			name = "强效魔法药(赠)",
			min = 0,
			enable = true
		},
		quick1 = {
			pack = "强效太阳包",
			name = "强效太阳水",
			min = 0,
			enable = true
		},
		quick2 = {
			pack = "雪霜包",
			name = "万年雪霜",
			min = 0,
			enable = true
		},
		quick3 = {
			pack = "疗伤药包",
			name = "疗伤药",
			min = 0,
			enable = true
		},
		quick4 = {
			pack = "疗伤药包(任务)",
			name = "疗伤药(任务)",
			min = 0,
			enable = true
		},
		reel1 = {
			pack = "随机传送卷包",
			name = "随机传送卷",
			min = 0,
			enable = true
		},
		reel2 = {
			pack = "地牢逃脱卷包",
			name = "地牢逃脱卷",
			min = 0,
			enable = true
		},
		reel3 = {
			pack = "回城卷包",
			name = "回城卷",
			min = 0,
			enable = true
		},
		reel4 = {
			pack = "行会回城卷包",
			name = "行会回城卷",
			min = 0,
			enable = true
		}
	},
	job = {
		autoDun = false,
		autoFire = false,
		autoZhanjiashu = false,
		autoAllSpace = false,
		autoSword = false,
		autoWide = true,
		autoInvisible = false,
		autoSpace = false,
		autoDunHero = false,
		autoYoulingDun = false,
		autoSkill = {
			enable = false,
			space = 10
		}
	},
	autoRat = {
		noPickUpItem = false,
		autoPoison = false,
		pickUpRatting = true,
		ignoreCripple = true,
		autoSpaceMove = {
			space = 10,
			use = "随机传送卷",
			enable = false
		},
		autoRoar = {
			space = 10,
			cnt = 5,
			enable = false
		},
		atkMagic = {},
		areaMagic = {
			cnt = 5,
			enable = false
		},
		autoPet = {
			enable = false
		},
		autoCure = {
			percent = 70,
			enable = false
		},
		autoCurePet = {
			percent = 60,
			enable = false
		}
	},
	display = {
		showHeroOutHP = false,
		showMonOutHP = true,
		mapScale = 1.5
	},
	cpu = {
		speedMode = false,
		loadMons = false,
		normalFont = false
	},
	help = {
		count = 7,
		looked = 0
	},
	chat = {
		alwaysTranslate = false,
		whisperLimit = 1,
		opens = {
			["组队"] = true,
			["战队"] = true
		},
		autoLoadVoice = {
			enable = false
		},
		autoPlayVoice = {
			["私聊"] = false,
			["组队"] = false,
			["喊话"] = false,
			["战队"] = false,
			["行会"] = false,
			["附近"] = false
		}
	},
	item = {
		pickUp = false,
		hindGood = false,
		showName = true,
		pickOnRatting = false,
		filt = {}
	},
	other = {
		buyNotTip = false
	}
}

function setting.initEnd()
	sound.setEnable(setting.base.soundEnable)

	an.label.normal = setting.cpu.normalFont
	local filt = setting.item.filt

	if not filt["极品属性道具"] then
		filt["极品属性道具"] = {
			hintName = true,
			pickUp = true,
			isGood = true,
			pickOnRatting = true
		}
	end

	setmetatable(filt, {
		__index = _G.def.items.filt
	})
end

function setting.getGoodAttItemSetting()
	return setting.item.filt["极品属性道具"]
end

function setting.resetItemFilt()
	setting.item.filt = {}

	setmetatable(setting.item.filt, {
		__index = _G.def.items.filt
	})
end

local default = clone(setting)

function setting.reset()
	for k, v in pairs(default) do
		setting[k] = clone(v)
	end

	setting.initEnd()
end

function setting.init(playerName)
	setting.reset()

	for k, v in pairs(setting) do
		local saved = cache.getSetting(playerName, k)

		if saved then
			for k2, v2 in pairs(saved) do
				v[k2] = v2
			end
		end
	end

	setting.initEnd()
end

return setting
