#pragma semicolon 1

#include <sourcemod>

forward void L4D_OnReplaceTank(int tank, int newtank);

#pragma newdecls required

Handle isTankActive;
bool hiddenTankPanel[MAXPLAYERS + 1];
int iTankPassedCount[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "[L4D] Tank Hud",
	author = "ConfoglTeam & Accelerator",
	description = "",
	version = "3.1",
	url = "https://github.com/accelerator74/sp-plugins"
};

public void OnPluginStart()
{
	HookEvent("round_start", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("round_end", Round_Event, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", TankSpawn_Event);
	
	RegConsoleCmd("sm_tankhud", ToggleTankPanel_Cmd, "Toggles the tank panel visibility so other menus can be seen");
	RegConsoleCmd("sm_spechud", ToggleTankPanel_Cmd, "Toggles the tank panel visibility so other menus can be seen");
}

public void Round_Event(Event event, const char[] name, bool dontBroadcast)
{
	delete isTankActive;
}

public void TankSpawn_Event(Event event, const char[] name, bool dontBroadcast)
{
	iTankPassedCount[GetClientOfUserId(event.GetInt("userid"))] = 1;
	if (isTankActive == null)
	{
		for (int i = 1; i <= MaxClients; i++)
			hiddenTankPanel[i] = false;
		
		isTankActive = CreateTimer(0.5, MenuRefresh_Timer, _, TIMER_REPEAT);
	}
}

public void L4D_OnReplaceTank(int tank, int newtank)
{
	if (tank != newtank)
	{
		iTankPassedCount[newtank] = iTankPassedCount[tank] + 1;
		iTankPassedCount[tank] = 0;
	}
}

public Action MenuRefresh_Timer(Handle timer)
{
	int iTankCount;
	int iTankClients[33];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3 && GetZombieClass(i) == 8 && GetTankAlive(i))
		{
			iTankClients[iTankCount] = i;
			iTankCount++;
		}
	}
	
	if (iTankCount < 1)
	{
		isTankActive = null;
		return Plugin_Stop;
	}
	
	char buffer[64];
	Panel menuPanel = new Panel();
	
	// Header
	menuPanel.SetTitle("Tank HUD"); 
	menuPanel.DrawText("\n \n");
	
	for (int j = 0; j < iTankCount; j++)
	{
		// Name
		if (!IsFakeClient(iTankClients[j]))
		{
			GetClientName(iTankClients[j], buffer, sizeof(buffer));
			
			if (strlen(buffer) > 25)
			{
				buffer[23] = '.';
				buffer[24] = '.';
				buffer[25] = '.';
				buffer[26] = 0;
			}
			
			Format(buffer, sizeof(buffer), "Control: %s", buffer);
			menuPanel.DrawText(buffer);
		}
		else
		{
			menuPanel.DrawText("Control: AI");
		}

		// Health
		int health = (GetEntProp(iTankClients[j], Prop_Send, "m_isIncapacitated") ? 0 : GetClientHealth(iTankClients[j]));
		Format(buffer, sizeof(buffer), "Health : %i / %.1f%%", health, 100.0*health/GetEntProp(iTankClients[j], Prop_Send, "m_iMaxHealth"));
		menuPanel.DrawText(buffer);

		// Rage
		if (!IsFakeClient(iTankClients[j])) {			
			FormatEx(buffer, sizeof(buffer), "Rage : %d%% (Pass #%i)", GetTankFrustration(iTankClients[j]), iTankPassedCount[iTankClients[j]]);
			menuPanel.DrawText(buffer);
			PrintHintText(iTankClients[j], buffer);
		}

		// Fire
		if (GetEntityFlags(iTankClients[j]) & FL_ONFIRE)
			menuPanel.DrawText("Burning...");
		
		menuPanel.DrawText("\n");
	}
	
	// menuPanel.DrawItem("Close");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && (GetClientTeam(i) == 1 || GetClientTeam(i) == 3) && GetZombieClass(i) != 8 && !hiddenTankPanel[i])
		{
			menuPanel.Send(i, DummyHandler, 1);
		}
	}
	
	delete menuPanel;
	return Plugin_Continue;
}

public int DummyHandler(Menu menu, MenuAction action, int param1, int param2) 
{ 
	// if (action == MenuAction_Select)
	// {
	// 	hiddenTankPanel[param1] = true;
	// 	PrintToChat(param1, "\x05Tank HUD disabled.\nTo enable \x04!tankhud");
	// }
	
	// return 0;
	return 1;
}

public Action ToggleTankPanel_Cmd(int client, int args)
{
	if(!hiddenTankPanel[client])
	{
		hiddenTankPanel[client] = true;
		PrintToChat(client, "\x05Tank HUD disabled.");
	}
	else
	{
		hiddenTankPanel[client] = false;
		PrintToChat(client, "\x05Tank HUD enabled.");
	}
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	hiddenTankPanel[client] = false;
}

stock bool GetTankAlive(int client) { return IsPlayerAlive(client) && !GetEntProp(client, Prop_Send, "m_isGhost"); }
stock int GetZombieClass(int client) { return GetEntProp(client, Prop_Send, "m_zombieClass"); }
stock int GetTankFrustration(int iTankClient) { return (100 - GetEntProp(iTankClient, Prop_Send, "m_frustration")); }