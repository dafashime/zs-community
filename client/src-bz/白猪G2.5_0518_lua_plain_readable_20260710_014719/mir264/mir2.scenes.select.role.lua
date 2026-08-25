local function getBeginID(work, sex, unselect)
	return work * 40 + math.max(0, sex - 1) * 120 + (unselect and 20 or 0)
end

local role = class("role", function()
	return display.newNode()
end)

table.merge(scene, {})

function role:ctor(work, sex)
	local anchors = {
		{
			0.5766666666666667,
			0.11944444444444445
		},
		{
			0.5366666666666666,
			0.10555555555555556
		},
		{
			0.5176056338028169,
			0.10650887573964497
		},
		{
			0.5833333333333334,
			0.13333333333333333
		},
		{
			0.5227272727272727,
			0.05466237942122187
		},
		{
			0.46938775510204084,
			0.07643312101910828
		}
	}
	local anchorIndex = work + (sex - 1) * 3
	local value = anchors[anchorIndex] and anchors[anchorIndex][1] or anchors[1][1]
	local value2 = anchors[anchorIndex] and anchors[anchorIndex][2] or anchors[1][2]

	if work > 8 and def.jobMaps then
		local value3 = def.jobMaps[work - 1]

		if value3 then
			value = value3.anchor0 or anchors[1][1]
			value2 = value3.anchor1 or anchors[1][2]
		end
	end

	local beginid = getBeginID(work, sex)

	self.sprite = display.newSprite(res.gettex("chrsel", beginid)):anchor(value, value2):addto(self)
	self.work = work
	self.sex = sex
	self.effect = nil
end

function role:setState(state)
	if state == "new" then
		self.sprite:opacity(0):fadeIn(0.5):run(cc.CallFunc:create(function()
			self:setState("normal")
		end))
	elseif state == "normal" then
		local beginid = getBeginID(self.work, self.sex)

		self.sprite:run(cc.RepeatForever:create(cc.Animate:create(res.getani("chrsel", beginid, beginid + 15, 0.15))))
	elseif state == "stone" then
		local beginid2 = getBeginID(self.work, self.sex, true)
		local tex = res.gettex("chrsel", beginid2)

		self.sprite:setTex(tex)
	elseif state == "selected" then
		self.sprite:stopAllActions()

		local beginid3 = getBeginID(self.work, self.sex, true)

		self.sprite:runs({
			cc.Animate:create(res.getani("chrsel", beginid3, beginid3 + 12, 0.1)),
			cc.CallFunc:create(function()
				self:setState("normal")
			end)
		})

		self.effect = m2spr.new("chrsel", 4)

		self.effect.spr:anchor(0.5, 0.1):addto(self)
		self.effect:playAni("chrsel", 4, 14, 0.1, true, nil, true, function()
			self.effect:removeSelf()

			self.effect = nil
		end)
	elseif state == "unselected" then
		if self.effect then
			self.effect:removeSelf()

			self.effect = nil
		end

		self.sprite:stopAllActions()

		local beginid4 = getBeginID(self.work, self.sex, true)
		local animation = res.getani("chrsel", beginid4, beginid4 + 12, 0.1, nil, true)

		self.sprite:runs({
			cc.Animate:create(animation),
			cc.CallFunc:create(function()
				self:setState("stone")
			end)
		})
	end

	return self
end

return role
