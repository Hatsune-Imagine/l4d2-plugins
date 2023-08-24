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
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define MAXCLIENTS 32
#define PLUGIN_VER "1.3.4"

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
	RegConsoleCmd("sm_bh", Cmd_Autobhop);
	RegConsoleCmd("sm_onrb", Cmd_Autobhop);
	RegConsoleCmd("sm_bhop", Cmd_Autobhop);

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public Action Cmd_Autobhop(int client, int args)
{
	if (client == 0)
	{
		if (!IsDedicatedServer())
			client = 1;
		else
			return Plugin_Handled;
	}

	if (!IsClientInGame(client))
		return Plugin_Handled;

	if(l4d2_gamemode() == 2) {
		ReplyToCommand(client, "对抗模式不可用");
		return Plugin_Handled;
	}

	if(l4d2_gamemode() == 4) {
		ReplyToCommand(client, "清道夫模式不可用");
		return Plugin_Handled;
	}

	g_AutoBhop[client] = !g_AutoBhop[client];

	if (g_AutoBhop[client])
		PrintToChat(client, "\x04[提示]\x03自动连跳开启.");
	else
		PrintToChat(client, "\x04[提示]\x03自动连跳关闭.");

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