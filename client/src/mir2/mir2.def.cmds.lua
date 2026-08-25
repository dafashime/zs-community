local cmds = {
	all = {
		{
			"@千里传音",
			"@传"
		},
		{
			"@传送",
			"@sdgo",
			true,
			"请输入坐标, 注意中间有空格, 例如:333 333"
		},
		{
			"@天地合一",
			"@天地合一"
		},
		{
			"@允许天地合一",
			"@允许天地合一"
		},
		{
			"@允许求婚",
			"@允许求婚"
		},
		{
			"@拒绝求婚",
			"@拒绝求婚"
		},
		{
			"@允许收徒",
			"@允许收徒"
		},
		{
			"@拒绝收徒",
			"@拒绝收徒"
		},
		{
			"@加入门派",
			"@加入门派"
		},
		{
			"@退出门派",
			"@退出门派"
		}
	},
	custom = {
		["卡位恢复"] = "@resetpoint",
		["回城复活"] = "@relive"
	}
}

function cmds.get(key)
	for k, v in pairs(cmds.all) do
		if v[1] == key then
			return v[2]
		end
	end
end

return cmds
