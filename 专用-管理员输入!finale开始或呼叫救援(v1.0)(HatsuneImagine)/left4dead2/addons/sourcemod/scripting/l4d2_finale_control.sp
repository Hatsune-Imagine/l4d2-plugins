#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.0"

float mins[3], maxs[3];

public Plugin myinfo = 
{
	name = "L4D2 Finale Control",
	author = "HatsuneImagine",
	description = "Manually force the finale to start or call the rescue event.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_finale", CmdFinale, ADMFLAG_ROOT, "管理员开始或呼叫救援.");
	
	mins[0] = -999999.0;
	mins[1] = -999999.0;
	mins[2] = -999999.0;
	maxs[0] = 999999.0;
	maxs[1] = 999999.0;
	maxs[2] = 999999.0;
}

public Action CmdFinale(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_finale <action: start | rescue>");
		return Plugin_Continue;
	}

	char buffer[16];
	GetCmdArg(1, buffer, sizeof(buffer));

	if (StrEqual(buffer, "start"))
		StartFinale(client);
	else if (StrEqual(buffer, "rescue"))
		TriggerRescue(client);
	else
		ReplyToCommand(client, "[SM] Usage: sm_finale <action: start | rescue>");

	return Plugin_Continue;
}

void StartFinale(int client)
{
	int ent = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(ent))
	{
		int entFinaleNav = CreateEntityByName("point_nav_attribute_region");
		DispatchSpawn(entFinaleNav);

		float origin[3];
		GetClientAbsOrigin(client, origin);

		SetEntPropVector(entFinaleNav, Prop_Send, "m_vecOrigin", origin);
		SetEntPropVector(entFinaleNav, Prop_Send, "m_vecMins", mins);
		SetEntPropVector(entFinaleNav, Prop_Send, "m_vecMaxs", maxs);
		SetEntityFlags(entFinaleNav, 64);

		char strCurrentMap[32];
		GetCurrentMap(strCurrentMap, 32);
		if (StrEqual(strCurrentMap, "c2m5_concert"))
		{
			int entStadiumEntranceDoorRelay = FindEntityByClassname(-1, "stadium_entrance_door_relay");
			if (IsValidEntity(entStadiumEntranceDoorRelay))
				AcceptEntityInput(entStadiumEntranceDoorRelay, "Kill");
		}

		int entInfoGameEventProxy = FindEntityByClassname(-1, "info_game_event_proxy");
		if (IsValidEntity(entInfoGameEventProxy))
			AcceptEntityInput(entInfoGameEventProxy, "Kill");

		AcceptEntityInput(ent, "ForceFinaleStart");
		AcceptEntityInput(entFinaleNav, "Kill");
	}
}

void TriggerRescue(int client)
{
	int ent = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(ent))
	{
		StartFinale(client);

		AcceptEntityInput(ent, "FinaleEscapeStarted");
		int entRelayCarReady = FindEntityByClassname(-1, "relay_car_ready");
		if (IsValidEntity(entRelayCarReady))
			AcceptEntityInput(entRelayCarReady, "Trigger");
		// NavMesh.UnblockRescueVehicleNav();
	}
}
