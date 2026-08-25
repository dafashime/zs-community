local config = {
	{
		key = "infoBar",
		name = "信息栏",
		class = "infoBar",
		banRemove = true,
		desc = "显示等级、金币、背包负重、穿戴负重、网络、时间、电池、坐标信息",
		fixedX = display.cx,
		fixedY = display.height - 14.5
	},
	{
		key = "btnMode",
		name = "攻击模式",
		class = "btnFixed",
		banRemove = true,
		fixedX = 18,
		z = 12,
		desc = "切换攻击模式",
		fixedY = display.height - 64
	},
	{
		key = "btnDiy",
		name = "布局",
		class = "btnFixed",
		banRemove = true,
		fixedX = 18,
		z = 99,
		desc = "打开布局面板",
		fixedY = display.height - 139
	},
	{
		key = "btnPet",
		name = "下属",
		class = "btnFixed",
		fixedX = 18,
		desc = "切换下属休息、攻击状态",
		fixedY = display.height - 214
	},
	{
		key = "btnMap",
		name = "小地图",
		class = "btnFixed",
		banRemove = true,
		desc = "打开小地图",
		fixedX = display.width - 17,
		fixedY = display.height - 64
	},
	{
		key = "btnExit",
		name = "退出",
		class = "btnFixed",
		banRemove = true,
		desc = "返回选择人物界面",
		fixedX = display.width - 17,
		fixedY = display.height - 139
	},
	{
		key = "rocker",
		name = "双摇杆",
		class = "rocker",
		z = 5,
		desc = "控制走路/跑步的虚拟摇杆, 小摇杆为走, 大摇杆为跑。"
	},
	{
		key = "bottom",
		name = "底部信息",
		class = "bottom",
		banRemove = true,
		fixedY = 14,
		desc = "显示地图坐标、经验值、天气。",
		fixedX = display.cx
	},
	{
		btntype = "normal",
		key = "btnHide",
		class = "btnMove",
		name = "显示/隐藏",
		z = 12,
		desc = "显示/隐藏 主操作区域, 便于攻击远程怪"
	},
	{
		key = "hp",
		name = "血量信息",
		class = "hp",
		banRemove = true,
		fixedY = 69,
		desc = "血球展示以及血量、魔法值详情, 点击可打开选择面板界面"
	},
	{
		key = "chat",
		name = "聊天框",
		class = "chat",
		desc = "简易聊天框, 可预览、发送信息."
	},
	{
		btntype = "normal",
		key = "btnChat",
		class = "btnMove",
		name = "聊天按钮",
		desc = "打开聊天框"
	},
	{
		btntype = "normal",
		key = "btnVoice",
		class = "btnMove",
		name = "语音",
		desc = "快捷语音按钮, 按住说话!"
	},
	{
		btntype = "normal",
		key = "btnVoiceJIT",
		class = "btnMove",
		name = "实时语音",
		desc = "实时语音控制按钮, 指挥模式控制上/下麦, 自由模式下按住说话"
	},
	{
		btntype = "normal",
		key = "btnGroup",
		class = "btnMove",
		name = "快速组队",
		desc = "快速组队。"
	},
	{
		key = "lock",
		name = "控制器",
		class = "lock",
		banRemove = true,
		fixedX = 21,
		desc = "锁定/攻击/技能的开关控制器."
	},
	{
		btntype = "base",
		key = "btnAttack",
		class = "btnMove",
		name = "普通攻击",
		btnid = "attack",
		desc = "自动攻击屏幕内的怪物。"
	},
	{
		btntype = "normal",
		key = "btnAutoRat",
		class = "btnMove",
		name = "挂机",
		desc = "自动攻击视野范围内的怪物，'设置－辅助'页面可配置挂机行为。挂机过程中使用摇杆将自动停止挂机"
	},
	{
		btntype = "base",
		key = "btnBackHome",
		class = "btnMove",
		name = "回城",
		btnid = "back",
		desc = "回到距离最近的城市"
	},
	{
		btntype = "base",
		key = "btnLock",
		class = "btnMove",
		name = "自动锁定",
		btnid = "lock",
		desc = "自动锁定屏幕内的人物、怪物。"
	},
	{
		btntype = "base",
		key = "btnShift",
		class = "btnMove",
		name = "强制攻击",
		btnid = "shift",
		desc = "强制往触摸屏幕的方向攻击"
	},
	{
		btntype = "base",
		key = "btnWa",
		class = "btnMove",
		name = "挖取",
		btnid = "wa",
		desc = "往怪物身上挖东西"
	},
	{
		btntype = "setting",
		key = "btnFullname",
		class = "btnMove",
		name = "全屏显名",
		btnid = "allName",
		desc = "显示屏幕上的人物、怪物名称"
	},
	{
		btntype = "setting",
		key = "btnOnlyname",
		class = "btnMove",
		name = "挖取",
		btnid = "onlyName",
		desc = "只显示屏幕上人物的名字, 隐藏行会、封号"
	},
	{
		btntype = "setting",
		key = "btnSoundEnable",
		class = "btnMove",
		name = "音效",
		btnid = "sound",
		desc = "打开/关闭 游戏音效"
	},
	{
		btntype = "setting",
		key = "btnTouchRun",
		class = "btnMove",
		name = "触屏跑步",
		btnid = "touchRun",
		desc = "决定于点屏幕是跑步还是走路."
	},
	{
		btntype = "setting",
		key = "btnAutoAllSpace",
		class = "btnMove",
		job = 0,
		btnid = "autoAllSpace",
		name = "刀刀刺杀",
		desc = "刀刀刺杀, 仅限于战士有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoSpace",
		class = "btnMove",
		job = 0,
		btnid = "autoSpace",
		name = "隔位刺杀",
		desc = "自动隔位刺杀, 仅限于战士有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoWide",
		class = "btnMove",
		job = 0,
		btnid = "autoWide",
		name = "智能半月",
		desc = "自动开启/关闭半月弯刀, 仅限于战士有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoFire",
		class = "btnMove",
		job = 0,
		btnid = "autoFire",
		name = "自动烈火",
		desc = "自动烈火, 仅限于战士有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoDun",
		class = "btnMove",
		job = 1,
		btnid = "autoDun",
		name = "自动魔法盾",
		desc = "自动魔法盾,  仅限于法师有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoInvisible",
		class = "btnMove",
		job = 2,
		btnid = "autoInvisible",
		name = "自动隐身",
		desc = "自动隐身, 仅限于道士有效。"
	},
	{
		btntype = "setting",
		key = "btnAutoSkill",
		class = "btnMove",
		name = "自动技能",
		btnid = "autoSkill",
		desc = "打开/关闭 自动技能"
	},
	{
		btntype = "panel",
		key = "btnPanelBag",
		class = "btnMove",
		name = "背包",
		btnid = "bag",
		desc = "打开背包面板"
	},
	{
		btntype = "panel",
		key = "btnPanelEquip",
		class = "btnMove",
		name = "装备",
		btnid = "equip",
		desc = "打开装备面板"
	},
	{
		btntype = "panel",
		key = "btnPanelSkill",
		class = "btnMove",
		name = "技能",
		btnid = "skill",
		desc = "打开技能面板"
	},
	{
		btntype = "panel",
		key = "btnPanelDeal",
		class = "btnMove",
		name = "交易",
		btnid = "deal",
		desc = "实时玩家交易"
	},
	{
		btntype = "panel",
		key = "btnPanelGroup",
		class = "btnMove",
		name = "组队",
		btnid = "group",
		desc = "打开组队面板"
	},
	{
		btntype = "panel",
		key = "btnPanelFriend",
		class = "btnMove",
		name = "好友",
		btnid = "relation",
		desc = "打开好友面板"
	},
	{
		btntype = "panel",
		key = "btnPanelGuild",
		class = "btnMove",
		name = "行会",
		btnid = "guild",
		desc = "打开行会面板"
	},
	{
		btntype = "panel",
		key = "btnPanelTop",
		class = "btnMove",
		name = "排行",
		btnid = "top",
		desc = "打开排行面板"
	},
	{
		btntype = "panel",
		key = "btnPanelShop",
		class = "btnMove",
		name = "商城",
		btnid = "shop",
		desc = "打开商场面板"
	},
	{
		btntype = "panel",
		key = "btnPanelStall",
		class = "btnMove",
		name = "摆摊",
		btnid = "stall",
		desc = "打开摆摊面板"
	},
	{
		btntype = "panel",
		key = "btnPanelMail",
		class = "btnMove",
		name = "邮件",
		btnid = "mail",
		desc = "打开邮件面板"
	},
	{
		btntype = "panel",
		key = "btnPanelSetting",
		class = "btnMove",
		name = "设置",
		btnid = "setting",
		desc = "打开设置面板"
	},
	{
		btntype = "prop",
		key = "btnPropHongyao",
		class = "btnMove",
		name = "红药",
		btnid = "hongyao",
		desc = "快捷道具使用按钮, 支持: 金创药(小量), 金创药(中量), 强效金创药",
		use = {
			"金创药(小量)",
			"金创药中量(赠)",
			"金创药(中量)",
			"强效金创药(赠)",
			"强效金创药"
		}
	},
	{
		btntype = "prop",
		key = "btnPropLanyao",
		class = "btnMove",
		name = "蓝药",
		btnid = "lanyao",
		desc = "快捷道具使用按钮, 支持: 魔法药(小量), 魔法药(中量), 强效魔法药",
		use = {
			"魔法药(小量)",
			"魔法药中量(赠)",
			"魔法药(中量)",
			"强效魔法药(赠)",
			"强效魔法药"
		}
	},
	{
		btntype = "prop",
		key = "btnPropShunhui",
		class = "btnMove",
		name = "瞬回药品",
		btnid = "shunhui",
		desc = "快捷道具使用按钮, 支持: 太阳水, 强效太阳水, 万年雪霜, 疗伤药",
		use = {
			"太阳水",
			"强效太阳水",
			"万年雪霜",
			"疗伤药"
		}
	},
	{
		btntype = "prop",
		key = "btnPropSuiji",
		class = "btnMove",
		name = "随机传送卷",
		btnid = "suiji",
		desc = "快捷道具使用按钮, 支持: 随机传送卷",
		use = {
			"随机传送卷"
		}
	},
	{
		btntype = "prop",
		key = "btnPropDilao",
		class = "btnMove",
		name = "地牢逃脱卷",
		btnid = "dilao",
		desc = "快捷道具使用按钮, 支持: 地牢逃脱卷",
		use = {
			"地牢逃脱卷"
		}
	},
	{
		btntype = "prop",
		key = "btnPropHuicheng",
		class = "btnMove",
		name = "回城卷",
		btnid = "huicheng",
		desc = "快捷道具使用按钮, 支持: 回城卷",
		use = {
			"回城卷"
		}
	},
	{
		btntype = "prop",
		key = "btnPropHanghui",
		class = "btnMove",
		name = "行会回城卷",
		btnid = "hanghui",
		desc = "快捷道具使用按钮, 支持: 行会回城卷",
		use = {
			"行会回城卷"
		}
	},
	{
		btntype = "prop",
		key = "btnPropZhufuyou",
		class = "btnMove",
		name = "祝福油",
		btnid = "zhufuyou",
		desc = "快捷道具使用按钮, 支持: 祝福油",
		use = {
			"祝福油"
		}
	},
	{
		btntype = "prop",
		key = "btnPropMengzhong",
		class = "btnMove",
		name = "盟重传送石",
		btnid = "mengzhong",
		desc = "快捷道具使用按钮, 支持: 盟重传送石",
		use = {
			"盟重传送石(赠)",
			"盟重传送石"
		}
	},
	{
		btntype = "prop",
		key = "btnPropBiqi",
		class = "btnMove",
		name = "比奇传送石",
		btnid = "biqi",
		desc = "快捷道具使用按钮, 支持: 比奇传送石",
		use = {
			"比奇传送石(赠)",
			"比奇传送石"
		}
	},
	{
		btntype = "prop",
		key = "btnPropSuijishi",
		class = "btnMove",
		name = "随机传送石",
		btnid = "suijishi",
		desc = "快捷道具使用按钮, 支持: 随机传送石",
		use = {
			"随机传送石"
		}
	},
	{
		btntype = "cmd",
		key = "btnCmdChuansong",
		class = "btnMove",
		name = "@传送",
		btnid = "chuansong",
		desc = "传送口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdQianlichuanyin",
		class = "btnMove",
		name = "@千里传音",
		btnid = "qianlichuanyin",
		desc = "千里传音口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdShuaxinbeibao",
		class = "btnMove",
		name = "@刷新背包",
		btnid = "shuaxinbeibao",
		desc = "刷新背包口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdJujuesiliao",
		class = "btnMove",
		name = "@拒绝私聊",
		btnid = "jujuesiliao",
		desc = "拒绝私聊口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdJinzhijiaoyi",
		class = "btnMove",
		name = "@禁止交易",
		btnid = "jinzhijiaoyi",
		desc = "禁止交易口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdShituchuansong",
		class = "btnMove",
		name = "@师徒传送",
		btnid = "shituchuansong",
		desc = "师徒传送口令"
	},
	{
		btntype = "cmd",
		key = "btnCmdFuqichuansong",
		class = "btnMove",
		name = "@夫妻传送",
		btnid = "fuqichuansong",
		desc = "夫妻传送口令"
	},
	{
		btntype = "skill",
		key = "btnSkillTemp",
		class = "btnMove",
		name = "技能"
	},
	{
		btntype = "hero",
		key = "btnHeroCall",
		class = "btnMove",
		name = "召唤英雄",
		btnid = "call",
		desc = "召唤一个英雄"
	},
	{
		btntype = "hero",
		key = "btnHeroBag",
		class = "btnMove",
		name = "英雄背包",
		btnid = "bag",
		desc = "打开/关闭英雄背包"
	},
	{
		btntype = "hero",
		key = "btnHeroEquip",
		class = "btnMove",
		name = "状态",
		btnid = "equip",
		desc = "打开英雄状态信息"
	},
	{
		btntype = "hero",
		key = "btnHeroSkill",
		class = "btnMove",
		name = "合击",
		btnid = "skill",
		desc = "释放合击技能"
	},
	{
		btntype = "hero",
		key = "btnHeroMode",
		class = "btnMove",
		name = "模式",
		btnid = "mode",
		desc = "切换英雄模式"
	},
	{
		btntype = "hero",
		key = "btnHeroGuard",
		class = "btnMove",
		name = "英雄守护",
		btnid = "guard",
		desc = "英雄守护在一个坐标区域内打怪"
	},
	{
		btntype = "hero",
		key = "btnHeroLock",
		class = "btnMove",
		name = "英雄锁定",
		btnid = "lock",
		desc = "英雄锁定一个目标"
	},
	{
		btntype = "custom",
		key = "btnCustom1",
		class = "btnMove",
		name = "",
		id = 1,
		btnid = "btnCustom1",
		desc = ""
	},
	{
		btntype = "custom",
		key = "btnCustom2",
		class = "btnMove",
		name = "",
		id = 2,
		btnid = "btnCustom2",
		desc = ""
	},
	{
		btntype = "custom",
		key = "btnCustom3",
		class = "btnMove",
		name = "",
		id = 3,
		btnid = "btnCustom3",
		desc = ""
	},
	{
		btntype = "custom",
		key = "btnCustom4",
		class = "btnMove",
		name = "",
		id = 4,
		btnid = "btnCustom4",
		desc = ""
	},
	{
		btntype = "custom",
		key = "btnCustom5",
		class = "btnMove",
		name = "",
		id = 5,
		btnid = "btnCustom5",
		desc = ""
	},
	{
		btntype = "custom",
		key = "btnCustom6",
		class = "btnMove",
		name = "",
		id = 6,
		btnid = "btnCustom6",
		desc = ""
	}
}

if VERSION_REVIEW then
	for i = #config, 1, -1 do
		if checkExist(config[i].key, "btnAutoRat", "btnHelper", "btnGroup", "btnPanelStall", "btnPanelMail") then
			table.remove(config, i)
		end
	end
end

local default = {
	{
		key = "infoBar"
	},
	{
		key = "btnMode"
	},
	{
		key = "btnPet"
	},
	{
		key = "btnDiy"
	},
	{
		key = "btnMap"
	},
	{
		key = "btnExit"
	},
	{
		key = "rocker",
		x = 150,
		y = 150
	},
	{
		key = "bottom"
	},
	{
		key = "hp",
		x = display.cx - 185
	},
	{
		y = 85,
		key = "chat",
		x = display.cx + 60
	},
	{
		y = 144,
		key = "btnChat",
		x = display.cx - 110
	},
	{
		key = "lock",
		y = 310
	},
	{
		y = 180,
		key = "btnPanelEquip",
		x = display.cx + 60 - 120
	},
	{
		y = 180,
		key = "btnPanelBag",
		x = display.cx + 60 - 40
	},
	{
		y = 180,
		key = "btnPanelSkill",
		x = display.cx + 60 + 40
	},
	{
		y = 180,
		key = "btnBackHome",
		x = display.cx + 60 + 120
	},
	{
		key = "btnAttack",
		btnpos = "1-1"
	},
	{
		key = "btnLock",
		btnpos = "1-2"
	},
	{
		key = "btnShift",
		btnpos = "1-3"
	},
	{
		key = "btnPropHongyao",
		btnpos = "2-1"
	},
	{
		key = "btnPropLanyao",
		btnpos = "2-2"
	},
	{
		key = "btnPropShunhui",
		btnpos = "2-3"
	}
}
local default_pc = {
	{
		y = 200,
		key = "btnCustom1",
		x = display.cx + 50 - 150
	},
	{
		y = 200,
		key = "btnCustom2",
		x = display.cx + 50 - 90
	},
	{
		y = 200,
		key = "btnCustom3",
		x = display.cx + 50 - 30
	},
	{
		y = 200,
		key = "btnCustom4",
		x = display.cx + 50 + 30
	},
	{
		y = 200,
		key = "btnCustom5",
		x = display.cx + 50 + 90
	},
	{
		y = 200,
		key = "btnCustom6",
		x = display.cx + 50 + 150
	}
}

local function getData(key)
	for i, v in ipairs(default) do
		if v.key == key then
			return v
		end
	end
end

local function getConfig(data)
	local key = data.key2 or data.key

	for i, v in ipairs(config) do
		if v.key == key then
			return v
		end
	end
end

return {
	config = config,
	default = default,
	getData = getData,
	getConfig = getConfig,
	default_pc = default_pc
}
