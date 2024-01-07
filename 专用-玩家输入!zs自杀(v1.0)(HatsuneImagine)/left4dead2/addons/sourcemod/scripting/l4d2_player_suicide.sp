#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.0"

public Plugin myinfo = 
{
	name = "L4D2 Player Suicide",
	author = "HatsuneImagine",
	description = "Player suicide.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_zs", PlayerSuicide, "玩家自杀.");
	RegConsoleCmd("sm_kl", PlayerSuicide, "玩家自杀.");
}

public Action PlayerSuicide(int client, int args)
{
	if (IsPlayerAlive(client)) {
		ForcePlayerSuicide(client);

		char playerName[32];
		GetClientName(client, playerName, sizeof(playerName));
		PrintToChatAll("\x03%s\x05自杀了.", playerName);
	}

	return Plugin_Continue;
}
