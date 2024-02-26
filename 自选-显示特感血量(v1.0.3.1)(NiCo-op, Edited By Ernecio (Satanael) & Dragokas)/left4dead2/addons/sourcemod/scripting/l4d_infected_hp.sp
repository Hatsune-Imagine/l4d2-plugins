#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define PLUGIN_VERSION 				"1.0.3.1"
#define INFECTED_NAMES				7
#define CVAR_FLAGS 					FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION 	CVAR_FLAGS|FCVAR_DONTRECORD

public Plugin myinfo =
{
	name 		= "[L4D1 AND L4D2] Infected HP",
	author 		= "NiCo-op, Edited By Ernecio (Satanael) & Dragokas",
	description = "L4D Infected HP",
	version 	= PLUGIN_VERSION,
	url 		= "http://nico-op.forjp.net/"
};

/*
	1.0.3.1 (20-Nov-2021) Dragokas
	 - Various speed optimizations (recommended to delete old l4d_infected_hp.cfg).
	 - Better methodmaps.
	 - Improved L4D1 support.
	 - removed versus cvar values differentiations for code simplification. Who need them, may manually set desired values in cfg.
	 - removed witch counter in witch name display for better performance.
	 - Timer client safe check.
	 - Cvar precache.
	 - Events hook unload on plugin disable.
	 - Fixed buffer sizes.
*/

ConVar hPluginEnable;
ConVar hBarLEN;
ConVar hCharHealth;
ConVar hCharDamage;
ConVar hShowType;
ConVar hShowNum;
ConVar hTank;
ConVar hWitch;
ConVar hWitchHealth;
ConVar hInfected[INFECTED_NAMES];

int witchMAX[2048];
int witchHP[2048];
int prevMAX[MAXPLAYERS+1];
int prevHP[MAXPLAYERS+1];
int nCharLength;
int nShowType;
int nShowNum;
int nShowTank;
int nShowWitch;
int nShowFlag[INFECTED_NAMES];
int nMaxBAR;
int nEnabled;
int TANK_CLASS;

char sCharHealth[8] = "#";
char sCharDamage[8] = "=";

char sClassName[][] = // according to zombie class enum
{
	"",
	"smoker",
	"boomer",
	"hunter",
	"spitter",
	"jockey",
	"charger"
};

int INFECTED_CLASS_MAX;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	if (test == Engine_Left4Dead2) {
		TANK_CLASS = 8;
		INFECTED_CLASS_MAX = 7;
	}
	else if (test == Engine_Left4Dead) {
		TANK_CLASS = 5;
		INFECTED_CLASS_MAX = 5;
	}
	else {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	hWitchHealth = FindConVar("z_witch_health");
	
	CreateConVar("l4d_infectedhp_version", PLUGIN_VERSION, "L4D Infected HP version", CVAR_FLAGS_PLUGIN_VERSION);
	hPluginEnable 	= CreateConVar("l4d_infectedhp", 			"1", 		"plugin on/off (on:1 / off:0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hBarLEN 		= CreateConVar("l4d_infectedhp_bar", 		"10", 		"length of health bar (min:10 / max:200)", CVAR_FLAGS, true, 10.0, true, 200.0);
	hCharHealth 	= CreateConVar("l4d_infectedhp_health", 	"|", 		"show health character", CVAR_FLAGS);
	hCharDamage 	= CreateConVar("l4d_infectedhp_damage", 	" ", 		"show damage character", CVAR_FLAGS);
	hShowType 		= CreateConVar("l4d_infectedhp_type", 		"0", 		"health bar type (center text:0 / hint text:1)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hShowNum 		= CreateConVar("l4d_infectedhp_num", 		"1", 		"health value display (hidden:0 / visible:1)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hTank 			= CreateConVar("l4d_infectedhp_tank", 		"1", 		"show health bar (on:1 / off:0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hWitch 			= CreateConVar("l4d_infectedhp_witch", 		"1", 		"show health bar (on:1 / off:0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	
	char buffers[64];
	for (int i = 1; i < INFECTED_CLASS_MAX; i ++)
	{
		Format(buffers, sizeof(buffers), "l4d_infectedhp_%s", sClassName[i]);
		hInfected[i] = CreateConVar(buffers, "1", "show health bar (def:1 / on:1 / off:0)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hInfected[i].AddChangeHook(ConVarChanged_Cvars);
	}
	
	// AutoExecConfig(true, "l4d_infected_hp");
	
	hPluginEnable.AddChangeHook(ConVarChanged_Cvars);
	hBarLEN.AddChangeHook(ConVarChanged_Cvars);
	hCharHealth.AddChangeHook(ConVarChanged_Cvars);
	hCharDamage.AddChangeHook(ConVarChanged_Cvars);
	hShowType.AddChangeHook(ConVarChanged_Cvars);
	hShowNum.AddChangeHook(ConVarChanged_Cvars);
	hTank.AddChangeHook(ConVarChanged_Cvars);
	hWitch.AddChangeHook(ConVarChanged_Cvars);
	
	GetConfig();
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetConfig();
}

void GetConfig()
{
	char bufA[8];
	char bufB[8];
	hCharHealth.GetString(bufA, sizeof(bufA));
	hCharDamage.GetString(bufB, sizeof(bufB));
	nCharLength = strlen(bufA);
	if (!nCharLength || nCharLength != strlen(bufB))
	{
		nCharLength = 1;
		sCharHealth[0] = '#';
		sCharHealth[1] = '\0';
		sCharDamage[0] = '=';
		sCharDamage[1] = '\0';
	}
	else
	{
		strcopy(sCharHealth, sizeof(sCharHealth), bufA);
		strcopy(sCharDamage, sizeof(sCharDamage), bufB);
	}

	nShowType = hShowType.BoolValue;
	nShowNum = hShowNum.BoolValue;
	nShowTank = hTank.BoolValue;
	nShowWitch = hWitch.BoolValue;
	for (int i = 1; i < INFECTED_CLASS_MAX; i ++)
	{
		nShowFlag[i] = hInfected[i].BoolValue;
	}
	nMaxBAR = hBarLEN.IntValue;
	nEnabled = hPluginEnable.IntValue;
	
	InitHook();
}

void InitHook()
{
	static bool bHooked;

	if (nEnabled) {
		if (!bHooked) {
			HookEvent("round_start", 	OnRoundStart, 	 EventHookMode_PostNoCopy);
			HookEvent("player_hurt", 	OnPlayerHurt);
			HookEvent("witch_spawn", 	OnWitchSpawn);
			HookEvent("witch_killed", 	OnWitchKilled);
			HookEvent("infected_hurt", 	OnWitchHurt);
			HookEvent("player_spawn", 	OnInfectedSpawn);
			HookEvent("player_death", 	OnInfectedDeath, EventHookMode_Pre);
		//	HookEvent("tank_spawn", 	OnInfectedSpawn);
		//	HookEvent("tank_killed", 	OnInfectedDeath, EventHookMode_Pre);
			bHooked = true;
		}
	} else {
		if (bHooked) {
			UnhookEvent("round_start", 		OnRoundStart, 	 EventHookMode_PostNoCopy);
			UnhookEvent("player_hurt", 		OnPlayerHurt);
			UnhookEvent("witch_spawn", 		OnWitchSpawn);
			UnhookEvent("witch_killed", 	OnWitchKilled);
			UnhookEvent("infected_hurt", 	OnWitchHurt);
			UnhookEvent("player_spawn", 	OnInfectedSpawn);
			UnhookEvent("player_death", 	OnInfectedDeath, EventHookMode_Pre);
			bHooked = false;
		}
	}
}

void ShowHealthGauge(int client, int maxHP, int nowHP, char[] clName)
{
	int percent = RoundToCeil((float(nowHP) / float(maxHP)) * float(nMaxBAR));
	int i; 
	int length = nMaxBAR * nCharLength + 2;
	static char showBAR[256];
	
	showBAR[0] = '\0';
	for (i = 0; i < percent && i < nMaxBAR; i ++) 	StrCat(showBAR, length, sCharHealth);
	for (; i < nMaxBAR; i ++) 						StrCat(showBAR, length, sCharDamage);

	if (nShowType)
	{
		if (!nShowNum) 	PrintHintText(client, "HP: |-%s-|  %s", showBAR, clName);
		else 			PrintHintText(client, "HP: |-%s-|  [%d / %d]  %s", showBAR, nowHP, maxHP, clName);
	}
	else
	{
		if (!nShowNum) 	PrintCenterText(client, "HP: |-%s-|  %s", showBAR, clName);
		else 			PrintCenterText(client, "HP: |-%s-|  [%d / %d]  %s", showBAR, nowHP, maxHP, clName);
	}
}

public void OnRoundStart(Event event, const char[] sName, bool bDontBroadcast)
{
	for (int i = 1; i <= MaxClients; i ++)
	{
		prevMAX[i] = -1;
		prevHP[i] = -1;
	}
	for (int i = 1; i < sizeof(witchHP); i++)
	{
		witchHP[i] = -1;
	}
}

public Action TimerSpawn(Handle timer, int UserId)
{
	int client = GetClientOfUserId(UserId);
	if (client && IsClientInGame(client))
	{
		int val = GetEntProp(client, Prop_Send, "m_iMaxHealth") & 0xffff;
		prevMAX[client] = (val <= 0) ? val : 1;
		prevHP[client] = 999999;
	}
	return Plugin_Continue;
}

public void OnInfectedSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == 3)
	{
		TimerSpawn(INVALID_HANDLE, hEvent.GetInt("userid"));
		CreateTimer(0.5, TimerSpawn, hEvent.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnInfectedDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == 3)
	{
		prevMAX[client] = -1;
		prevHP[client] = -1;
		
		// if (nShowTank && GetEntProp(client, Prop_Send, "m_zombieClass") == TANK_CLASS)
		// {
		// 	static char clName[MAX_NAME_LENGTH];
		// 	GetClientName(client, clName, sizeof(clName));
		// 	PrintHintTextToAll("++ %s is DEAD ++", clName);
		// }
	}
}

public void OnPlayerHurt(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	if (!attacker || !IsClientInGame(attacker) || GetClientTeam(attacker) != 2) return;
	
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 3) return;
	
	int class;
	class = GetEntProp(client, Prop_Send, "m_zombieClass");
	
	int match = 0;
	if (class < INFECTED_CLASS_MAX && nShowFlag[class])
	{
		match = 1;
	}
	else {
		if (nShowTank && class == TANK_CLASS)
		{
			match = 1;
		}
	}
	
	if (!match) return;
	
	int nowHP = hEvent.GetInt("health") & 0xffff;
	int maxHP = GetEntProp(client, Prop_Send, "m_iMaxHealth") & 0xffff;

	if (nowHP <= 0 || prevMAX[client] < 0) 	nowHP = 0;
	
	if (nowHP && nowHP > prevHP[client]) 	nowHP = prevHP[client];
	else 									prevHP[client] = nowHP;
	
	if (maxHP < prevMAX[client]) 			maxHP = prevMAX[client];
	
	if (maxHP < nowHP)
	{
		maxHP = nowHP;
		prevMAX[client] = nowHP;
	}
	
	if (maxHP < 1) maxHP = 1;

	static char clName[MAX_NAME_LENGTH];
	GetClientName(client, clName, sizeof(clName));
	ShowHealthGauge(attacker, maxHP, nowHP, clName);
}

public void OnWitchSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int entity = hEvent.GetInt("witchid");
	int health = (hWitchHealth == INVALID_HANDLE) ? 0 : hWitchHealth.IntValue;
	witchMAX[entity] = health;
	witchHP[entity] = health;
}

public void OnWitchKilled(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int entity = hEvent.GetInt("witchid");
	witchMAX[entity] = -1;
	witchHP[entity] = -1;
}

public void OnWitchHurt(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	if (!nShowWitch) return;
	
	int entity = hEvent.GetInt("entityid");
	if (witchHP[entity] == -1) return;

	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	if (!attacker || !IsClientInGame(attacker) || GetClientTeam(attacker) != 2) return;
	
	int damage = hEvent.GetInt("amount");
	int nowHP = witchHP[entity] - damage;
	int maxHP = witchMAX[entity];

	if (nowHP <= 0 || witchMAX[entity] < 0) nowHP = 0;
	
	if (nowHP && nowHP > witchHP[entity])	nowHP = witchHP[entity];
	else									witchHP[entity] = nowHP;
	
	if (maxHP < 1)	maxHP = 1;
	ShowHealthGauge(attacker, maxHP, nowHP, "Witch");
}
