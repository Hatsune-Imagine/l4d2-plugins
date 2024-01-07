#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define VERSION "1.0"

public Plugin myinfo = 
{
	name = "L4D2 Restart Current Map",
	author = "HatsuneImagine",
	description = "Restart current map.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_restart", RestartMap, ADMFLAG_ROOT, "管理员重启当前章节.");
}

public Action RestartMap(int client, int args)
{
	PrintToChatAll("\x03将在10秒后\x05重启当前章节...");
	PrintToChatAll("\x05重启期间黑屏为正常现象, 请耐心等待.");
	CreateTimer(10.0, Timer_RestartMap);

	return Plugin_Continue;
}

Action Timer_RestartMap(Handle timer) {
	char strCurrentMap[32];
	GetCurrentMap(strCurrentMap,32);
	ServerCommand("changelevel %s", strCurrentMap);
	PrintToChatAll("\x03正在重启\x05当前章节...");

	return Plugin_Continue;
}
