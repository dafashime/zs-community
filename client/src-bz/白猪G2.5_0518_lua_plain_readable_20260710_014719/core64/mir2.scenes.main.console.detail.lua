local magic = import("..common.magic")
local iconFunc = import(".iconFunc")
local detail = require("mir2.scenes.main.console.detail1")

function detail:ctor(value, sprite, x2, y3, value2, value3, value5, value7)
	self.size(self, display.width, display.height):addto(main_scene.ui, main_scene.ui.z.detail)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function(nameOwner)
		if nameOwner.name == "ended" then
			self:endLook(x2, y3)
		end

		return true
	end)

	local y = 10
	local y2 = y
	local x = 200

	self.content = display.newNode():add2(self)

	local editNode

	if value7 and value7.getEditNode then
		editNode = value7.getEditNode(value7)
		x = math.max(x, editNode.getw(editNode) + y * 2)
	end

	local function callback()
		local value_2 = res.get2("pic/console/line.png"):anchor(0.5, 0):pos(x / 2, y2):add2(self.content)

		value_2.scaleX(value_2, (x - y * 2) / value_2.getw(value_2))

		y2 = y2 + value_2.geth(value_2)
	end

	if not value.banRemove and value5 == "console" then
		display.newScale9Sprite(res.getframe2("pic/scale/scale10.png")):anchor(0.5, 0):pos(x / 2, y2 - 3):size(x - y * 2, 32):add2(self.content):enableClick(function()
			self:endLook(x2, y3)
			main_scene.ui.console:removeWidget(sprite.key)
		end)
		an.newLabel("移除", 24, 1, {
			color = cc.c3b(255, 255, 0)
		}):pos(x / 2, y2 - 3):anchor(0.5, 0):add2(self.content)

		y2 = y2 + 32 + 5
	end

	if editNode then
		editNode.pos(editNode, y, y2):add2(self.content)

		y2 = y2 + editNode.geth(editNode)

		local label = an.newLabel("设置:", 18, 1, {
			color = cc.c3b(0, 255, 0)
		}):pos(y, y2):add2(self.content)

		y2 = y2 + label.geth(label)

		callback()
	end

	fixedXText = value.fixedX and "限制X轴移动"

	local value4 = value.fixedY and "限制Y轴移动"
	local value6 = value.banRemove and "可移除"

	if value5 == "console" and (fixedXText or value4 or value6) then
		local label2 = an.newLabelM(x - y * 2, 18, 1, {
			manual = true
		}):pos(y, y2):add2(self.content)

		if fixedXText then
			label2.nextLine(label2):addLabel(fixedXText, cc.c3b(255, 0, 0))
		end

		if value4 then
			label2.nextLine(label2):addLabel(value4, cc.c3b(255, 0, 0))
		end

		if value6 then
			label2.nextLine(label2):addLabel(value6, cc.c3b(255, 0, 0))
		end

		y2 = y2 + label2.geth(label2)

		callback()
	end

	local text
	local text2

	if x2 > math.floor(x2) then
		local value8, value9 = math.modf(x2)

		text = value8
	else
		text = x2
	end

	if y3 > math.floor(y3) then
		local value10, value11 = math.modf(y3)

		text2 = value10
	else
		text2 = y3
	end

	if text and text2 and def.bzm2debug then
		local text3 = tostring(text) .. "," .. tostring(text2)
		local label3 = an.newLabelM(x - y * 2, 18, 1):pos(y, y2):add2(self.content):addLabel("Current: ", def.colors.clGreen):addLabel(text3)

		y2 = y2 + label3.geth(label3)

		callback()
	end

	if value.btntype == "skill" then
		local magicConfigByUid = def.magic.getMagicConfigByUid(sprite.magicId, main_scene.ground.player)

		if magicConfigByUid.continueFire and magicConfigByUid.continueFire > 0 then
			local label4 = an.newLabelM(x - y * 2, 18, 1):pos(y, y2):add2(self.content):addLabel("该技能支持连续施法！", def.colors.clGreen)

			y2 = y2 + label4.geth(label4)

			callback()
		end
	end

	local value12 = value.desc

	if value.class == "btnMove" and value.btntype == "skill" then
		value12 = self.processSkillExtend(self, value, sprite, value5)
	end

	if value12 then
		if value.class == "btnMove" and value.btntype == "skill" then
			local label5 = an.newLabelM(x - y * 2, 18, 1):pos(y, y2):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0))

			for _, item in ipairs(value12) do
				label5.addLabel(label5, item.text, item.color)
			end

			y2 = y2 + label5.geth(label5)

			callback()
		else
			local label6 = an.newLabelM(x - y * 2, 18, 1):pos(y, y2):add2(self.content):addLabel("描述: ", cc.c3b(0, 255, 0)):addLabel(value12)

			y2 = y2 + label6.geth(label6)

			callback()
		end
	end

	local filenames = iconFunc:getFilenames(value, sprite)
	local value_2 = res.get2(filenames.bg):pos(y + 40, y2 + 40):add2(self.content)

	if sprite.magicId then
		filenames.sprite = def.magic.buildSkillIcon(sprite.magicId)
	end

	if filenames.sprite then
		res.get2(filenames.sprite):pos(value_2.centerPos(value_2)):add2(value_2)
	end

	local text4

	if value.class == "btnMove" then
		if value.btntype == "normal" then
			text4 = "普通按钮"
		elseif value.btntype == "base" then
			text4 = "基本技能"
		elseif value.btntype == "setting" then
			text4 = "设置快捷键"
		elseif value.btntype == "skill" then
			local magicConfigByUid2 = def.magic.getMagicConfigByUid(sprite.magicId, main_scene.ground.player)

			if magicConfigByUid2 then
				if value5 == "skillHero" then
					text4 = magicConfigByUid2.heroName
				else
					text4 = magicConfigByUid2.name
				end

				if magicConfigByUid2.name and string.find(magicConfigByUid2.name, "|") ~= nil then
					local parts = string.split(magicConfigByUid2.name, "|")
					local value13 = g_data.player.job

					if value13 >= 8 then
						value13 = value13 - 5
					end

					text4 = parts[value13 + 1]
				end

				if magicConfigByUid2 and magicConfigByUid2.extName then
					text4 = text4 .. magicConfigByUid2.extName
				end
			end
		elseif value.btntype == "panel" then
			text4 = "面板快捷键"
		end
	end

	local label7 = an.newLabel(value.name or "", 18, 1, {
		color = cc.c3b(0, 255, 0)
	})

	an.newLabel(value.name or "", 18, 1, {
		color = cc.c3b(0, 255, 0)
	}).pos(label7, y + 80, y2 + (text4 and 45 or 30)):add2(self.content)

	if text4 then
		an.newLabel(text4, 18, 1):pos(y + 80, y2 + 15):add2(self.content)
	end

	y2 = y2 + 80
	y2 = y2 + y

	local size = cc.size(x, y2)
	local x3
	local y4

	local function callback2(self)
		self = self - size.width / 2 < 0 and size.width / 2 or self
		self = display.width < self + size.width / 2 and display.width - size.width / 2 or self

		return self
	end

	local function callback3(self)
		self = self - size.height / 2 < 0 and size.height / 2 or self
		self = display.height < self + size.height / 2 and display.height - size.height / 2 or self

		return self
	end

	if x2 - value2 / 2 - size.width > 0 then
		x3 = x2 - value2 / 2 - size.width / 2
		y4 = callback3(y3 + 50)
	end

	if not x3 and x2 + value2 / 2 + size.width < display.width then
		x3 = x2 + value2 / 2 + size.width / 2
		y4 = callback3(y3 + 50)
	end

	if not x3 and y3 + value3 / 2 + size.height < display.height then
		x3 = callback2(x2)
		y4 = y3 + value3 / 2 + size.height / 2
	end

	if not x3 and y3 - value3 / 2 - size.height > 0 then
		x3 = callback2(x2)
		y4 = y3 - value3 / 2 - size.height / 2
	end

	if not x3 then
		y4 = callback3(y3)
		x3 = callback2(x2)
	end

	local point
	local point2

	self.content:setTouchEnabled(true)
	self.content:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x)
		if x.name == "began" then
			point = cc.p(self.content:getPosition())
			point2 = cc.p(x.x, x.y)

			return true
		elseif x.name == "moved" then
			self.content:pos(x.x - point2.x + point.x, x.y - point2.y + point.y)
		end
	end)
	self.content:anchor(0.5, 0.5):size(size):scale(0.01):scaleTo(0.2, 1)
	self.content:pos(x2, y3)
	self.content:runs({
		cc.MoveTo:create(0.1, cc.p(self.getMovePos(self, x2, y3, x3, y4))),
		cc.MoveTo:create(0.1, cc.p(x3, y4))
	})
	display.newScale9Sprite(res.getframe2("pic/scale/scale5.png")):size(size):anchor(0, 0):add2(self.content, -1)
end

function detail:processSkillExtend(skillData, level, level2)
	local items = {}
	local magicConfigByUid = def.magic.getMagicConfigByUid(level.magicId, main_scene.ground.player)

	if magicConfigByUid then
		local value = self.expressionIsFront(self, level2, level.magicId)
		local text = level2 == "skillHero" and magicConfigByUid.heroName or magicConfigByUid.name

		if string.find(text, "|") ~= nil then
			text = string.split(text, "|")[g_data.player.job + 1] or nil
		end

		if not text then
			return
		end

		local value2 = def.skill[text]

		if skillData.SkillLv then
			local text2 = value2 and value2[4]

			if not text2 then
				return
			end

			local count = 1
			local value3

			repeat
				local value4, value5 = string.find(text2, "%u~%u", count)
				local value6, value7 = string.find(text2, "%u", count)
				local value8
				local value9

				if not value4 and not value6 then
					break
				elseif not value6 then
					value9 = value5
					value8 = value4
				elseif not value4 then
					value9 = value7
					value8 = value6
				elseif value4 <= value6 then
					value9 = value5
					value8 = value4
				else
					value9 = value7
					value8 = value6
				end

				items[#items + 1] = {
					text = string.sub(text2, count, value8 - 1)
				}

				local text3 = string.sub(text2, value8, value9)
				local text4 = self.calcExpression(self, text3, value2, skillData.SkillLv, value)

				items[#items + 1] = {
					text = text4,
					color = display.COLOR_RED
				}
				count = value9 + 1
				value3 = value9
			until value3 == string.len(text2)

			if not value3 then
				items[#items + 1] = {
					text = text2
				}
			elseif value3 and value3 < string.len(text2) then
				items[#items + 1] = {
					text = string.sub(text2, value3 + 1)
				}
			end
		else
			local text5 = ""
			local value10
			local value11 = value2 and value2[4]

			if value11 then
				for index in string.gmatch(value11, "[^(A-DN)~]") do
					text5 = text5 .. index
				end

				for _, item in ipairs(self.wordFilter(self)) do
					text5 = string.gsub(text5, item, "")
				end

				items[#items + 1] = {
					text = text5
				}
			end
		end
	end

	return items
end

return detail
