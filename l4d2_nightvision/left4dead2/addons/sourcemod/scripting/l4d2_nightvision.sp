/*
 *	v1.1
 *	1:增加打开夜视仪弹出亮度设置菜单,设置减弱加强亮度,也可以手动开启亮度菜单.
 *
 *	v1.0
 *	1:幸存者双击F,感染者单击F,开启关闭夜视仪.
 *	2:聚光灯部分借鉴King_OXO(edited, now have cookie)大佬源码,防止实体溢出删除实体部分感谢little_froy大佬指导和提供借鉴源码.
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

#define	UseTeam2	(1 << 0)
#define UseTeam3	(1 << 1)

ConVar g_cNightVisionMode;

int g_iNightVisionMode;

int IMPULS_FLASHLIGHT = 100;

int g_iBrightness[MAXPLAYERS+1];

int g_iPlayerLight[MAXPLAYERS+1] = {-1, ...};

float g_fPressTime[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "L4D2 Night Vision",
	author = "X光",
	description = "夜视仪",
	version = PLUGIN_VERSION,
	url = "QQ群59046067"
};

public void OnPluginStart()
{
	g_cNightVisionMode = CreateConVar("l4d2_night_vision_mode", "3", "0=关闭, 1=只有幸存者可以使用, 2=只有感染者可以使用, 3=都可以使用.");
	g_cNightVisionMode.AddChangeHook(ConVarChange);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_disconnect", Event_PlayerDisconnect);

	RegConsoleCmd("sm_nv", Cmd_Brightness, "夜视仪亮度菜单");
	RegConsoleCmd("sm_ysy", Cmd_Brightness, "夜视仪亮度菜单");

	// AutoExecConfig(true, "l4d2_nightvision");
}

public void ConVarChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetConVar();
}

void GetConVar()
{
	g_iNightVisionMode = g_cNightVisionMode.IntValue;
}

public void OnConfigsExecuted()
{
	GetConVar();
}

Action Hook_SetTransmit(int entity, int client)
{
	int ref = EntIndexToEntRef(entity);

	if (g_iPlayerLight[client] == ref)
		return Plugin_Continue;

	return Plugin_Handled;
}

void RemoveRef(int& ref)
{
	int entity = EntRefToEntIndex(ref);

	if (entity != -1)
		RemoveEdict(entity);

	ref = -1;
}

void ResetSpriteNormal(int client)
{
	if (g_iPlayerLight[client] != -1)
		RemoveRef(g_iPlayerLight[client]);
}

void SwitchNightVision(int client)
{
	if (g_iPlayerLight[client] == -1)
	{
		int Light = CreateEntityByName("light_dynamic");
		if (IsValidEntity(Light))
		{
			g_iPlayerLight[client] = EntIndexToEntRef(Light);

			DispatchKeyValue(Light, "_light", "255 255 255 255");

			char item[4];
			Format(item, sizeof item, "%d", g_iBrightness[client]);
			DispatchKeyValue(Light, "brightness", item);

			DispatchKeyValueFloat(Light, "spotlight_radius", 32.0);
			DispatchKeyValueFloat(Light, "distance", 750.0);
			DispatchKeyValue(Light, "style", "0");
			DispatchSpawn(Light);
			AcceptEntityInput(Light, "TurnOn");
			SetVariantString("!activator");
			AcceptEntityInput(Light, "SetParent", client);
			TeleportEntity(Light, view_as<float>({0.0, 0.0, 20.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
			SDKHook(Light, SDKHook_SetTransmit, Hook_SetTransmit);
			BrightnessMainMenu(client);
			PrintHintText(client, "夜视仪已开启");
		}
	}
	else
	{
		ResetSpriteNormal(client);
		ClientCommand(client, "slot10");
		PrintHintText(client, "夜视仪已关闭");
	}
}

public void OnClientDisconnect(int client)
{
	ResetSpriteNormal(client);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
		ResetSpriteNormal(i);
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client || !IsClientInGame(client) || IsFakeClient(client))
		return;

	ClientCommand(client, "slot10");
	int team = event.GetInt("team");

	switch (g_iNightVisionMode)
	{
		case 1:
		{
			if (team == 1 || team == 2)
				return;
		}
		case 2:
		{
			if (team == 3)
				return;
		}
		case 3:
			return;
	}

	ResetSpriteNormal(client);
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client || g_iBrightness[client] != 0 || IsFakeClient(client))
		return;

	g_iBrightness[client] = 0;
}

public void OnPlayerRunCmdPre(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if (impulse == IMPULS_FLASHLIGHT)
	{
		if (g_iNightVisionMode & UseTeam2 && GetClientTeam(client) == 2)
		{
			float time = GetEngineTime();
			if(time - g_fPressTime[client] < 0.3)
				SwitchNightVision(client);

			g_fPressTime[client] = time; 
		}
		if (g_iNightVisionMode & UseTeam3 && GetClientTeam(client) == 3)
			SwitchNightVision(client);
	}
}

Action Cmd_Brightness(int client, int args)
{
	if (!client || !IsClientInGame(client) || IsFakeClient(client))
		return Plugin_Handled;

	if (g_iPlayerLight[client] == -1)
	{
		PrintToChat(client, "\x04[提示]\x05夜视仪亮度菜单功能打开\x03失败\x05,夜视仪功能未开启.");
		return Plugin_Handled;
	}

	BrightnessMainMenu(client);
	return Plugin_Handled;
}

void BrightnessMainMenu(int client)
{
	char item[64];
	Menu menu = new Menu(BrightnessHandlerMenu);

	menu.SetTitle("═══夜视仪亮度值[ %d ]═══\n聊天窗口输入 !ysy 打开菜单", g_iBrightness[client] + 4);
	Format(item, sizeof item, "%s", g_iBrightness[client] == -3 ? "已达到最弱亮度" : "减弱夜视仪亮度");
	menu.AddItem("", item);
	Format(item, sizeof item, "%s", g_iBrightness[client] == 3 ? "已达到最强亮度" : "加强夜视仪亮度");
	menu.AddItem("", item);

	menu.ExitButton = true;
	menu.Display(client, 10);
}

int BrightnessHandlerMenu(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client) && g_iPlayerLight[client] != -1)
			{
				if (param2 == 0)
				{
					g_iBrightness[client]--;
					if (g_iBrightness[client] < -3)
					{
						g_iBrightness[client] = -3;
						BrightnessMainMenu(client);
						return 0;
					}
				}
				else
				{
					g_iBrightness[client]++;
					if (g_iBrightness[client] > 3)
					{
						g_iBrightness[client] = 3;
						BrightnessMainMenu(client);
						return 0;
					}
				}
				ResetSpriteNormal(client);
				SwitchNightVision(client);
			}
			else
				PrintToChat(client, "\x04[提示]\x05夜视仪亮度设置已\x03无效\x05,夜视仪功能未开启.");
		}
		case MenuAction_End:
			delete menu;
	}

	return 0;
}