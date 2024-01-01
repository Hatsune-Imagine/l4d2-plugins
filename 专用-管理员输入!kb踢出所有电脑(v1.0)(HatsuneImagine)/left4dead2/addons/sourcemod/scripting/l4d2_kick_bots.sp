#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define VERSION "1.0"

public Plugin myinfo = 
{
	name = "L4D2 Kick All Bots",
	author = "HatsuneImagine",
	description = "Kick all bots.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart() 
{
	RegAdminCmd("sm_kb", KickBots, ADMFLAG_ROOT, "管理员踢出所有电脑.");
}

public Action KickBots(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && GetIdleUserId(i) == 0)
		KickClient(i, "踢出电脑生还者.");

	PrintToChatAll("\x03已踢出\x05所有电脑玩家.");

	return Plugin_Continue;
}

int GetIdleUserId(int client)
{
	if (!HasEntProp(client, Prop_Send, "m_humanSpectatorUserID"))
		return 0;

	return GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
}
