#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.1"

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
	RegConsoleCmd("sm_kill", PlayerSuicide, "玩家自杀.");
}

public Action PlayerSuicide(int client, int args)
{
	if (IsPlayerAlive(client)) {
		ForcePlayerSuicide(client);
		PrintToChatAll("\x03%N\x05自杀了.", client);
	}

	return Plugin_Continue;
}
