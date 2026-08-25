GuideAlways = {
	"firstLogin"
}

function main(evt)
	if evt == "firstLogin" then
		print("globalEvent firstLogin")
		mod.newbee(evt)
	end
end
