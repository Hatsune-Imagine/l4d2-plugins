#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.1"

char scriptUnlockFinaleBuffer[256], scriptUnblockRescueBuffer[256];
char scriptUnlockFinale[][] =
{
	"NAV_FINALE <- 64",
	"",
	"local table = {};",
	"NavMesh.GetAllAreas(table);",
	"",
	"foreach (area in table) {",
	"	if (!area.HasSpawnAttributes(NAV_FINALE)) {",
	"		area.SetSpawnAttributes(NAV_FINALE);",
	"	}",
	"}"
};
char scriptUnblockRescue[][] =
{
	"NavMesh.UnblockRescueVehicleNav();"
};

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
	ImplodeStrings(scriptUnlockFinale, sizeof(scriptUnlockFinale), "\n", scriptUnlockFinaleBuffer, sizeof(scriptUnlockFinaleBuffer));
	ImplodeStrings(scriptUnblockRescue, sizeof(scriptUnblockRescue), "\n", scriptUnblockRescueBuffer, sizeof(scriptUnblockRescueBuffer));
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
		ReplyToCommand(client, "Force Finale Start...");

		int entity;
		char targetName[64];
		char currentMapName[64];
		GetCurrentMap(currentMapName, sizeof(currentMapName));
		if (StrEqual(currentMapName, "c2m5_concert"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "stadium_entrance_door_relay"))
					AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(currentMapName, "c3m4_plantation"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
					AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(currentMapName, "c4m5_milltown_escape"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
					AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(currentMapName, "c7m3_port"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "point_template")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "door_spawner"))
				{
					AcceptEntityInput(entity, "Kill");
					break;
				}
			}

			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "func_button_timed")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrContains(targetName, "finale_start_button") != -1)
					AcceptEntityInput(entity, "Unlock");
			}
		}
		else if (StrEqual(currentMapName, "c8m5_rooftop"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "point_template")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "rooftop_playerclip_template"))
				{
					AcceptEntityInput(entity, "Kill");
					break;
				}
			}

			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "func_button")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "radio_button"))
				{
					AcceptEntityInput(entity, "Unlock");
					break;
				}
			}
		}
		else if (StrEqual(currentMapName, "c9m2_lots"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
					AcceptEntityInput(entity, "Kill");
			}

			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "func_button_timed")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "finaleswitch_initial"))
				{
					AcceptEntityInput(entity, "Unlock");
					break;
				}
			}
		}
		else if (StrEqual(currentMapName, "c12m5_cornfield"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
					AcceptEntityInput(entity, "Kill");
			}
		}
		else if (StrEqual(currentMapName, "c14m2_lighthouse"))
		{
			entity = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "func_brush")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
				StringToLowerCase(targetName);

				if (StrEqual(targetName, "lookout_clip"))
				{
					AcceptEntityInput(entity, "Kill");
					break;
				}
			}
		}

		int entInfoGameEventProxy = FindEntityByClassname(-1, "info_game_event_proxy");
		if (IsValidEntity(entInfoGameEventProxy))
			AcceptEntityInput(entInfoGameEventProxy, "Kill");

		UnlockFinaleNav();
		AcceptEntityInput(ent, "ForceFinaleStart");
	}
}

void TriggerRescue(int client)
{
	int ent = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(ent))
	{
		StartFinale(client);
		ReplyToCommand(client, "Force Finale Rescue...");

		int entity;
		char targetName[64];
		while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			StringToLowerCase(targetName);

			if (StrEqual(targetName, "relay_car_ready"))
				AcceptEntityInput(entity, "Trigger");
		}

		UnblockRescueVehicleNav();
		AcceptEntityInput(ent, "FinaleEscapeStarted");
	}
}

void UnlockFinaleNav()
{
	int entity = CreateEntityByName("logic_script");
	DispatchSpawn(entity);

	SetVariantString(scriptUnlockFinaleBuffer);
	AcceptEntityInput(entity, "RunScriptCode");
	AcceptEntityInput(entity, "Kill");
}

void UnblockRescueVehicleNav()
{
	int entity = CreateEntityByName("logic_script");
	DispatchSpawn(entity);

	SetVariantString(scriptUnblockRescueBuffer);
	AcceptEntityInput(entity, "RunScriptCode");
	AcceptEntityInput(entity, "Kill");
}

/**
 * Converts the string to lower case.
 *
 * @param input	Input string.
 */
void StringToLowerCase(char[] input)
{
	for (int i = 0; i < strlen(input); i++)
	{
		input[i] = CharToLower(input[i]);
	}
}
