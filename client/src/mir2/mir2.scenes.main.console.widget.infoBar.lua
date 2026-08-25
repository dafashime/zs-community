local infoBar = class("infoBar", function ()
	return display.newNode()
end)

table.merge(infoBar, {
	bg,
	info = {
		player,
		energy,
		mobile
	},
	default = {
		g = 0,
		a = 255,
		r = 0,
		b = 0
	}
})

function infoBar:ctor(config, data)
	data.r = data.r or self.default.r
	data.g = data.g or self.default.g
	data.b = data.b or self.default.b
	data.a = data.a or self.default.a
	local bgH = 30
	self.bg = display.newScale9Sprite(res.getframe2("pic/console/infobar/top.png"), display.cx, bgH / 2, cc.size(display.width, bgH)):add2(self)

	self:size(display.width, self.bg:geth()):anchor(0.5, 0.5):pos(data.x, data.y)

	self.state = an.newBtn(res.gettex2("pic/common/state.png"), function ()
		self:switch()
		self:showActiveType(nil, -1)
	end, {
		size = cc.size(60, self:geth())
	}):addTo(self):pos(30, self:geth() / 2):anchor(0.5, 0.5)
	local cfg = {
		player = {
			level = {
				type = "label"
			}
		},
		energy = {},
		mobile = {
			webinfo = {
				ancX = 1,
				type = "label"
			},
			engine = {
				ancX = 1,
				type = "label"
			},
			signal = {
				ancX = 1,
				type = "sprite"
			},
			time = {
				ancX = 1,
				type = "label"
			},
			battery = {
				p2 = "pic/console/infobar/empty.png",
				ancX = 1,
				p1 = "pic/console/infobar/full.png",
				type = "progress",
				offset = {
					x = 4,
					y = 4
				}
			}
		}
	}

	for i, v in pairs(cfg) do
		self.info[i] = display.newNode():addTo(self):size(self:getw(), self:geth())

		for k, var in pairs(v) do
			if var.type == "label" then
				local labelColor = nil

				if k == "engine" then
					labelColor = display.COLOR_GREEN
				else
					labelColor = display.COLOR_WHITE
				end

				self.info[i][k] = an.newLabel("", 16, 1, {
					color = labelColor
				}):addTo(self.info[i], 1):pos(0, self:geth() / 2):anchor(var.ancX or 0, 0.5)

				if var.value then
					self.info[i][k]:enableClick(function ()
						self:showActiveType(self.info[i][k], var.value)
					end)
				end
			elseif var.type == "sprite" then
				self.info[i][k] = display.newSprite():addTo(self.info[i]):anchor(var.ancX or 0, 0.5):pos(0, self:geth() / 2)
			elseif var.type == "progress" then
				self.info[i][k] = an.newProgress(res.gettex2(var.p1), res.gettex2(var.p2), var.offset):addTo(self.info[i]):anchor(var.ancX or 0, 0.5)
			end

			if var.icon then
				self.info[i][k].icon = res.get2("pic/console/infobar/" .. k .. ".png"):addTo(self.info[i]):pos(0, self:geth() / 2):anchor(var.ancX or 0, 0.5)
			elseif var.bg then
				self.info[i][k].bg = res.get2("pic/console/infobar/btn.png"):addTo(self.info[i]):pos(0, self:geth() / 2):anchor(0.5, 0.5)
			end
		end
	end

	self:switch()
	self:uptAbility()
	self:uptMobile()
	self:uptVitality()
	self:uptStamina()
	self:uptExp()
	self:uptBlood()

	if device.platform == "android" then
		self:getEventDispatcher():addEventListenerWithSceneGraphPriority(cc.EventListenerCustom:create("BATTERY_CHANGED", function ()
			self:uptBattery()
		end), self)
		self:schedule(function ()
			self:uptTime()
		end, 1)
	else
		self:schedule(function ()
			self:uptTime()
			self:uptBattery()
		end, 10)
	end

	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(cc.EventListenerCustom:create("CONNECTIVITY_ACTION", function ()
		self:uptSignal()
	end), self)
end

function infoBar:getEditNode()
	local node = display.newNode():size(540, 50)
	local cnt = 0
	local space = 45
	local begin = 15

	local function add(key, name)
		local num = an.newLabel("", 16, 1, {
			color = cc.c3b(0, 255, 255)
		}):add2(node):anchor(0, 0.5):pos(420, node:geth() - begin - cnt * space)

		local function upt(uptUI)
			if key == "a" then
				local p = math.modf(self.data[key] / 255 * 100)

				num:setString(name .. "(" .. p .. "％)")
			else
				num:setString(name .. "(" .. self.data[key] .. "/255)")
			end

			if uptUI then
				self.bg:opacity(self.data.a)
			end
		end

		upt()

		local slider = an.newSlider(res.gettex2("pic/common/sliderBg.png"), res.gettex2("pic/common/sliderBar.png"), res.gettex2("pic/common/sliderBlock.png"), {
			value = (self.data[key] - 0) / 255,
			valueChange = function (value)
				local color = 255 * value + 0
				self.data[key] = math.modf(color)

				upt(true)
			end,
			valueChangeEnd = function (value)
				local color = 255 * value + 0
				self.data[key] = math.modf(color)

				upt(true)
			end
		}):add2(node):anchor(0, 0.5):pos(20, node:geth() - begin - cnt * space)
		cnt = cnt + 1
	end

	add("a", "不透明度")

	return node
end

function infoBar:switch()
	self.switchVar = not self.switchVar
	local var = self.switchVar

	self.state:setScaleX(var and 1 or -1)
	self.info.player:setVisible(var)
	self.info.energy:setVisible(not var)
	self:uptPos()
end

function infoBar:uptPos()
	local x = 60
	local y = self:geth() / 2

	local function uptPos(obj, space)
		obj:pos(x, y)

		x = x + obj:getw() + space
	end

	if self.switchVar then
		local objs = {
			"level"
		}

		for i, v in ipairs(objs) do
			if self.info.player[v].icon then
				uptPos(self.info.player[v].icon, 2)
			end

			uptPos(self.info.player[v], 15)
		end
	else
		local objs = {
			"active",
			"stamina",
			"exp",
			"blood"
		}

		for i, v in ipairs(objs) do
			if self.info.energy[v].bg then
				self.info.energy[v].bg:pos(x + self.info.energy[v]:getw() / 2, y)
			end

			uptPos(self.info.energy[v], 15)
		end
	end
end

function infoBar:uptAbility()
	for k, v in pairs({
		"level",
		"gold",
		"yb",
		"bag",
		"equip"
	}) do
		self["upt" .. string.ucfirst(v)](self)
	end
end

function infoBar:uptMobile()
	local x = display.width - 5
	local y = self:geth() / 2

	local function uptPos(obj)
		obj:pos(x, y)

		x = x - obj:getw() - 15
	end

	for k, v in ipairs({
		"battery",
		"time",
		"signal",
		"engine",
		"webinfo"
	}) do
		self["upt" .. string.ucfirst(v)](self)
		uptPos(self.info.mobile[v])
	end
end

function infoBar:uptLevel()
	local ability = g_data.player.ability

	self.info.player.level:setString("Lv: " .. ability:get("level"))
	self:uptPos()
end

function infoBar:uptGold()
end

function infoBar:uptYb()
end

function infoBar:uptBag()
end

function infoBar:uptEquip()
end

function infoBar:uptWebinfo()
	self.info.mobile.webinfo:setString(def.serverinfo or "serverinfo")
end

function infoBar:uptEngine()
	self.info.mobile.engine:setString("by战神引擎")
end

function infoBar:uptVitality()
end

function infoBar:uptStamina()
end

function infoBar:uptExp()
end

function infoBar:uptBlood()
	local function upt(text)
		self.info.energy.blood:setString(text)

		local w = self.info.energy.blood:getw() + 10

		self.info.energy.blood.bg:setScaleX(w / self.info.energy.blood.bg:getw())
	end

	if g_data.player.vitaliyitem and g_data.player.vitaliyitem > 0 then
		upt("魔龙之血时间: " .. g_data.player.vitaliyitem .. "秒")
		self.blood:stopAllActions()
		self.blood:runForever(transition.sequence({
			cc.DelayTime:create(1),
			cc.CallFunc:create(function ()
				g_data.player.vitaliyitem = g_data.player.vitaliyitem - 1

				if g_data.player.vitaliyitem < 0 then
					upt()
					self.blood:stopAllActions()
				else
					upt("魔龙之血时间: " .. g_data.player.vitaliyitem .. " 秒")
					self:uptPos()
				end
			end)
		}))
	end
end

function infoBar:uptSignal()
	local ok, ret = nil

	if device.platform == "ios" then
		local status = network.getInternetConnectionStatus()
		ret = ({
			"wifi",
			"mobile"
		})[status] or "null"
		ok = true
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "DeviceUtil", "getCurrentNetType", {}, "()Ljava/lang/String;")
	end

	if ok and ret then
		ret = string.lower(ret)

		self.info.mobile.signal:setTex(res.gettex2("pic/console/infobar/" .. (ret == "wifi" and "wifi" or "3g") .. ".png"))
	end
end

function infoBar:uptTime()
	self.info.mobile.time:setString(os.date("%H:%M"))
end

function infoBar:uptBattery()
	local ok, ret = nil

	if device.platform == "ios" then
		ok, ret = luaoc.callStaticMethod("iosFuncs", "getBattery")
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "getBattery", {}, "()I")
	end

	if ok and ret then
		local p = ret / 100

		if p > 1 then
			p = 1
		end

		if p < 0 then
			p = 0
		end

		self.info.mobile.battery:setp(p)
	end
end

function infoBar:showActiveType(src, type)
	if self.Activecontent then
		local lastType = self.Activecontent.type

		self.Activecontent:removeSelf()

		self.Activecontent = nil

		if lastType == type or type == -1 then
			return
		end
	elseif type == -1 then
		return
	end

	local info = {
		{
			"每天指定时间自动获得活力值",
			"拥有活力值时打怪可获得多倍经验",
			"详细介绍可至边界城水晶鉴定师查看"
		},
		{
			"精力值是由精力水晶鉴定后获得",
			"必须达到25级才能鉴定精力水晶",
			"拥有精力值打怪可获得大量多倍经验",
			"详细介绍可至边界城水晶鉴定师查看"
		},
		{
			"当活力值、精力值都消耗完毕继续打怪的经验可增加储存经验",
			"拥有储存经验值可在边界城水晶鉴定师处直接消耗储存经验来兑换多倍活力值、精力值经验",
			"详细介绍可至边界城水晶鉴定师查看"
		},
		{
			"在魔龙之血使用后的有效时间内可快速通过打怪消耗活力值、精力值"
		}
	}
	local content = an.newLabelM(320, 16, 1, {
		manual = false
	}):anchor(0, 0)
	info = info[type] or {}

	for i, v in ipairs(info) do
		content:addLabel(v)

		if i ~= #info then
			content:nextLine()
		end
	end

	self.Activecontent = display.newNode():anchor(0, 1):pos(src:getPositionX(), 0):size(content:getw() + 20, content:geth() + 20):add2(self)
	self.Activecontent.type = type

	self.Activecontent:enableClick(function ()
		self.Activecontent:removeSelf()

		self.Activecontent = nil
	end)
	display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):anchor(0, 0):size(self.Activecontent:getContentSize()):add2(self.Activecontent)
	content:pos(10, 10):add2(self.Activecontent, 3)
end

return infoBar
