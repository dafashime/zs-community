local hotKey = {}

function hotKey:setKeyInfos(info)
	self.keyInfos = info
end

function hotKey:getKeyInfos()
	return self.keyInfos
end

function hotKey:getHotKeySet()
	if not self.hotKeySet or #self.hotKeySet == 0 then
		self.hotKeySet = {}
		local index = 1

		for _, v in ipairs(def.operate.hotKeySet) do
			for _, version in ipairs(v.version) do
				if tostring(version) == tostring(def.gameVersionType) then
					v.id = index

					table.insert(self.hotKeySet, v)

					index = index + 1

					break
				end
			end
		end
	end

	return self.hotKeySet
end

function hotKey:resetKey(id, key)
	local i_type = self:getType(id)

	if not i_type then
		return false
	end

	for _, v in ipairs(self.keyInfos) do
		if v.keyType == i_type.keyType and (not i_type.name or v.params and v.params.name == i_type.name) then
			v.keyType = nil
			v.params = nil
		end
	end

	for _, v in ipairs(self.keyInfos) do
		local isIn = true

		for _, v2 in ipairs(key) do
			if not self:iskeyInList(v2, v.pressKey) then
				isIn = false
			end
		end

		if #v.pressKey == #key and isIn then
			if v.canSet then
				v.keyType = i_type.keyType

				if i_type.name then
					v.params = {
						name = i_type.name
					}
				end

				return true
			else
				local errorMsg = "该键不可以自定义设置"

				return false, errorMsg
			end
		end
	end

	local newInfo = {}
	local keyName = {}

	for _, k in ipairs(key) do
		for _, v in ipairs(self.keyInfos) do
			if #v.pressKey == 1 and v.pressKey[1] == k then
				table.insert(keyName, v.keyName)
			end
		end
	end

	if #keyName > 0 then
		newInfo.id = #self.keyInfos + 1

		for i = 1, #keyName do
			if i == 1 then
				newInfo.keyName = keyName[i]
			else
				newInfo.keyName = newInfo.keyName .. "+" .. keyName[i]
			end
		end

		print("newInfo.keyName", newInfo.keyName)

		newInfo.pressKey = clone(key)
		newInfo.isKeybord = true
		newInfo.canSet = true
		newInfo.keyType = i_type.keyType

		if i_type.name then
			newInfo.params = {
				name = i_type.name
			}
		end

		table.insert(self.keyInfos, newInfo)

		return true
	end

	local errorMsg = "该键不可以自定义设置"

	return false
end

function hotKey:isCanSet()
	local isIn = true

	for _, v2 in ipairs(key) do
		if not self:iskeyInList(v2, v.pressKey) then
			isIn = false
		end
	end
end

function hotKey:getInfo(id)
	local i_type = self:getType(id)

	for _, v in ipairs(self.keyInfos) do
		if v.keyType == i_type.keyType and (not i_type.name or v.params and v.params.name == i_type.name) then
			return v
		end
	end
end

function hotKey:getType(id)
	for i, v in ipairs(self:getHotKeySet()) do
		if i == id then
			return v
		end
	end
end

function hotKey:isTrigger(keyCode, pressed)
	local key_count = 0
	local triggerInfo = nil

	for _, info in ipairs(self.keyInfos) do
		if self:iskeyInList(keyCode, info.pressKey) then
			local isFixed = true
			local i_count = 0

			for _, v in ipairs(info.pressKey) do
				if not self:iskeyInList(v, pressed) then
					isFixed = false

					break
				end

				i_count = i_count + 1
			end

			if isFixed then
				if key_count < i_count then
					triggerInfo = info
				end

				key_count = i_count
			end
		end
	end

	return triggerInfo
end

function hotKey:iskeyInList(keyCode, pressed)
	for _, v in ipairs(pressed) do
		if v == keyCode then
			return true
		end
	end

	return false
end

function hotKey:loadMagicHotKey(playerName)
	for _, magic in pairs(g_data.player.magicList) do
		if magic.key then
			for _, v in ipairs(self.keyInfos) do
				local key_id = nil

				if magic.key > 48 and magic.key < 57 then
					key_id = magic.key - 49 + 6
				elseif magic.key > 64 and magic.key < 73 then
					key_id = magic.key - 65 + 18
				end

				if v.id == key_id then
					self:setMagicHotKey(key_id, magic.magicId)
				end
			end
		end
	end
end

function hotKey:setMagicHotKey(keyid, magicId)
	for _, info in ipairs(self.keyInfos) do
		if info.params and info.params.magicId == magicId then
			info.keyType = nil
			info.params = nil

			net.send({
				CM_MAGICKEYCHANGE,
				param = 0,
				recog = magicId
			})
		end
	end

	for _, info in ipairs(self.keyInfos) do
		if info.id == keyid then
			info.keyType = "skill"
			info.params = {
				magicId = magicId
			}
			local keyCode = nil

			if keyid >= 6 and keyid <= 13 then
				keyCode = keyid - 6 + 49
			elseif keyid >= 18 and keyid <= 25 then
				keyCode = keyid - 18 + 65
			end

			net.send({
				CM_MAGICKEYCHANGE,
				recog = magicId,
				param = keyCode
			})

			break
		end
	end
end

function hotKey:magicIsHotKey(magicId)
	for _, info in ipairs(self.keyInfos) do
		if info.params and info.params.magicId == magicId then
			return true, info.id
		end
	end

	return false
end

function hotKey:getMagicOfKey(keyid)
	for _, info in ipairs(self.keyInfos) do
		if info.id == keyid and info.keyType == "skill" and info.params then
			return info.params.magicId
		end
	end
end

function hotKey:getSkillHotKey()
	local magicHotKeys = {}

	for i = 6, 13 do
		local temp = {
			keyId = i,
			magicId = self:getMagicOfKey(i)
		}

		table.insert(magicHotKeys, temp)
	end

	for i = 18, 25 do
		local temp = {
			keyId = i,
			magicId = self:getMagicOfKey(i)
		}

		table.insert(magicHotKeys, temp)
	end

	return magicHotKeys
end

return hotKey
