local info = {}

function info.show(data, scenePos, params)
	if g_data.player.showTips then
		return
	end

	g_data.player.showTips = true
	params = params or {}
	local layer = display.newNode():size(display.width, display.height):addto(params.parent or main_scene.ui, params.z or main_scene.ui.z.textInfo)

	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(false)
	layer:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		if event.name == "ended" then
			g_data.player.showTips = false

			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local playerorhero = nil

	if params.from == "heroBag" or params.from == "heroEquip" then
		playerorhero = g_data.hero
	elseif params.from == "bag" or params.from == "equip" then
		playerorhero = g_data.player
	else
		playerorhero = g_data.player
	end

	local getData, getDataStd = nil
	local double = 1

	if params.onlyStdItem then
		function getData(k)
			return data.getVar(k)
		end

		getDataStd = getData
	else
		function getData(k)
			return data.getVar(k)
		end

		function getDataStd(k)
			return data.getStd():get(k)
		end

		if data.isPileUp and data.isPileUp() then
			double = data:get("dura")
		end
	end

	function isBind()
		if getData("normalStateSet") then
			return ycFunction:band(getData("normalStateSet"), 2) ~= 0
		elseif getData("stdMode") == 2 then
			return getData("shape") == 10 or getData("shape") == 23 or getData("shape") == 31
		elseif getData("stdMode") == 3 then
			return getData("shape") == 30
		end
	end

	function isGift()
		if getData("VTGiftProp") then
			return getData("VTGiftProp") ~= 0
		end
	end

	function isUpgrade()
		if getData("normalStateSet") then
			return ycFunction:band(getData("normalStateSet"), 1) ~= 0
		end
	end

	function getExternText()
		if isBind() then
			local itemName = getData("name")

			if string.find(itemName, "(赠)") then
				return ""
			elseif isGift() then
				return "(赠)"
			else
				return "(绑)"
			end
		elseif isGift() then
			return "(赠)"
		end

		return ""
	end

	local labels = {
		an.newLabel(getData("name") .. getExternText(), 20, 1, {
			color = cc.c3b(255, 255, 0)
		}),
		an.newLabel("重量: " .. getData("weight") * double, 20, 1)
	}
	local btns = {}

	function add(text, color)
		text = text or ""
		labels[#labels + 1] = an.newLabel(text, 20, 1, {
			color = color
		})
	end

	function addAttr(text, key)
		local front = getData(key) or 0
		local after = getData("max" .. key) or 0

		if front > 0 or after > 0 then
			local normalAfter = getDataStd("max" .. key)

			if normalAfter and normalAfter < after then
				add(text .. front .. "-" .. after .. "  (+" .. after - normalAfter .. ")", display.COLOR_GREEN)
			else
				add(text .. front .. "-" .. after)
			end
		end
	end

	function addAttr2(text, value, normalValue, color, attachText)
		attachText = attachText or ""

		if normalValue and normalValue < value then
			add(text .. value .. attachText .. "  (+" .. value - normalValue .. attachText .. ")", display.COLOR_GREEN)
		else
			add(text .. value .. attachText, color)
		end
	end

	function needColor(a, b)
		return b <= a and display.COLOR_WHITE or display.COLOR_RED
	end

	function addNeed()
		local need = getData("need")
		local needLevel = getData("needLevel")

		if need == 0 then
			add("需要等级: " .. needLevel .. "级", needColor(playerorhero.ability:get("level"), needLevel))
		elseif need == 1 then
			add("需要攻击力: " .. needLevel, needColor(playerorhero.ability:get("maxDC"), needLevel))
		elseif need == 2 then
			add("需要魔法力: " .. needLevel, needColor(playerorhero.ability:get("maxMC"), needLevel))
		elseif need == 3 then
			add("需要精神力: " .. needLevel, needColor(playerorhero.ability:get("maxSC"), needLevel))
		elseif need == 4 then
			add("需要转生等级: " .. needLevel, display.COLOR_WHITE)
		elseif need == 40 then
			add("需要转生&等级: " .. needLevel, display.COLOR_WHITE)
		elseif need == 41 then
			add("需要转生&攻击力: " .. needLevel, display.COLOR_WHITE)
		elseif need == 42 then
			add("需要转生&魔法力: " .. needLevel, display.COLOR_WHITE)
		elseif need == 43 then
			add("需要转生&精神力力: " .. needLevel, display.COLOR_WHITE)
		elseif need == 44 then
			add("需要转生&声望点: " .. needLevel, display.COLOR_WHITE)
		elseif need == 5 then
			add("需要声望点: " .. needLevel, display.COLOR_WHITE)
		elseif need == 6 then
			add("行会成员专用", display.COLOR_WHITE)
		elseif need == 60 then
			add("行会掌门专用", display.COLOR_WHITE)
		elseif need == 7 then
			add("沙城成员专用", display.COLOR_WHITE)
		elseif need == 70 then
			add("沙城掌门专用", display.COLOR_WHITE)
		elseif need == 8 then
			add("会员专用", display.COLOR_WHITE)
		elseif need == 81 then
			add("会员类型 =" .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_WHITE)
		elseif need == 82 then
			add("会员类型 >= " .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_WHITE)
		end
	end

	local function tmpModf(value)
		local int, f = math.modf(value)

		return f >= 0.5 and int + 1 or int
	end

	local function getDuraColor(v)
		v = v or 1000
		local tmpDura = tmpModf(Word(data:get("dura") or getData("duraMax")) / v)

		return tmpDura == 0 and display.COLOR_RED or display.COLOR_WHITE
	end

	function duraStr(v)
		v = v or 1000

		if params.onlyStdItem then
			if params.hideMaxDura then
				return "-/-"
			else
				return math.modf(Word(getData("duraMax")) / v)
			end
		end

		if params.hideMaxDura then
			return tmpModf(Word(data:get("dura")) / v)
		else
			return tmpModf(Word(data:get("dura")) / v) .. "/" .. tmpModf(Word(data:get("duraMax")) / v)
		end
	end

	local stdMode = getData("stdMode")

	if stdMode == 0 then
		if getData("AC") > 0 then
			add("HP+" .. getData("AC"), display.COLOR_GREEN)
		end

		if getData("MAC") > 0 then
			add("MP+" .. getData("MAC"), display.COLOR_GREEN)
		end
	elseif stdMode == 1 then
		local shape = getData("shape") or 0

		if checkExist(shape, 1, 2, 5, 6, 7) then
			add("持续: " .. duraStr() .. " 小时")
		elseif checkExist(shape, 3, 4, 8, 9, 10) then
			add("累积: " .. duraStr() .. " 小时")
		elseif shape == 30 then
			add("使用: " .. duraStr(10) .. " 次")
		elseif shape == 34 then
			add("持久: " .. duraStr(1))
		elseif shape == 35 then
			add("使用: " .. duraStr(1) .. " 次")
		end
	elseif stdMode == 2 then
		local shape = getData("shape") or 0

		if shape == 9 then
			add("修复装备持久: " .. duraStr(100) .. "点", display.COLOR_GREEN)
		elseif shape == 20 then
			add("容量: " .. duraStr(), display.COLOR_GREEN)
			add("等级: " .. getData("needLevel"), display.COLOR_GREEN)
			add("品质: " .. getData("source"), display.COLOR_GREEN)
			add("酒精度: " .. getData("aniCount") .. "C°", display.COLOR_GREEN)
		elseif shape == 21 then
			add("品质: " .. getData("source"), display.COLOR_GREEN)
		else
			add("可用: " .. duraStr() .. "次", display.COLOR_GREEN)
		end
	elseif stdMode == 4 then
		local shape = getData("shape") or 0

		if checkExist(shape, 0, 1, 2) then
			local names = {
				"战士秘籍",
				"魔法秘籍",
				"道士秘籍"
			}

			add(names[shape + 1], display.COLOR_GREEN)
		end

		if not params.hideMaxDura then
			local needLevel = math.modf(Word(getData("duraMax")))

			add("需要等级: " .. needLevel .. "级", needColor(playerorhero.ability:get("level"), needLevel))
		end
	elseif checkExist(stdMode, 5, 6) then
		if isUpgrade() then
			labels[1]:setString("(*)" .. getData("name"))
		end

		add("持久: " .. duraStr(), getDuraColor())
		addAttr("攻击: ", "DC")
		addAttr("魔法: ", "MC")
		addAttr("道术: ", "SC")

		local source = getData("source")
		local sourceN = getDataStd("source")

		if checkIn(source, 1, 10) then
			addAttr2("强度: +", source, sourceN)
		elseif checkIn(source, -50, -1) then
			addAttr2("神圣: +", -source, -sourceN, display.COLOR_WHITE)
		elseif checkIn(source, -100, -51) then
			add("神圣: -" .. -source - 50, display.COLOR_RED)
		end

		local AC = getData("AC")
		local maxAC = getData("maxAC")
		local MAC = getData("MAC")
		local maxMAC = getData("maxMAC")
		local ACN = getDataStd("AC")
		local maxACN = getDataStd("maxAC")
		local MACN = getDataStd("MAC")
		local maxMACN = getDataStd("maxMAC")

		if maxAC > 0 then
			local ac = getData("accurate") or maxAC

			addAttr2("准确: +", ac, maxACN, display.COLOR_WHITE)
		end

		if maxMAC > 0 then
			if maxMAC > 10 then
				if macN then
					macN = maxMACN
					macN = macN > 10 and macN - 10 or macN
				end

				addAttr2("攻击速度: +", maxMAC - 10, macN, display.COLOR_WHITE)
			else
				add("攻击速度: -" .. maxMAC, display.COLOR_RED)
			end
		end

		if AC > 0 then
			addAttr2("幸运: +", AC, acN or ACN, display.COLOR_WHITE)
		end

		if MAC > 0 then
			add("诅咒: +" .. MAC, display.COLOR_RED)
		end

		addNeed()
	elseif stdMode == 7 then
		local shape = getData("shape") or 0

		if checkExist(shape, 0, 1, 2, 3) then
			local front = {
				"次数: ",
				"HP ",
				"MP ",
				"HPMP "
			}
			local after = {
				" 次",
				" 万",
				" 万",
				" 万"
			}

			add(front[shape + 1] .. duraStr() .. after[shape + 1])
		end

		addNeed()
	elseif checkExist(stdMode, 10, 11) then
		add("持久: " .. duraStr(), getDuraColor())
		addAttr("防御: ", "AC")
		addAttr("魔御: ", "MAC")
		addAttr("攻击: ", "DC")
		addAttr("魔法: ", "MC")
		addAttr("道术: ", "SC")

		local source = getData("source")
		local sourceN = getDataStd("source")

		if Lobyte(source) > 0 then
			addAttr2("幸运: +", Lobyte(source), sourceN and Lobyte(sourceN), display.COLOR_WHITE)
		end

		if Hibyte(source) > 0 then
			add("诅咒: +" .. Hibyte(source), display.COLOR_RED)
		end

		addNeed()
	elseif checkExist(stdMode, 15, 30, 16, 19, 20, 21, 22, 23, 24, 26, 27, 28, 52, 62, 53, 63, 54, 64) then
		if getData("shape") == 188 then
			local name = getData("name")

			p2("normal", "===================\n", name, "该道具似乎有特殊的属性规则")
		end

		local tmpShape = getData("shape") or 0

		if stdMode ~= 64 then
			add("持久: " .. duraStr(), getDuraColor())
		end

		local AC = getData("AC")
		local maxAC = getData("maxAC")
		local MAC = getData("MAC")
		local maxMAC = getData("maxMAC")
		local ACN = getDataStd("AC")
		local maxACN = getDataStd("maxAC")
		local MACN = getDataStd("MAC")
		local maxMACN = getDataStd("maxMAC")

		if stdMode == 19 or stdMode == 53 then
			if maxAC > 0 then
				addAttr2("魔法躲避: +", maxAC, maxACN, display.COLOR_WHITE, "0％")
			end

			if maxMAC > 0 then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_WHITE)
			end

			if MAC > 0 then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 20 or stdMode == 24 then
			if maxAC > 0 then
				addAttr2("准确: +", maxAC, maxACN, display.COLOR_WHITE)
			end

			if maxMAC > 0 then
				addAttr2("敏捷: +", maxMAC, maxMACN, display.COLOR_WHITE)
			end
		elseif stdMode == 21 then
			if maxAC > 0 then
				addAttr2("体力恢复: +", maxAC, maxACN, display.COLOR_WHITE, "0％")
			end

			if maxMAC > 0 then
				addAttr2("魔法恢复: +", maxMAC, maxMACN, display.COLOR_WHITE, "0％")
			end

			if AC > 0 then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_WHITE)
			end

			if MAC > 0 then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 23 then
			if maxAC > 0 then
				addAttr2("毒物躲避: +", maxAC, maxACN, display.COLOR_WHITE, "0％")
			end

			if maxMAC > 0 then
				addAttr2("中毒恢复: +", maxMAC, maxMACN, display.COLOR_WHITE, "0％")
			end

			if AC > 0 then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_WHITE)
			end

			if MAC > 0 then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 28 or stdMode == 27 then
			addAttr("防御: ", "AC")
			addAttr("魔御: ", "MAC")

			if getData("aniCount") > 0 then
				add("负重: +" .. getData("aniCount"), display.COLOR_WHITE)
			end
		elseif stdMode == 63 then
			if AC > 0 then
				add("HP: +" .. AC, display.COLOR_GREEN)
			end

			if maxAC > 0 then
				add("MP: +" .. maxAC, display.COLOR_GREEN)
			end

			if maxMAC > 0 then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_WHITE)
			end

			if MAC > 0 then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		else
			addAttr("防御: ", "AC")
			addAttr("魔御: ", "MAC")
		end

		addAttr("攻击: ", "DC")
		addAttr("魔法: ", "MC")
		addAttr("道术: ", "SC")

		local source = getData("source")

		if checkIn(source, -50, -1) then
			add("神圣: +" .. -source, display.COLOR_WHITE)
		elseif checkIn(source, -100, -51) then
			add("神圣: -" .. -source - 50, display.COLOR_RED)
		end

		if stdMode ~= 52 and stdMode ~= 64 then
			addNeed()
		end
	elseif stdMode == 25 then
		local shape = getData("shape") or 0

		if shape == 9 then
			add("容量: " .. duraStr(1))
		elseif shape == 10 or shape == 11 then
			add("持久: " .. duraStr(100))
		elseif shape == 8 then
			if getData("name") == "祝福罐" or getData("name") == "魔令包" then
				add("容量: " .. duraStr(100))
			else
				add("容量: " .. duraStr(10))
			end
		else
			add("数量: " .. duraStr(100))
		end
	elseif stdMode == 40 then
		add("品质: " .. duraStr())
	elseif stdMode == 42 then
		-- Nothing
	elseif stdMode == 43 then
		if not params.onlyStdItem then
			add("纯度: " .. math.modf(Word(data:get("dura")) / 1000))
		end
	elseif stdMode == 48 then
		-- Nothing
	elseif stdMode == 49 then
		-- Nothing
	end

	local desc = def.items.desc[getData("name")]

	if desc then
		local strs = string.split(desc, "\\")

		for i, v in ipairs(strs) do
			add(v)
		end
	end

	if params.extend then
		for i, v in ipairs(params.extend) do
			add(v, display.COLOR_RED)
		end
	end

	local function release(name)
		local msgBox, slider = nil
		local count = 0
		msgBox = an.newMsgbox("", function (idx)
			if idx == 1 and count > 0 then
				local useCnt = math.min(count, 6)

				local function use()
					if g_data.bag:use("eat", data:get("makeIndex")) then
						net.send({
							CM_EAT,
							recog = data:get("makeIndex")
						})

						useCnt = useCnt - 1

						if useCnt > 0 then
							scheduler.performWithDelayGlobal(use, 0.5)
						end
					end
				end

				use()
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("当前有" .. data:get("dura") / 100 .. "个" .. name, 18, 1):addTo(msgBox.bg):pos(60, 190):anchor(0, 0.5)

		local getout = an.newLabel("取出0个" .. name .. "(一次最多取6个)", 18, 1):addTo(msgBox.bg):pos(60, 160):anchor(0, 0.5)
		slider = an.newSlider(res.gettex2("pic/common/sliderBg3.png"), nil, res.gettex2("pic/common/sliderBlock3.png"), {
			scale9 = cc.size(280, 31),
			valueChange = function (value)
				count = math.min(data:get("dura") / 100, 6) * value

				getout:setString("取出" .. math.ceil(count) .. "个" .. name .. "(一次最多取6个)")
			end
		}):add2(msgBox.bg):pos(msgBox.bg:getw() / 2, 110):anchor(0.5, 0.5)
	end

	if getData("name") == "祝福罐" and params.from == "bag" and data:get("dura") >= 100 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/release.png",
			click = function ()
				release("祝福油")
			end
		}
	end

	if getData("name") == "魔令包" and params.from == "bag" and data:get("dura") >= 100 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/release.png",
			click = function ()
				release("魔族指令书")
			end
		}
	end

	if getData("name") == "金条" and params.from == "bag" then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/dh.png",
			click = function ()
				an.newMsgbox("确定使用一根金条兑换998000金币吗？", function ()
					if g_data.bag:use("eat", data:get("makeIndex")) then
						net.send({
							CM_EAT,
							recog = data:get("makeIndex")
						})

						if main_scene.ui.panels.bag then
							main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
						end
					end
				end, {
					center = true
				})
			end
		}
	end

	if (getData("name") == "祝福罐" or getData("name") == "泉水罐" or getData("name") == "魔令包") and params.from == "equip" then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/collect.png",
			click = function ()
				net.send({
					CM_DBLCLICKUSEITEM,
					recog = data:get("makeIndex"),
					param = U_BUJUK
				})
			end
		}
	end

	if params.itemLink then
		btns[#btns + 1] = {
			name = "添加链接",
			click = params.itemLink
		}
	end

	local function splitItem()
		local input = nil
		local msgbox = an.newMsgbox("", function (idx)
			if idx == 1 then
				local count = tonumber(input:getString())

				if not count or count < 0 or data:get("dura") < count then
					main_scene.ui:tip("请输入正确的数字！")
				else
					net.send({
						CM_SPLITITEM,
						tag = 0,
						recog = data:get("makeIndex"),
						param = count,
						series = params.from == "heroBag" and 1 or 0
					})
					playerorhero:setIsSplliting(true)
				end
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("当前堆叠数量为 " .. data:get("dura") .. ", 请输入拆分数量", 18, 1):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)

		input = an.newInput(0, 0, 300, 36, 3, {
			bg = {
				h = 36,
				tex = res.gettex2("pic/scale/edit.png")
			}
		}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 140):anchor(0.5, 0.5)
	end

	if params.from and (params.from == "bag" or params.from == "heroBag") and data.isPileUp() and data:get("dura") > 1 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/split.png",
			click = splitItem
		}
	end

	if params.from and params.from == "storage" and data.isPileUp() and data:get("dura") > 1 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/split.png",
			click = splitItem
		}
	end

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i, v in ipairs(btns) do
		local params = {
			pressImage = res.gettex2("pic/common/btn91.png")
		}

		if v.name then
			params.label = {
				v.name or "",
				20,
				1,
				{
					color = def.colors.btn30
				}
			}
		elseif v.sprite then
			params.sprite = res.gettex2(v.sprite)
		end

		local btn = an.newBtn(res.gettex2("pic/common/btn90.png"), function ()
			v.click()
		end, params):anchor(0.5, 0):pos(w * 0.5, h):add2(bg, 999):scale(0.9)
		btns[i] = btn
		w = math.max(w, btn:getw())
		h = h + btn:geth() + space
	end

	for i = #labels, 1, -1 do
		local v = labels[i]:addto(bg, 99):anchor(0, 0):pos(10, h)
		w = math.max(w, v:getw())
		h = h + v:geth() + space
	end

	w = w + 20
	h = h + 10

	for i, v in ipairs(btns) do
		v:setPositionX(w * 0.5)
	end

	local rect = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w then
		p.x = rect.width - w
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h < rect.y then
		p.y = h + rect.y
	end

	bg:size(w, h):pos(p.x, p.y)

	return layer
end

return info
