function CreatEnumTable(tbl, index)
	local enumtbl = {}
	local enumindex = index or 0

	for i, v in ipairs(tbl) do
		enumtbl[v] = enumindex + i - 1
	end

	return enumtbl
end

Plugin_type = {
	"kPluginAds",
	"kPluginAnalytics",
	"kPluginIAP",
	"kPluginShare",
	"kPluginUser",
	"kPluginSocial",
	"kPluginPush"
}
Plugin_type = CreatEnumTable(Plugin_type, 1)
AdsResultCode = {
	"kAdsReceived",
	"kAdsShown",
	"kAdsDismissed",
	"kPointsSpendSucceed",
	"kPointsSpendFailed",
	"kNetworkError",
	"kUnknownError",
	"kOfferWallOnPointsChanged"
}
AdsResultCode = CreatEnumTable(AdsResultCode, 0)
AdsPos = {
	"kPosCenter",
	"kPosTop",
	"kPosTopLeft",
	"kPosTopRight",
	"kPosBottom",
	"kPosBottomLeft",
	"kPosBottomRight"
}
AdsPos = CreatEnumTable(AdsPos, 0)
AdsType = {
	"AD_TYPE_BANNER",
	"AD_TYPE_FULLSCREEN",
	"AD_TYPE_MOREAPP",
	"AD_TYPE_OFFERWALL"
}
AdsType = CreatEnumTable(AdsType, 0)
PayResultCode = {
	"kPaySuccess",
	"kPayFail",
	"kPayCancel",
	"kPayNetworkError",
	"kPayProductionInforIncomplete",
	"kPayInitSuccess",
	"kPayInitFail",
	"kPayNowPaying"
}
PayResultCode = CreatEnumTable(PayResultCode, 0)
PushActionResultCode = {
	"kPushReceiveMessage"
}
PushActionResultCode = CreatEnumTable(PushActionResultCode, 0)
ShareResultCode = {
	"kShareSuccess",
	"kShareFail",
	"kShareCancel",
	"kShareNetworkError"
}
ShareResultCode = CreatEnumTable(ShareResultCode, 0)
SocialRetCode = {
	"kScoreSubmitSucceed",
	"kScoreSubmitfail",
	"kAchUnlockSucceed",
	"kAchUnlockFail",
	"kSocialSignInSucceed",
	"kSocialSignInFail",
	"kSocialSignOutSucceed",
	"kSocialSignOutFail"
}
SocialRetCode = CreatEnumTable(SocialRetCode, 1)
UserActionResultCode = {
	"kInitSuccess",
	"kInitFail",
	"kLoginSuccess",
	"kLoginNetworkError",
	"kLoginNoNeed",
	"kLoginFail",
	"kLoginCancel",
	"kLogoutSuccess",
	"kLogoutFail",
	"kPlatformEnter",
	"kPlatformBack",
	"kPausePage",
	"kExitPage",
	"kAntiAddictionQuery",
	"kRealNameRegister",
	"kAccountSwitchSuccess",
	"kAccountSwitchFail"
}
UserActionResultCode = CreatEnumTable(UserActionResultCode, 0)
ToolBarPlace = {
	"kToolBarTopLeft",
	"kToolBarTopRight",
	"kToolBarMidLeft",
	"kToolBarMidRight",
	"kToolBarBottomLeft",
	"kToolBarBottomRight"
}
ToolBarPlace = CreatEnumTable(ToolBarPlace, 1)
