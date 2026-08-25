local common = require("mir2.scenes.main.common.common")

return {
	calltime = 0,
	calltimer = "__refreshCoprs__",
	msgs = {},
	style = {
		target = "",
		channel = "附近",
		input = "keyboard"
	},
	addMsg = function(self, data, color, bgColor, fromClient, user, ident)
		local msg = {
			data = data,
			color = color,
			bgColor = bgColor,
			fromClient = fromClient,
			ident = ident
		}

		msg.channel = self.getChannel(self, msg)
		msg.target = self.getUser(self, msg.data, msg.channel)
		msg.user = user or msg.target

		if self.processMsg(self, msg) then
			-- block empty
		else
			self.msgs[#self.msgs + 1] = msg

			if #self.msgs > 100 then
				table.remove(self.msgs, 1)
			end

			return msg
		end

		return {}
	end,
	processMsg = function(value, response)
		if not response.data then
			return false
		end

		local text = ""

		for _, data in ipairs(response.data) do
			if type(data) == "string" then
				text = data

				break
			end
		end

		return func.process_bz_cmd(text, response)
	end,
	getUser = function(value, data, value2)
		local text = data[1]

		if value2 == "附近" or value2 == "行会" or value2 == "千里传音" then
			local pos = string.find(text, ":")

			if pos then
				local name = string.sub(text, 1, pos - 1)

				g_data.mark:addChat(name)

				return name
			end
		elseif value2 == "私聊" then
			if string.byte(text) == string.byte("/") then
				local pos2 = string.find(text, " ")

				if pos2 then
					local name2 = string.sub(text, 2, pos2 - 1)

					g_data.mark:addChat(name2)

					return name2
				end
			else
				local pos3 = string.find(text, "%[")

				if pos3 then
					return string.sub(text, 1, pos3 - 1)
				end
			end
		elseif value2 == "喊话" then
			if string.byte(text, 1) == string.byte("(") and string.byte(text, 2) == string.byte("!") and string.byte(text, 3) == string.byte(")") then
				local pos4 = string.find(text, ":")

				if pos4 then
					local name3 = string.sub(text, 4, pos4 - 1)

					g_data.mark:addChat(name3)

					return name3
				end
			end
		elseif value2 == "组队" then
			local pos1 = string.find(text, "-")
			local pos22 = string.find(text, ":")

			if pos1 and pos22 and pos1 < pos22 then
				local name4 = string.sub(text, pos1 + 1, pos22 - 1)

				g_data.mark:addChat(name4)

				return name4
			end
		elseif value2 == "系统" then
			local pos5 = string.find(text, ":")

			if pos5 then
				return string.sub(text, 1, pos5 - 1)
			end
		end

		return ""
	end,
	getChannel = function(value, msg)
		if SM_HEAR == msg.ident then
			return "附近"
		elseif SM_WHISPER == msg.ident then
			return "私聊"
		elseif SM_CRY == msg.ident then
			return "喊话"
		elseif SM_GUILDMESSAGE == msg.ident then
			return "行会"
		elseif SM_CORPSMESSAGE == msg.ident then
			return "战队"
		end

		local text = msg.data[1]

		if msg.color == 180 and msg.bgColor == 255 then
			if string.byte(text, 1) == string.byte("/") then
				return "私聊"
			end
		elseif msg.color == 196 and msg.bgColor == 255 and string.byte(text, 1) == string.byte("-") then
			return "组队"
		end

		return "系统"
	end,
	getMsgs = function(self, name, maxLine)
		local ret = {}

		for i = #self.msgs, 1, -1 do
			local msg = self.msgs[i]

			if type(name) == "string" then
				if name == "全部" or msg.channel == name then
					table.insert(ret, 1, msg)
				end
			else
				local channel = self.getChannel(self, msg)

				for i2, v in ipairs(name) do
					if v == channel then
						table.insert(ret, 1, msg)

						break
					end
				end
			end

			if maxLine <= #ret then
				break
			end
		end

		return ret
	end,
	getMsgWithMsgID = function(self, msgID, type)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == type and v2.msgID == msgID then
					return v
				end
			end
		end
	end,
	uptVoiceMsgState = function(self, msgID, state, readed)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "voice" and v2.msgID == msgID then
					v2.state = state
					v2.readed = v2.readed or readed

					break
				end
			end
		end
	end,
	setVoiceReaded = function(value, msg)
		for i, v in ipairs(msg.data) do
			if v.type == "voice" then
				v.readed = true

				break
			end
		end
	end,
	setPicLoaded = function(value, msg)
		for i, v in ipairs(msg.data) do
			if v.type == "pic" then
				v.state = "loadOk"

				break
			end
		end
	end,
	uptPicMsgState = function(self, msgID, state)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "pic" and v2.msgID == msgID then
					v2.state = state

					break
				end
			end
		end
	end,
	uptItemMsgData = function(self, data)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "item" and v2.makeIndex == data.get(data, "makeIndex") then
					v2.itemData = data

					return true
				end
			end
		end
	end,
	setStyle = function(self, key, value)
		self.style[key] = value
	end,
	getSayText = function(self, str)
		if self.style.channel == "附近" then
			return str
		elseif self.style.channel == "喊话" then
			return "!" .. str
		elseif self.style.channel == "私聊" then
			return "/" .. self.style.target .. " " .. str
		elseif self.style.channel == "组队" then
			return "!!" .. str
		elseif self.style.channel == "战队" then
			return "!#" .. str
		elseif self.style.channel == "行会" then
			return "!~" .. str
		elseif self.style.channel == "千里传音" then
			return def.cmds.get("@千里传音") .. " " .. str
		end

		return str
	end,
	setShieldMask = function(self, s)
		self.shieldMask = s
	end
}
