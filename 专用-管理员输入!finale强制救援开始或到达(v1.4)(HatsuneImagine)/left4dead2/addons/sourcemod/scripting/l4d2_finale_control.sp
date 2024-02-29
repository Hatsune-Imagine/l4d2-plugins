#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.4"

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
	description = "Manually force the finale to start or force the rescue to arrive.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_finale", CmdFinale, ADMFLAG_ROOT, "管理员强制救援开始或到达.");
	ImplodeStrings(scriptUnlockFinale, sizeof(scriptUnlockFinale), "\n", scriptUnlockFinaleBuffer, sizeof(scriptUnlockFinaleBuffer));
	ImplodeStrings(scriptUnblockRescue, sizeof(scriptUnblockRescue), "\n", scriptUnblockRescueBuffer, sizeof(scriptUnblockRescueBuffer));
	LoadTranslations("l4d2_finale_control.phrases");
}

public Action CmdFinale(int client, int args)
{
	if (args < 1)
	{
		char title[64];
		char item1[64];
		char item2[64];
		// char item3[64];
		Format(title, sizeof(title), "%T", "menu_title", client);
		Format(item1, sizeof(item1), "%T", "finale_start", client);
		Format(item2, sizeof(item2), "%T", "finale_rescue", client);
		// Format(item3, sizeof(item3), "%T", "finale_escape", client);

		Menu menu = new Menu(MenuHandler_Finale);
		menu.SetTitle(title);
		menu.AddItem("1", item1);
		menu.AddItem("2", item2);
		// menu.AddItem("3", item3);
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		char buffer[16];
		GetCmdArg(1, buffer, sizeof(buffer));

		if (StrEqual(buffer, "start"))
			StartFinale(client);
		else if (StrEqual(buffer, "rescue"))
			TriggerRescue(client);
		else if (StrEqual(buffer, "escape"))
			TriggerEscape(client);
		else
			ReplyToCommand(client, "[SM] Usage: sm_finale <action: start | rescue | escape>");
	}

	return Plugin_Continue;
}

int MenuHandler_Finale(Menu menu, MenuAction action, int client, int param)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;

		case MenuAction_Select:
		{
			char item[2];
			menu.GetItem(param, item, sizeof(item));
			switch (item[0])
			{
				case '1':
					StartFinale(client);
				case '2':
					TriggerRescue(client);
				// case '3':
				// 	TriggerEscape(client);
				default:
					delete menu;
			}
		}
	}

	return 0;
}

void StartFinale(int client)
{
	DoMapSpecificConfigsPre();

	int finale = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(finale))
	{
		ReplyToCommand(client, "%t...", "finale_start");

		int eventProxy = FindEntityByClassname(-1, "info_game_event_proxy");
		if (IsValidEntity(eventProxy))
			AcceptEntityInput(eventProxy, "Kill");

		UnlockFinaleNav();
		AcceptEntityInput(finale, "ForceFinaleStart");
	}

	DoMapSpecificConfigsPost();
}

void TriggerRescue(int client)
{
	int finale = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(finale))
	{
		StartFinale(client);
		ReplyToCommand(client, "%t...", "finale_rescue");

		int entity;
		char targetName[64];
		while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "relay_car_ready") || 
				StrEqual(targetName, "relay_start_heli") || 
				StrEqual(targetName, "helicopter_land_relay")
			)
				AcceptEntityInput(entity, "Trigger");
		}

		UnblockRescueVehicleNav();
		AcceptEntityInput(finale, "FinaleEscapeStarted");
	}
}

// Limited Use
void TriggerEscape(int client)
{
	int finale = FindEntityByClassname(-1, "trigger_finale");
	if (IsValidEntity(finale))
	{
		TriggerRescue(client);
		ReplyToCommand(client, "%t...", "finale_escape");

		int entity;
		char targetName[64];
		while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "relay_car_escape") || 
				StrEqual(targetName, "escape_left_relay") || 
				StrEqual(targetName, "escape_right_relay") || 
				StrEqual(targetName, "escape_relay") || 
				StrEqual(targetName, "relay_leave_boat") || 
				StrEqual(targetName, "relay_leave_heli") || 
				StrEqual(targetName, "helicopter_continue_relay") || 
				StrEqual(targetName, "helicopter_takeoff_relay") || 
				StrEqual(targetName, "generator_final_button_relay") || 
				StrEqual(targetName, "relay_outro_start") || 
				StrEqual(targetName, "relay_escape_ends") || 
				StrEqual(targetName, "exit_relay02")
			)
				AcceptEntityInput(entity, "Trigger");
		}
	}
}

void DoMapSpecificConfigsPre()
{
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
			if (StrEqual(targetName, "stadium_entrance_door_relay"))
			{
				AcceptEntityInput(entity, "Kill");
				break;
			}
		}
	}
	else if (StrEqual(currentMapName, "c6m3_port"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "func_brush")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "elevator_clip_brush"))
			{
				AcceptEntityInput(entity, "Kill");
				break;
			}
		}
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "trigger_push")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "elevator_push"))
			{
				AcceptEntityInput(entity, "Kill");
				break;
			}
		}
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "generator_elevator_trigger"))
			{
				AcceptEntityInput(entity, "Kill");
				break;
			}
		}
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "func_button")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "generator_elevator_button"))
			{
				AcceptEntityInput(entity, "Unlock");
				break;
			}
		}
	}
	else if (StrEqual(currentMapName, "c7m3_port"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "point_template")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
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
			//finale_start_button/finale_start_button1/finale_start_button2
			if (StrContains(targetName, "finale_start_button") != -1)
			{
				AcceptEntityInput(entity, "Unlock");
			}
		}
	}
	else if (StrEqual(currentMapName, "c8m5_rooftop"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "point_template")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
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
		while ((entity = FindEntityByClassname(entity, "func_button_timed")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "finaleswitch_initial"))
			{
				AcceptEntityInput(entity, "Unlock");
				break;
			}
		}
	}
	else if (StrEqual(currentMapName, "c14m2_lighthouse"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "func_brush")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "lookout_clip"))
			{
				AcceptEntityInput(entity, "Kill");
				break;
			}
		}
	}
}

void DoMapSpecificConfigsPost()
{
	int entity;
	char targetName[64];
	char currentMapName[64];
	GetCurrentMap(currentMapName, sizeof(currentMapName));
	if (StrEqual(currentMapName, "c3m4_plantation"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
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
			if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
				AcceptEntityInput(entity, "Kill");
		}
	}
	else if (StrEqual(currentMapName, "c9m2_lots"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
				AcceptEntityInput(entity, "Kill");
		}
	}
	else if (StrEqual(currentMapName, "c12m5_cornfield"))
	{
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, "env_physics_blocker")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
			if (StrEqual(targetName, "anv_mapfixes_point_of_no_return") || StrEqual(targetName, "community_update_point_of_no_return"))
				AcceptEntityInput(entity, "Kill");
		}
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
