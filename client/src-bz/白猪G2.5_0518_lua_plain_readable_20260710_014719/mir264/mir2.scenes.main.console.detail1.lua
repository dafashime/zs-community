local magic = import("..common.magic")
local iconFunc = import(".iconFunc")
local detail = class("detail", function()
	return display.newNode()
end)

table.merge(detail, {
	lock,
	content
})

function detail:endLook(widgetx, widgety)
	if self.lock then
		return
	end

	self.lock = true

	local x, y = self.content:getPosition()

	self.content:scaleTo(0.2, 0.01)
	self.content:runs({
		cc.MoveTo:create(0.1, cc.p(self:getMovePos(widgetx, widgety, x, y))),
		cc.MoveTo:create(0.1, cc.p(widgetx, widgety)),
		cc.CallFunc:create(function()
			self:removeSelf()
		end)
	})
end

function detail:ctor(config, data, widgetx, widgety, widgetw, widgeth, from, widget)
	self:size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.detail)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "ended" then
			self:endLook(widgetx, widgety)
		end

		return true
	end)

	local space = 10
	local count, maxw = space, 200

	self.content = display.newNode():add2(self)

	local editNode

	if widget and widget.getEditNode then
		editNode = widget:getEditNode()
		maxw = math.max(maxw, editNode:getw() + space * 2)
	end

	local function addLine()
		local line = res.get2("pic/console/line.png"):anchor(0.5, 0):pos(maxw / 2, count):add2(self.content)

		line:scaleX((maxw - space * 2) / line:getw())

		count = count + line:geth()
	end

	local hasRemove = not config.banRemove and from == "console"

	if hasRemove then
		display.newScale9Sprite(res.getframe2("pic/scale/scale10.png")):anchor(0.5, 0):pos(maxw / 2, count - 3):size(maxw - space * 2, 32):add2(self.content):enableClick(function()
			self:endLook(widgetx, widgety)
			main_scene.ui.console:removeWidget(data.key)
		end)
		an.newLabel("移除", 24, 1, {
			color = cc.c3b(255, 255, 0)
		}):pos(maxw / 2, count - 3):anchor(0.5, 0):add2(self.content)

		count = count + 32 + 5
	end

	if editNode then
		editNode:pos(space, count):add2(self.content)

		count = count + editNode:geth()

		local title = an.newLabel("设置:", 18, 1, {
			color = cc.c3b(0, 255, 0)
		}):pos(space, count):add2(self.content)

		count = count + title:geth()

		addLine()
	end

	local fixedXText = config.fixedX and "限制X轴移动"
	local fixedYText = config.fixedY and "限制Y轴移动"
	local removeText = config.banRemove and "不可移除"

	if from == "console" and (fixedXText or fixedYText or removeText) then
		local label = an.newLabelM(maxw - space * 2, 18, 1, {
			manual = true
		}):pos(space, count):add2(self.content)

		if fixedXText then
			label:nextLine():addLabel(fixedXText, cc.c3b(255, 0, 0))
		end

		if fixedYText then
			label:nextLine():addLabel(fixedYText, cc.c3b(255, 0, 0))
		end

		if removeText then
			label:nextLine():addLabel(removeText, cc.c3b(255, 0, 0))
		end

		count = count + label:geth()

		addLine()
	end

	local desc = config.desc

	if config.class == "btnMove" and config.btntype == "skill" then
		desc = self:processSkillExtend(config, data, from)
	end

	if desc then
		if config.class == "btnMove" and config.btntype == "skill" then
			local descLabel = an.newLabelM(maxw - space * 2, 18, 1):pos(space, count):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0))

			for i, v in ipairs(desc) do
				descLabel:addLabel(v.text, v.color)
			end

			count = count + descLabel:geth()

			addLine()
		else
			local descLabel = an.newLabelM(maxw - space * 2, 18, 1):pos(space, count):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0)):addLabel(desc)

			count = count + descLabel:geth()

			addLine()
		end
	end

	local files = iconFunc:getFilenames(config, data)
	local icon = res.get2(files.bg):pos(space + 40, count + 40):add2(self.content)

	if files.sprite then
		res.get2(files.sprite):pos(icon:centerPos()):add2(icon)
	end

	local subtitle

	if config.class == "btnMove" then
		if config.btntype == "normal" then
			subtitle = "普通按钮"
		elseif config.btntype == "base" then
			subtitle = "基本技能"
		elseif config.btntype == "setting" then
			subtitle = "设置快捷键"
		elseif config.btntype == "skill" then
			local magicData = def.magic.getMagicConfigByUid(data.magicId)

			if magicData then
				if from == "skillHero" then
					subtitle = magicData.heroName
				else
					subtitle = magicData.name
				end
			end
		elseif config.btntype == "panel" then
			subtitle = "面板快捷键"
		end
	end

	an.newLabel(config.name or "", 18, 1, {
		color = cc.c3b(0, 255, 0)
	}):pos(space + 80, count + (subtitle and 45 or 30)):add2(self.content)

	if subtitle then
		an.newLabel(subtitle, 18, 1):pos(space + 80, count + 15):add2(self.content)
	end

	count = count + 80
	count = count + space

	local size = cc.size(maxw, count)
	local x, y

	local function checkx(x)
		x = x - size.width / 2 < 0 and size.width / 2 or x
		x = x + size.width / 2 > display.width and display.width - size.width / 2 or x

		return x
	end

	local function checky(y)
		y = y - size.height / 2 < 0 and size.height / 2 or y
		y = y + size.height / 2 > display.height and display.height - size.height / 2 or y

		return y
	end

	if widgetx - widgetw / 2 - size.width > 0 then
		x = widgetx - widgetw / 2 - size.width / 2
		y = checky(widgety + 50)
	end

	if not x and widgetx + widgetw / 2 + size.width < display.width then
		x = widgetx + widgetw / 2 + size.width / 2
		y = checky(widgety + 50)
	end

	if not x and widgety + widgeth / 2 + size.height < display.height then
		x = checkx(widgetx)
		y = widgety + widgeth / 2 + size.height / 2
	end

	if not x and widgety - widgeth / 2 - size.height > 0 then
		x = checkx(widgetx)
		y = widgety - widgeth / 2 - size.height / 2
	end

	if not x then
		x, y = checkx(widgetx), checky(widgety)
	end

	local beganPos, beganTouchPos

	self.content:setTouchEnabled(true)
	self.content:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			beganPos = cc.p(self.content:getPosition())
			beganTouchPos = cc.p(event.x, event.y)

			return true
		elseif event.name == "moved" then
			self.content:pos(event.x - beganTouchPos.x + beganPos.x, event.y - beganTouchPos.y + beganPos.y)
		end
	end)
	self.content:anchor(0.5, 0.5):size(size):scale(0.01):scaleTo(0.2, 1)
	self.content:pos(widgetx, widgety)
	self.content:runs({
		cc.MoveTo:create(0.1, cc.p(self:getMovePos(widgetx, widgety, x, y))),
		cc.MoveTo:create(0.1, cc.p(x, y))
	})
	display.newScale9Sprite(res.getframe2("pic/scale/scale5.png")):size(size):anchor(0, 0):add2(self.content, -1)
end

function detail:getMovePos(sx, sy, dx, dy)
	local retx, rety

	if sx < dx then
		retx = sx + 50
	elseif dx < sx then
		retx = sx - 50
	end

	if sy < dy then
		rety = sy - 50
	elseif dy < sy then
		rety = sy + 50
	end

	return retx or sx, rety or sy - 50
end

function detail:expressionIsFront(from, magicId)
	local isFront = from ~= "skillHero"

	if not isFront then
		local isUnion = checkIn(tonumber(magicId), {
			50,
			55
		})

		if isUnion then
			isFront = g_data.player.job <= g_data.hero.job
		end
	end

	return isFront
end

function detail:processSkillExtend(config, data, from)
	local desc = {}
	local magicData = def.magic.getMagicConfigByUid(data.magicId)

	if magicData then
		local isFront = self:expressionIsFront(from, data.magicId)
		local name = from == "skillHero" and magicData.heroName or magicData.name
		local descData = def.skill[name]

		if config.SkillLv then
			local descString = descData and descData[4]
			local pos_start, pos_end = 1

			repeat
				local s1, e1 = string.find(descString, "%u~%u", pos_start)
				local s2, e2 = string.find(descString, "%u", pos_start)
				local s, e

				if not s1 and not s2 then
					break
				elseif not s2 then
					s, e = s1, e1
				elseif not s1 then
					s, e = s2, e2
				elseif s1 <= s2 then
					s, e = s1, e1
				else
					s, e = s2, e2
				end

				desc[#desc + 1] = {
					text = string.sub(descString, pos_start, s - 1)
				}

				local expression = string.sub(descString, s, e)
				local valueString = self:calcExpression(expression, descData, config.SkillLv, isFront)

				desc[#desc + 1] = {
					text = valueString,
					color = display.COLOR_RED
				}
				pos_start = e + 1
				pos_end = e
			until pos_end == string.len(descString)

			if not pos_end then
				desc[#desc + 1] = {
					text = descString
				}
			elseif pos_end and pos_end < string.len(descString) then
				desc[#desc + 1] = {
					text = string.sub(descString, pos_end + 1)
				}
			end
		else
			local str = ""

			for sub in string.gmatch(descData and descData[4], "[^(A-DN)~]") do
				str = str .. sub
			end

			for i, v in ipairs(self:wordFilter()) do
				str = string.gsub(str, v, "")
			end

			desc[#desc + 1] = {
				text = str
			}
		end
	end

	return desc
end

function detail:calcExpression(express, data, lv, front)
	local result

	while true do
		local cfg = {
			nil,
			nil,
			nil,
			nil,
			"N",
			"A",
			"B",
			"C",
			"D",
			"A",
			"B",
			"C",
			"D"
		}

		local function dataError(index)
			if data[index] == "" then
				p2("error", "[skilldesc cofig is error] : Name:", front and data[2] or data[3], cfg[index] .. " express is nil, index: ", index)

				return true
			end
		end

		if express == "N" then
			if dataError(5) then
				break
			end

			result = self:calcField(data[5], lv) .. ""
		elseif express == "A" then
			if front then
				if dataError(6) then
					break
				end

				result = math.floor(self:calcField(data[6], lv)) .. ""
			else
				if dataError(10) then
					break
				end

				result = math.floor(self:calcField(data[10], lv)) .. ""
			end
		elseif express == "A~B" then
			if front then
				if dataError(6) or dataError(7) then
					break
				end

				result = math.floor(self:calcField(data[6], lv)) .. "~" .. math.ceil(self:calcField(data[7], lv))
			else
				if dataError(10) or dataError(11) then
					break
				end

				result = math.floor(self:calcField(data[10], lv)) .. "~" .. math.ceil(self:calcField(data[11], lv))
			end
		elseif express == "C~D" then
			if front then
				if dataError(8) or dataError(9) then
					break
				end

				result = math.floor(self:calcField(data[8], lv)) .. "~" .. math.ceil(self:calcField(data[9], lv))
			else
				if dataError(12) or dataError(13) then
					break
				end

				result = math.floor(self:calcField(data[12], lv)) .. "~" .. math.ceil(self:calcField(data[13], lv))
			end
		end

		break
	end

	return result
end

function detail:calcField(express, lv)
	local function getExpress(str)
		local express

		xpcall(function()
			express = loadstring("return " .. str)()
		end, function()
			express = str
		end)

		if type(express) == "table" then
			return express[lv] and express[lv] or express[0]
		else
			return str
		end
	end

	local newExpress = getExpress(express)

	newExpress = string.gsub(newExpress, "<SkillLv>", "lv")

	local cfg = {
		"DC",
		"MC",
		"SC",
		"maxDC",
		"maxMC",
		"maxSC"
	}

	for i, v in ipairs(cfg) do
		newExpress = string.gsub(newExpress, "<" .. v .. ">", string.format("g_data.player.ability:get(\"%s\")", v))
		newExpress = string.gsub(newExpress, "<hero" .. v .. ">", string.format("g_data.hero.ability:get(\"%s\")", v))
	end

	local fun = loadstring("local lv = ... return " .. newExpress)

	return fun(lv)
end

function detail:wordFilter()
	return {
		"点",
		"(骷髅等级最高可提升至级)",
		"(神兽等级最高可提升至级)",
		"(月灵等级最高可提升至级)"
	}
end

return detail
