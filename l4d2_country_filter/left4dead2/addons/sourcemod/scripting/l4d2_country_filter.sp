#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <geoip>

ConVar cv_blackList;
ConVar cv_whiteList;
char blackList[256][3];
char whiteList[256][3];

public Plugin myinfo = {
	name = "L4D2 Country Filter",
	author = "HatsuneImagine",
	description = "Filter player regions.",
	version = "1.0",
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart() {
	cv_blackList = CreateConVar("l4d2_country_black_list", "", "2位国家码黑名单(,分隔).");
	cv_whiteList = CreateConVar("l4d2_country_white_list", "", "2位国家码白名单(,分隔).");
	HookConVarChange(cv_blackList, ConvarChanged);
	HookConVarChange(cv_whiteList, ConvarChanged);
	AutoExecConfig(true, "l4d2_country_filter");
}

void ConvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	OnConfigsExecuted();
}

public void OnConfigsExecuted() {
	char blackListStr[4096];
	char whiteListStr[4096];
	cv_blackList.GetString(blackListStr, sizeof(blackListStr));
	cv_whiteList.GetString(whiteListStr, sizeof(whiteListStr));
	ExplodeString(blackListStr, ",", blackList, 256, 3);
	ExplodeString(whiteListStr, ",", whiteList, 256, 3);
}

public void OnClientPutInServer(int client) {
	if (IsFakeClient(client)) {
		return;
	}

	char ip[16];
	char ccode[3];
	GetClientIP(client, ip, sizeof(ip));
	if (!GeoipCode2(ip, ccode)) {
		return;
	}
	if (!StrEqual(whiteList[0], "") && !contains(whiteList, ccode)) {
		LogMessage("[l4d2_country_filter] Kicked player [%s]%N.", ccode, client);
		KickClient(client, "Not Available in your region");
	}
	if (!StrEqual(blackList[0], "") && contains(blackList, ccode)) {
		LogMessage("[l4d2_country_filter] Kicked player [%s]%N.", ccode, client);
		KickClient(client, "Not Available in your region");
	}
}

bool contains(char[][] list, char[] countryCode) {
	for (int i = 0; i < 256; i++) {
		if (StrEqual(list[i], countryCode)) {
			return true;
		}
	}
	return false;
}
