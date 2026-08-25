local path = "pic/panels/voice/"
local common = import("..common.common")
local yaya = require("mir2.single.yaya")
local voice = class("voice", function()
	return display.newNode()
end)

table.merge(voice, {})

function voice:ctor()
	self._supportMove = true

	local bg = res.get2("pic/panels/voice/bg.png"):anchor(0, 0):add2(self)

	self:size(bg:getw(), bg:geth()):anchor(0.5, 0.5):center()
	res.get2(path .. "title.png"):add2(bg):pos(bg:getw() / 2, bg:geth() - 24)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 6, self:geth() - 5):addto(self)

	local scroll = an.newScroll(14, 75, 118, 320):add2(self)
	local tabs = {
		{
			"public",
			"公 共"
		},
		{
			"group",
			"组 队"
		},
		{
			"battleTeam",
			"战 队"
		},
		{
			"guild",
			"行 会"
		}
	}
	local btns = {}

	local function clickBtn(key)
		if self.channel == key then
			return
		end

		self.channel = key

		for k, v in pairs(btns) do
			v:setIsSelect(k == self.channel)
		end

		self:load()
	end

	for i, v in ipairs(tabs) do
		local btn = an.newBtn(res.gettex2("pic/common/btn60.png"), function()
			sound.playSound("103")
			clickBtn(v[1])
		end, {
			support = "scroll",
			sprite = res.gettex2("pic/panels/voice/" .. v[1] .. ".png"),
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(scroll):pos(scroll:getw() / 2, scroll:geth() - 23 - (i - 1) * 52)

		btn.icon = res.get2(path .. "icon.png"):add2(btn):pos(btn:getw() - 15, 15):hide()
		btns[v[1]] = btn
	end

	function self.refershEnterIcon()
		local enterTab

		if g_data.voice.roomData then
			enterTab = self:channelType2TabKey(voice.getChannelType(g_data.voice.channelType))
		end

		for k, v in pairs(btns) do
			v.icon:setVisible(k == enterTab)
		end
	end

	self.refershEnterIcon()

	local enterTab

	if g_data.voice.roomData then
		enterTab = self:channelType2TabKey(voice.getChannelType(g_data.voice.channelType))
	end

	self.channel = nil

	clickBtn(enterTab or "public")
end

function voice:channelType2TabKey(channelType)
	if channelType == "ctGuild" then
		return "guild"
	elseif channelType == "ctCorps" then
		return "battleTeam"
	elseif channelType == "ctGroup" then
		return "group"
	end

	return "public"
end

function voice:load()
	if g_data.voice.roomData then
		local channelType = voice.getChannelType(g_data.voice.channelType)

		if (channelType == "ctPublic" or channelType == "ctPersonal") and self.channel == "public" or channelType == "ctGuild" and self.channel == "guild" or channelType == "ctCorps" and self.channel == "battleTeam" or channelType == "ctGroup" and self.channel == "group" then
			self:loadMemberList()

			return
		end
	end

	if self.content then
		self.content:removeSelf()

		self.content = nil
	end

	if self.channel == "public" then
		net.send({
			CM_QUERY_CHANNEL_LIST
		})
	else
		local param

		if self.channel == "group" then
			param = 4
		elseif self.channel == "guild" then
			param = 2
		elseif self.channel == "battleTeam" then
			param = 3
		else
			assert(false, "invalid self.channel.")

			return
		end

		net.send({
			CM_QUERY_CHANNEL_MEMBERS,
			param = param
		})
	end
end

function voice:exitChannel(exitType)
	if self.content then
		self.content:removeSelf()

		self.content = nil
	end

	if exitType ~= 4 then
		self:load()
	end

	self:refershEnterIcon()
end

function voice:recvChannelList(msg, buf, bufLen)
	self.channelList = {}

	for i = 1, msg.param do
		self.channelList[#self.channelList + 1], buf, bufLen = getRecord("TClientChannelInfo"):decode(buf, bufLen, true)
	end

	if self.channel == "public" then
		self:loadChannelList()
	end
end

function voice:recvMemberList(msg, buf, bufLen, channelType, isEnter)
	local channelTypeStr = voice.getChannelType(channelType)
	local recvIsCurTab = (channelTypeStr == "ctPublic" or channelTypeStr == "ctPersonal") and self.channel == "public" or channelTypeStr == "ctGuild" and self.channel == "guild" or channelTypeStr == "ctCorps" and self.channel == "battleTeam" or channelTypeStr == "ctGroup" and self.channel == "group"

	if isEnter then
		self:refershEnterIcon()

		if recvIsCurTab then
			self:loadMemberList()
		end
	else
		if not recvIsCurTab then
			return
		end

		if channelType == g_data.voice.channelType then
			return
		end

		if msg.recog ~= 0 then
			self:loadMemberErr(msg.recog, channelType, channelTypeStr)
		else
			local value
			local members = {}
			local roomData

			roomData, buf, bufLen = getRecord("TClientChannelHeadInfo"):decode(buf, bufLen, true)

			for i = 1, msg.param do
				members[#members + 1], buf, bufLen = getRecord("TClientMemberInfo"):decode(buf, bufLen, true)
			end

			self:loadMemberList(true, channelType, roomData, members)
		end
	end
end

function voice:requestEnter(id, channelType, password)
	net.send({
		CM_CHANNEL_ENTER,
		recog = id,
		param = channelType
	}, password and {
		password
	})
end

function voice:loadChannelList()
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():add2(self)

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(85, 42):anchor(0, 0):pos(142, 361):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(148, 42):anchor(0, 0):pos(226, 361):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(80, 42):anchor(0, 0):pos(373, 361):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(174, 42):anchor(0, 0):pos(452, 361):add2(self.content)
	an.newLabel("频道ID", 20, 1, {
		color = def.colors.labelTitle
	}):pos(154, 370):add2(self.content)
	an.newLabel("频道名", 20, 1, {
		color = def.colors.labelTitle
	}):pos(268, 370):add2(self.content)
	an.newLabel("人数", 20, 1, {
		color = def.colors.labelTitle
	}):pos(390, 370):add2(self.content)
	an.newLabel("频道创建者", 20, 1, {
		color = def.colors.labelTitle
	}):pos(490, 370):add2(self.content)

	local filterStr = ""
	local contentNode

	local function load()
		if contentNode then
			contentNode:removeSelf()
		end

		contentNode = display.newNode():add2(self.content)

		local curSelect
		local selectSpr
		local cnt = 0
		local lineh = 38
		local scroll = an.newScroll(142, 68, 484, 292):add2(contentNode)

		local function add(idx, v, isPrivate)
			local line

			local function clickFunc()
				if not selectSpr then
					local tmpSize = cc.size(line:getContentSize().width + 6, line:getContentSize().height + 6)

					selectSpr = res.get2("pic/panels/voice/shine.png"):pos(-5, 0):size(tmpSize):anchor(0, 1):add2(scroll)
				end

				if not curSelect or curSelect.idx ~= idx then
					selectSpr:pos(line:getPositionX() - 5, line:getPositionY())

					curSelect = {
						idx = idx,
						data = v,
						isPrivate = isPrivate
					}
				end
			end

			line = display.newNode():size(scroll:getw(), lineh):anchor(0, 1):pos(0, scroll:geth() - idx * lineh):add2(scroll):enableClick(clickFunc, {
				support = "scroll"
			})

			display.newScale9Sprite(res.getframe2("pic/scale/scale" .. (idx % 2 == 0 and 19 or 18) .. ".png")):anchor(0, 0):size(line:getContentSize()):add2(line)

			if isPrivate then
				res.get2("pic/common/lock.png"):pos(20, line:geth() / 2):add2(line)
				an.newLabel(v:get("publicID"), 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):pos(40, line:geth() / 2):add2(line)
			else
				an.newLabel(v:get("publicID"), 20, 1, {
					color = def.colors.labelGray
				}):anchor(0.5, 0.5):pos(47, line:geth() / 2):add2(line)
			end

			an.newLabel(v:get("name"), 20, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(157, line:geth() / 2):add2(line)
			an.newLabel(v:get("memberCount") .. "/" .. v:get("maxMem"), 20, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(270, line:geth() / 2):add2(line)
			an.newLabel(v:get("creatorName"), 20, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(400, line:geth() / 2):add2(line)

			if idx == 0 then
				clickFunc()
			end
		end

		for k, v in pairs(self.channelList) do
			local channelType = voice.getChannelType(v:get("channelType"))

			if (channelType == "ctPublic" or channelType == "ctPersonal") and (filterStr == "" or string.find(string.lower(v:get("name")), string.lower(filterStr)) or string.find(string.lower(v:get("publicID")) .. "", string.lower(filterStr))) then
				add(cnt, v, channelType == "ctPersonal")

				cnt = cnt + 1
			end
		end

		if cnt > 0 then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				if curSelect then
					local function go()
						if curSelect.isPrivate then
							local msgbox

							msgbox = an.newMsgbox("", function(idx)
								if idx <= 0 then
									return
								end

								if not tonumber(msgbox.pwInput:getString()) then
									an.newMsgbox("密码只能是6位以内数字", nil, {
										center = true
									})

									return
								end

								self:requestEnter(curSelect.data:get("ID"), curSelect.data:get("channelType"), msgbox.pwInput:getString())
							end, {
								hasCancel = true,
								title = res.gettex2(path .. "title_enter.png")
							})
							msgbox.pwInput = an.newInput(0, 0, 236, 40, 6, {
								label = {
									"",
									20,
									1
								},
								bg = {
									tex = res.gettex2("pic/scale/scale16.png"),
									offset = {
										-10,
										2
									}
								},
								tip = {
									"输入六位以内数字密码",
									20,
									1,
									{
										color = cc.c3b(128, 128, 128)
									}
								}
							}):add2(msgbox.bg):pos(msgbox.bg:getw() / 2, msgbox.bg:geth() / 2)

							return
						end

						self:requestEnter(curSelect.data:get("ID"), curSelect.data:get("channelType"))
					end

					if g_data.voice.roomData then
						an.newMsgbox(string.format("你确定离开当前频道并进入(%s)吗?", curSelect.data:get("name")), function(idx)
							if idx == 1 then
								go()
							end
						end, {
							center = true,
							hasCancel = true
						})
					else
						go()
					end
				end
			end, {
				sprite = res.gettex2("pic/panels/voice/enter.png"),
				pressImage = res.gettex2("pic/common/btn21.png")
			}):add2(contentNode):anchor(1, 0):pos(self:getw() - 126, 16)
		elseif filterStr == "" then
			an.newLabel("当前服务器暂无创建频道", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(383, 230):add2(contentNode)
		else
			an.newLabel(string.format("未找到符合(%s)的频道", filterStr), 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(383, 230):add2(contentNode)
		end
	end

	load()

	local filterInput

	filterInput = an.newInput(0, 0, 236, 40, 7, {
		label = {
			"",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入ID或频道名",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function()
			filterStr = filterInput:getString()

			load()
		end
	}):add2(self.content):anchor(0, 0):pos(25, 16):add(res.get2(path .. "search.png"):pos(210, 20))

	local value

	local function createVoice()
		local msgbox

		msgbox = an.newMsgbox("", function(idx)
			if idx <= 0 then
				return
			end

			g_data.voice.isCreate = true

			if msgbox.nameInput:getString() == "" then
				an.newMsgbox("频道名字不能为空", function()
					createVoice()
				end, {
					center = true
				})

				return
			end

			if not def.wordfilter.check(msgbox.nameInput:getString()) then
				an.newMsgbox("频道名字包含敏感字符", function()
					createVoice()
				end, {
					center = true
				})

				return
			end

			if msgbox.pwInput:getString() ~= "" and not tonumber(msgbox.pwInput:getString()) then
				an.newMsgbox("密码只能是6位以内数字", function()
					createVoice()
				end, {
					center = true
				})

				return
			end

			local mem = tonumber(msgbox.memInput:getString())

			if not mem or mem < 2 or mem > 200 then
				an.newMsgbox("成员人数只能是 2 ~ 200数字", function()
					createVoice()
				end, {
					center = true
				})

				return
			end

			net.send({
				CM_CHANNEL_CREATE
			}, nil, getRecord("TCnlCreateParam", {
				channelName = msgbox.nameInput:getString(),
				needPw = msgbox.pwInput:getString() == "" and 0 or 1,
				pw = msgbox.pwInput:getString(),
				memberMax = mem
			}))
		end, {
			hasCancel = true,
			title = res.gettex2(path .. "title_create.png")
		})

		an.newLabel("频道名", 20, 1, {
			color = def.colors.colorGrayYellow
		}):add2(msgbox.bg):anchor(0, 0.5):pos(40, 200)
		an.newLabel("密码(可选)", 20, 1, {
			color = def.colors.colorGrayYellow
		}):add2(msgbox.bg):anchor(0, 0.5):pos(40, 150)
		an.newLabel("最大人数", 20, 1, {
			color = def.colors.colorGrayYellow
		}):add2(msgbox.bg):anchor(0, 0.5):pos(40, 100)

		msgbox.nameInput = an.newInput(0, 0, 236, 40, 7, {
			label = {
				common.getPlayerName() .. "的频道",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"最多七个字",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(280, 200)
		msgbox.pwInput = an.newInput(0, 0, 236, 40, 6, {
			label = {
				"",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"6位数字",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(280, 150)
		msgbox.memInput = an.newInput(0, 0, 236, 40, 3, {
			label = {
				"20",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"2 ~ 200(默认20)",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(280, 100)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		createVoice()
	end, {
		sprite = res.gettex2("pic/panels/voice/create.png"),
		pressImage = res.gettex2("pic/common/btn21.png")
	}):add2(self.content):anchor(1, 0):pos(self:getw() - 18, 16)
end

function voice:loadMemberErr(code, channelType, channelTypeStr)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():add2(self)

	local tipstr

	if code == -28 then
		if channelTypeStr == "ctCorps" then
			tipstr = "你当前还未加入任何战队."
		elseif channelTypeStr == "ctGuild" then
			tipstr = "你当前还未加入任何行会."
		elseif channelTypeStr == "ctGroup" then
			tipstr = "你当前还没有编组."
		else
			return
		end

		an.newLabel(tipstr, 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(383, 230):add2(self.content)
	elseif code == -29 then
		an.newLabel("频道未创建", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(383, 230):add2(self.content)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local function go()
				self:requestEnter(nil, channelType)
			end

			if g_data.voice.roomData then
				an.newMsgbox("你确定离开当前频道并创建频道吗?", function(idx)
					if idx == 1 then
						go()
					end
				end, {
					hasCancel = true
				})
			else
				go()
			end
		end, {
			clickSpace = 2,
			sprite = res.gettex2("pic/panels/voice/create.png"),
			pressImage = res.gettex2("pic/common/btn21.png")
		}):add2(self.content):anchor(1, 0):pos(self:getw() - 18, 16)
	end
end

function voice:loadMemberList(isPreview, channelType, roomData, members)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():add2(self)
	self.content.type = isPreview and "members_preview" or "members"

	if not isPreview then
		members = g_data.voice.members
		roomData = g_data.voice.roomData
		channelType = g_data.voice.channelType
	end

	local onMicNames = {}
	local title
	local channelTypeStr = voice.getChannelType(channelType)

	if channelTypeStr == "ctPublic" or channelTypeStr == "ctPersonal" then
		title = string.format("%s (ID: %d)", roomData:get("name"), roomData:get("publicID"))
	elseif channelTypeStr == "ctGuild" then
		title = g_data.guild:getGuildName() or ""
	elseif channelTypeStr == "ctCorps" then
		title = g_data.guild:getClanName() or ""
	elseif channelTypeStr == "ctGroup" then
		title = g_data.player:getLeaderName() .. "的队伍"
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(485, 42):anchor(0, 0):pos(141, 361):add2(self.content)
	an.newLabel(title, 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(383, 383):add2(self.content)

	local adminNode = display.newNode():size(223, 172):add2(self.content):pos(141, 191)

	display.newScale9Sprite(res.getframe2("pic/scale/scale21.png")):size(adminNode:getContentSize()):anchor(0, 0):add2(adminNode)
	res.get2(path .. "tab_bg.png"):add2(adminNode):pos(adminNode:getw() / 2, adminNode:geth() - 14)
	an.newLabel("管理员", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(adminNode:getw() / 2, adminNode:geth() - 14):add2(adminNode)

	local adminScroll = an.newScroll(4, 50, adminNode:getw() - 8, 94):add2(adminNode)
	local adminLists = {}
	local commandMode = an.newBtn(res.gettex2("pic/common/btn150.png"), function()
		sound.playSound("103")

		if isPreview then
			return
		end

		if g_data.voice.roomData:get("mode") == 1 then
			return
		end

		if g_data.voice.playerData:get("isAdmin") == 0 then
			main_scene.ui:tip("只有管理员才能更改模式.")

			return
		end

		net.send({
			CM_CHANNEL_CHANGE_MODE,
			param = 1,
			recog = g_data.voice.roomData:get("ID")
		})
	end, {
		clickSpace = 2,
		select = {
			res.gettex2("pic/common/btn151.png"),
			manual = true
		},
		label = {
			"指挥模式",
			20,
			1,
			{
				color = def.colors.btn20,
				sc = def.colors.btn20s
			}
		}
	}):add2(adminNode):pos(60, 25)
	local freeMode = an.newBtn(res.gettex2("pic/common/btn150.png"), function()
		sound.playSound("103")

		if isPreview then
			return
		end

		if g_data.voice.roomData:get("mode") == 0 then
			return
		end

		if g_data.voice.playerData:get("isAdmin") == 0 then
			main_scene.ui:tip("只有管理员才能更改模式.")

			return
		end

		net.send({
			CM_CHANNEL_CHANGE_MODE,
			param = 0,
			recog = g_data.voice.roomData:get("ID")
		})
	end, {
		clickSpace = 2,
		select = {
			res.gettex2("pic/common/btn151.png"),
			manual = true
		},
		label = {
			"自由模式",
			20,
			1,
			{
				color = def.colors.btn20,
				sc = def.colors.btn20s
			}
		}
	}):add2(adminNode):pos(adminNode:getw() - 60, 25)
	local logNode = display.newNode():size(223, 123):add2(self.content):pos(141, 67)

	display.newScale9Sprite(res.getframe2("pic/scale/scale21.png")):size(logNode:getContentSize()):anchor(0, 0):add2(logNode)
	res.get2(path .. "tab_bg.png"):add2(logNode):pos(logNode:getw() / 2, logNode:geth() - 14)
	an.newLabel("频道信息", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(logNode:getw() / 2, logNode:geth() - 14):add2(logNode)

	local logMax = 30
	local logScroll = an.newScroll(4, 4, logNode:getw() - 8, logNode:geth() - 35, {
		labelM = {
			20,
			1,
			params = {
				maxLine = logMax
			}
		}
	}):add2(logNode)
	local membersNode = display.newNode():size(260, 296):add2(self.content):pos(365, 67)

	display.newScale9Sprite(res.getframe2("pic/scale/scale21.png")):size(membersNode:getContentSize()):anchor(0, 0):add2(membersNode)
	res.get2(path .. "tab_bg.png"):add2(membersNode):pos(membersNode:getw() / 2, membersNode:geth() - 14)

	local label = an.newLabel("成员", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(membersNode:getw() / 2, membersNode:geth() - 14):add2(membersNode)
	local membersScroll = an.newScroll(4, 4, membersNode:getw() - 8, membersNode:geth() - 35):add2(membersNode)
	local membersLists = {}
	local memberSelectSpr
	local memberSelectData

	if isPreview then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local function go()
				self:requestEnter(nil, channelType)
			end

			if g_data.voice.roomData then
				an.newMsgbox(string.format("你确定离开当前频道并进入(%s)吗?", title), function(idx)
					if idx == 1 then
						go()
					end
				end, {
					center = true,
					hasCancel = true
				})
			else
				go()
			end
		end, {
			clickSpace = 2,
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"进入频道",
				20,
				1,
				{
					color = def.colors.btn20,
					sc = def.colors.btn20s
				}
			}
		}):add2(self.content):anchor(1, 0):pos(self:getw() - 12, 20)
	else
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if g_data.voice.playerData:get("isAdmin") == 0 then
				main_scene.ui:tip("你不是管理员")

				return
			end

			if not memberSelectData then
				main_scene.ui:tip("你还未选中成员")

				return
			end

			local node = display.newNode():size(110, 110):pos(414, 58):add2(self.content)

			display.newScale9Sprite("pic/scale/scale21.png"):size(node:getContentSize()):anchor(0, 0):add2(node)
			common.enablePopStyle(node, true)
			an.newBtn(res.gettex2("pic/common/btn150.png"), function()
				sound.playSound("103")
				node:removeSelf()

				if not memberSelectData then
					return
				end

				net.send({
					CM_CHANNEL_CHANGE_MUTE,
					recog = g_data.voice.roomData:get("ID"),
					param = (memberSelectData.data:get("isMute") + 1) % 2
				}, {
					memberSelectData.name
				})
			end, {
				sprite = res.gettex2("pic/panels/voice/" .. (memberSelectData.data:get("isMute") == 0 and "notalk" or "cantalk") .. ".png"),
				pressImage = res.gettex2("pic/common/btn151.png")
			}):add2(node):pos(node:getw() / 2, 80)
			an.newBtn(res.gettex2("pic/common/btn150.png"), function()
				sound.playSound("103")
				node:removeSelf()

				if not memberSelectData then
					return
				end

				net.send({
					CM_CHANNEL_KICK_OUT,
					recog = g_data.voice.roomData:get("ID")
				}, {
					memberSelectData.name
				})
			end, {
				sprite = res.gettex2("pic/panels/voice/kick.png"),
				pressImage = res.gettex2("pic/common/btn151.png")
			}):add2(node):pos(node:getw() / 2, 28)
		end, {
			sprite = res.gettex2("pic/panels/voice/operator.png"),
			pressImage = res.gettex2("pic/common/btn21.png")
		}):add2(self.content):anchor(1, 0):pos(self:getw() - 126, 16)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			net.send({
				CM_CHANNEL_EXIT
			})
		end, {
			clickSpace = 2,
			sprite = res.gettex2("pic/panels/voice/exit.png"),
			pressImage = res.gettex2("pic/common/btn21.png")
		}):add2(self.content):anchor(1, 0):pos(self:getw() - 18, 16)
	end

	function self.content.addLog(text)
		if not text then
			return
		end

		logScroll.labelM:nextLine():addLabel(text, def.colors.labelGray)
		logScroll:setScrollOffset(0, logScroll:getScrollSize().height - logScroll:geth())
	end

	function self.content.refershMode()
		local mode = roomData:get("mode")

		freeMode:setIsSelect(mode == 0)
		commandMode:setIsSelect(mode == 1)
	end

	function self.content.refershMemberCnt()
		local cnt = 0

		for i, v in ipairs(members) do
			if v:get("isAdmin") == 0 then
				cnt = cnt + 1
			end
		end

		label:setString(string.format("成员(%d)", cnt))
	end

	function self.content.addMember(v)
		local isAdmin = v:get("isAdmin") == 1
		local lists
		local scroll
		local lineh

		if isAdmin then
			lineh = 32
			scroll = adminScroll
			lists = adminLists
		else
			lineh = 38
			scroll = membersScroll
			lists = membersLists
		end

		local name = v:get("name")

		if lists[name] then
			return
		end

		local curCnt = table.nums(lists)
		local line = display.newNode():size(scroll:getw(), lineh):anchor(0, 1):pos(0, scroll:geth() - curCnt * lineh):add2(scroll)

		an.newLabel(v:get("name"), 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(10, line:geth() / 2):add2(line, 1)

		if not isAdmin then
			display.newScale9Sprite(res.getframe2("pic/scale/scale" .. (curCnt % 2 == 0 and 19 or 18) .. ".png")):anchor(0, 0):size(line:getContentSize()):add2(line)
			line:enableClick(function()
				if isPreview then
					return
				end

				if g_data.voice.playerData:get("isAdmin") == 0 then
					return
				end

				if not memberSelectSpr then
					local tmpSize = cc.size(line:getContentSize().width + 6, line:getContentSize().height + 6)

					memberSelectSpr = res.get2("pic/panels/voice/shine_frame.png"):pos(-6, 0):size(tmpSize):anchor(0, 1):add2(scroll)
				end

				if not memberSelectData or memberSelectData.name ~= name then
					memberSelectSpr:pos(line:getPositionX() - 6, line:getPositionY()):show()

					memberSelectData = {
						name = name,
						data = v
					}
				else
					memberSelectSpr:hide()

					memberSelectData = nil
				end
			end, {
				support = "scroll"
			})
		end

		function line.setState(state)
			if state == "mute" or state == "saying" then
				if not line.icon then
					line.icon = res.get2(path .. state .. ".png"):add2(line):pos(line:getw() - 30, line:geth() / 2)
				else
					line.icon:setTex(res.gettex2(path .. state .. ".png")):show()
				end
			elseif line.icon then
				line.icon:hide()
			end
		end

		line.setState(v:get("isMute") == 1 and "mute" or onMicNames[name] and "saying" or "normal")

		lists[name] = line
	end

	function self.content.delMember(name)
		local function del(lists, scroll)
			local line = lists[name]

			if not line then
				return
			end

			line:removeSelf()

			lists[name] = nil

			if memberSelectData and memberSelectData.name == name then
				memberSelectData = nil

				if memberSelectSpr then
					memberSelectSpr:hide()
				end
			end

			local curCnt = 0
			local lineh

			for k, v in pairs(lists) do
				lineh = lineh or v:geth()

				v:pos(0, scroll:geth() - curCnt * lineh)

				if memberSelectData and memberSelectData.name == v and memberSelectSpr then
					memberSelectSpr:pos(v:getPosition())
				end

				curCnt = curCnt + 1
			end

			return true
		end

		onMicNames[name] = nil

		return del(adminLists, adminScroll) or del(membersLists, membersScroll)
	end

	function self.content.stateChanged(v)
		local name = v:get("name")
		local line = adminLists[name] or membersLists[name]

		if line then
			line.setState(v:get("isMute") == 1 and "mute" or onMicNames[name] and "saying" or "normal")
		end
	end

	function self.content.refreshOnMicNames()
		if yaya.isonMic then
			self.content.addOnMicMember(common.getPlayerName())
		end

		for k, v in pairs(onMicNames) do
			if v.mark then
				v.mark = nil
			else
				local data = v.data

				onMicNames[k] = nil

				self.content.stateChanged(data)
			end
		end
	end

	function self.content.addOnMicMember(name)
		if onMicNames[name] then
			onMicNames[name].mark = true
		else
			local data = g_data.voice:getMember(name)

			if data then
				onMicNames[name] = {
					mark = true,
					data = data
				}

				self.content.stateChanged(data)
			end
		end
	end

	self.content.refershMode()

	for i, v in ipairs(members) do
		self.content.addMember(v)
	end

	self.content.refershMemberCnt()

	if isPreview then
		self.content.addLog("当前频道为: " .. (roomData:get("mode") == 0 and "自由模式" or "指挥模式"))
	else
		local logs = g_data.voice:getLastLog(logMax)

		for i2 = #logs, 1, -1 do
			self.content.addLog(logs[i2])
		end

		self.content:runForever(transition.sequence({
			cc.DelayTime:create(1),
			cc.CallFunc:create(self.content.refreshOnMicNames)
		}))
	end
end

function voice:modeChanged(log)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.refershMode()
	self.content.addLog(log)
end

function voice:memberJoin(v, log)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.addMember(v)
	self.content.refershMemberCnt()
	self.content.addLog(log)
end

function voice:memberExit(name, log)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.delMember(name)
	self.content.refershMemberCnt()
	self.content.addLog(log)
end

function voice:setIsMute(v, log)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.stateChanged(v)
	self.content.addLog(log)
end

function voice:setIsAdmin(v, log)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.delMember(v:get("name"))
	self.content.addMember(v)
	self.content.refershMemberCnt()
	self.content.addLog(log)
end

function voice:addOnMicMember(name)
	if not self.content or self.content.type ~= "members" then
		return
	end

	self.content.addOnMicMember(name)
end

local codes = {
	OP_CHANNEL_OK = {
		0,
		"成功"
	},
	OP_ERR_CHANNEL_EXIST = {
		-1,
		"已有频道, 请先退出再创建。"
	},
	OP_ERR_CHANNEL_FULL = {
		-2,
		"[创建频道] 频道数量已满"
	},
	OP_ERR_CHANNEL_CREATE_LIMIT_LEVEL = {
		-3,
		"[创建频道] 需要35级才可创建频道"
	},
	OP_ERR_CHANNEL_CREATE_ALREADY_JOININ = {
		-4,
		"[创建频道] 已经进入频道"
	},
	OP_ERR_CHANNEL_CREATE_INPUT_UNVALID = {
		-5,
		"[创建频道] 输入密码需为数字"
	},
	OP_ERR_CHANNEL_CREATE_INPUT_UNVALID2 = {
		-6,
		"[创建频道] 输入人数需在范围内"
	},
	OP_ERR_CHANNEL_ENTER_NOT_EXIST = {
		-7,
		"[进入频道] 频道不存在"
	},
	OP_ERR_CHANNEL_ENTER_NOT_MATCH = {
		-8,
		"[进入频道] 密码不正确或其它错误"
	},
	OP_ERR_CHANNEL_ENTER_OBJ_UNVALID = {
		-9,
		"[进入频道] 频道（行会或战队或队伍）不存在"
	},
	OP_ERR_CHANNEL_ENTER_FULL_MEMBER = {
		-10,
		"[进入频道] 该频道成员已满。"
	},
	OP_ERR_CHANNEL_EXIT_NOT_EXIST = {
		-11,
		"[退出频道] 频道不存在"
	},
	OP_ERR_CHANNEL_EXIT_NOT_MEMBER = {
		-12,
		"[退出频道] 不是该频道成员"
	},
	OP_ERR_CHANNEL_EXIT_NOT_INCHANNEL = {
		-13,
		"[退出频道] 您不在频道中（如果是踢玩家时的退出 则是该玩家不在频道中）"
	},
	OP_ERR_CHANNEL_SWITCH_NOT_AUTH = {
		-14,
		"[切换频道] 只有管理员才可操作"
	},
	OP_ERR_CHANNEL_SWITCH_NOT_MEMBER = {
		-15,
		"[切换频道] 不是该频道成员"
	},
	OP_ERR_CHANNEL_SWITCH_NOT_EXIST = {
		-16,
		"[切换频道] 频道不存在"
	},
	OP_ERR_CHANNEL_KICKOUT_NOT_AUTH = {
		-17,
		"[踢出成员] 只有管理员才可操作"
	},
	OP_ERR_CHANNEL_KICKOUT_NOT_MEMBER = {
		-18,
		"[踢出成员] 不是该频道成员"
	},
	OP_ERR_CHANNEL_KICKOUT_NOT_MEMBER_SEC = {
		-19,
		"[踢出成员] 对方不是该频道成员"
	},
	OP_ERR_CHANNEL_KICKOUT_NOT_EXIST = {
		-20,
		"[踢出成员] 频道不存在"
	},
	OP_ERR_CHANNEL_KICKOUT_NOT_AUTH_ADMIN = {
		-21,
		"[踢出成员] 不能将管理员踢出"
	},
	OP_ERR_CHANNEL_MUTE_NOT_AUTH = {
		-22,
		"[成员禁言] 只有管理员才可操作"
	},
	OP_ERR_CHANNEL_MUTE_NOT_EXIST = {
		-23,
		"[成员禁言] 频道不存在"
	},
	OP_ERR_CHANNEL_MUTE_NOT_MEMBER = {
		-24,
		"[成员禁言] 不是该频道成员"
	},
	OP_ERR_CHANNEL_MUTE_NOT_MEMBER_SEC = {
		-25,
		"[成员禁言] 对方不是该频道成员"
	},
	OP_ERR_CHANNEL_MUTE_NOT_AUTH_ADMIN = {
		-26,
		"[成员禁言] 不能将管理员禁言"
	},
	OP_ERR_CHANNEL_NAME_NOT_FIND = {
		-27,
		"玩家名错误或不在线"
	},
	OP_ERR_CHANNEL_MEMBERLIST_OBJ_UNVALID = {
		-28,
		"频道不存在"
	},
	OP_ERR_CHANNEL_MEMBERLIST_NOT_CREATE = {
		-29,
		"频道未创建"
	},
	OP_ERR_CHANNEL_SYSTEM_BUSY = {
		-30,
		"系统繁忙, 请稍后再试"
	},
	OP_ERR_CHANNEL_UNKNOWN = {
		-99,
		"未知错误"
	}
}

function voice.handleCode(code)
	for k, v in pairs(codes) do
		if v[1] == code then
			return k, v[2]
		end
	end
end

local channelTypes = {
	[0] = "ctPublic",
	"ctPersonal",
	"ctGuild",
	"ctCorps",
	"ctGroup"
}

function voice.getChannelType(value)
	return channelTypes[value] or "unknow"
end

return voice
