#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks>

#define VERSION "1.0"

int commandGodFlags;

public Plugin myinfo = 
{
	name = "L4D2 Round Start Setup",
	author = "HatsuneImagine",
	description = "Make players in god mode and infinite ammo at round start.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	HookEvent("round_start", RoundStart_Event);
	commandGodFlags = GetCommandFlags("god");
}

void RoundStart_Event(Event event, const char[] name, bool dontBroadcast) 
{
	SetCommandFlags("god", commandGodFlags & ~FCVAR_NOTIFY);
	SetConVarInt(FindConVar("god"), 1);
	SetCommandFlags("god", commandGodFlags);
	SetConVarInt(FindConVar("sv_infinite_ammo"), 1);
}

public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	SetCommandFlags("god", commandGodFlags & ~FCVAR_NOTIFY);
	ResetConVar(FindConVar("god"));
	SetCommandFlags("god", commandGodFlags);
	ResetConVar(FindConVar("sv_infinite_ammo"));

	return Plugin_Continue;
}
