//SourcePawn

/*			Changelog
*	29/08/2014 Version 1.0 – Released.
*	28/12/2016 Version 1.1 – Changed syntax.
*	22/10/2017 Version 1.2 – Fixed jump after vomitjar-boost and after "TakeOverBot" event.
*	08/11/2018 Version 1.2.1 – Fixed incorrect flags initializing; some changes in syntax.
*	25/04/2019 Version 1.2.2 – Command "sm_autobhop" has fixed for localplayer in order to work properly in console.
*	16/11/2019 Version 1.3.2 – At the moment CBasePlayer specific flags (or rather FL_ONGROUND bit) aren't longer fixed, by reason
*							player's jump animation during boost is incorrect (it's must be ACT_RUN_CROUCH_* sequence always!);
*							removed 'm_nWaterLevel' check (we cannot swim in this game anyway) to avoid problems with jumping
*							on some deep water maps.
*	26/05/2023 Version 1.3.3 - Add some restrictions in versus mode and scavenge mode. Players can no longer enable auto bhop in
*							versus mode and scavenge mode now.
*	24/08/2023 Version 1.3.4 - Fixed a bug that players have to enable auto bhop manually after changing the chapter. Using
*							'player_disconnect' event instead of 'OnClientDisconnect()' function.
*	01/01/2024 Version 1.3.5 - Add a cvar to control whether allow players to enable auto bhop in competitive modes.
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define MAXCLIENTS 32
#define PLUGIN_VER "1.3.5"

ConVar cv_autoBhopCompetitive;
bool g_AutoBhop[MAXCLIENTS + 1];

public Plugin myinfo =
{
	name = "Auto Bunny Hop",
	author = "Zakikun, noa1mbot, HatsuneImagine",
	description = "Make Bunny Hop easier.",
	version = PLUGIN_VER,
	url = "https://steamcommunity.com/groups/noa1mbot"
}

//============================================================
//============================================================

public void OnPluginStart()
{
	cv_autoBhopCompetitive = CreateConVar("l4d2_auto_bhop_allow_competitive", "1", "Allow players enable auto bhop in competitive mode.");

	RegConsoleCmd("sm_bh", Cmd_Autobhop);
	RegConsoleCmd("sm_onrb", Cmd_Autobhop);
	RegConsoleCmd("sm_bhop", Cmd_Autobhop);

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

	AutoExecConfig(true, "l4d2_auto_bhop");
}

public Action Cmd_Autobhop(int client, int args)
{
	if (!cv_autoBhopCompetitive.BoolValue && l4d2_gamemode() == 2) {
		ReplyToCommand(client, "对抗模式不可用.");
		return Plugin_Handled;
	}

	if (!cv_autoBhopCompetitive.BoolValue && l4d2_gamemode() == 4) {
		ReplyToCommand(client, "清道夫模式不可用.");
		return Plugin_Handled;
	}

	if (client == 0)
	{
		if (!IsDedicatedServer())
			client = 1;
		else
			return Plugin_Handled;
	}

	if (!IsClientInGame(client))
		return Plugin_Handled;

	g_AutoBhop[client] = !g_AutoBhop[client];

	if (g_AutoBhop[client])
		PrintToChat(client, "\x03已开启\x05自动连跳.");
	else
		PrintToChat(client, "\x03已关闭\x05自动连跳.");

	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (g_AutoBhop[client] && IsPlayerAlive(client))
	{
		if (buttons & IN_JUMP)
		{
			if (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1)
			{
				if (GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					buttons &= ~IN_JUMP;
				}
			}
		}
	}
	return Plugin_Continue;
}

//OnClientDisconnect will fired when changing map, use "player_disconnect" event instead.
void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_AutoBhop[client] = false;
}

int l4d2_gamemode()
{
	char gmode[32];
	GetConVarString(FindConVar("mp_gamemode"), gmode, sizeof(gmode));

	if (StrEqual(gmode, "coop", false) || StrEqual(gmode, "realism", false))
		return 1;
	else if (StrEqual(gmode, "versus", false) || StrEqual(gmode, "teamversus", false))
		return 2;
	if (StrEqual(gmode, "survival", false))
		return 3;
	if (StrEqual(gmode, "scavenge", false) || StrEqual(gmode, "teamscavenge", false))
		return 4;
	else
		return 0;
}