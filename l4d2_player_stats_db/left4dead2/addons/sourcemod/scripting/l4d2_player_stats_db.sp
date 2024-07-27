#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define TEAM_SPECTATOR	1
#define TEAM_SURVIVOR	2
#define TEAM_INFECTED	3

#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6
#define ZC_WITCH		7
#define ZC_TANK			8

enum struct PlayerInfo
{
	char ip[16];
	char steamId[32];
	char nickname[32];
	int gametime;
	int headshot;
	int melee;
	int ciKilled;
	int smokerKilled;
	int boomerKilled;
	int hunterKilled;
	int spitterKilled;
	int jockeyKilled;
	int chargerKilled;
	int witchKilled;
	int tankKilled;
	int siDamageValue;
	float siDamagePercent;
	int totalFF;
	int totalFFReceived;
	float totalFFPercent;
	int adrenalineUsed;
	int pillsUsed;
	int medkitUsed;
	int teammateProtected;
	int teammateRevived;
	int incapacitated;
	int ledgeHanged;
	int missionCompleted;
	int missionLost;
	int smokerTongueCut;
	int smokerSelfCleared;
	int hunterSkeeted;
	int chargerLeveled;
	int witchCrowned;
	int tankRockSkeeted;
	int tankRockEaten;
	int alarmTriggered;
	float avgInstaClearTime;
	ArrayList instaClearTime;
}

int allSiDamage;
int allFF;

Database g_db;
PlayerInfo g_players[MAXPLAYERS + 1];
char g_playersInGame[MAXPLAYERS + 1][32];
char g_serverIP[16];
char g_serverPort[8];
char g_serverMap[32];
char g_serverMode[32];
int g_mapRound;
// bool g_skillDetectLoaded;

public Plugin myinfo = {
	name 			= "L4D2 Player Stats with Database",
	author 			= "HatsuneImagine",
	description 	= "Store & Fetch player stats from/to databases.",
	version 		= "1.0",
	url 			= "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart() {
	Database.Connect(ConnectCallback, "player_stats");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("mission_lost", Event_MissionLost, EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_MissionCompleted, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_leaving", Event_MissionCompleted, EventHookMode_PostNoCopy);
	HookEvent("adrenaline_used", Event_AdrenalineUsed, EventHookMode_Post);
	HookEvent("pills_used", Event_PillsUsed, EventHookMode_Post);
	HookEvent("heal_success", Event_HealSuccess, EventHookMode_Post);
	HookEvent("award_earned", Event_AwardEarned, EventHookMode_Post);
	HookEvent("revive_success", Event_ReviveSuccess, EventHookMode_Post);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated, EventHookMode_Post);
	HookEvent("player_ledge_grab", Event_PlayerLedgeGrab, EventHookMode_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("infected_hurt", Event_InfectedHurt, EventHookMode_Post);
	HookEvent("infected_death", Event_InfectedDeath, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	HookEvent("witch_killed", Event_WitchDeath, EventHookMode_Post);

	FindConVar("net_public_adr").GetString(g_serverIP, sizeof(g_serverIP));
	FindConVar("hostport").GetString(g_serverPort, sizeof(g_serverPort));

	RegConsoleCmd("sm_mystats", Cmd_My_Stats, "Show my stats.");
	RegConsoleCmd("sm_my_stats", Cmd_My_Stats, "Show my stats.");

	for (int i = 0; i < MAXPLAYERS + 1; i++) {
		g_players[i].instaClearTime = new ArrayList();
	}
}
/*
public void OnAllPluginsLoaded() {
	g_skillDetectLoaded = LibraryExists("skill_detect");
}

public void OnLibraryAdded(const char[] name) {
	CheckLib(name, true);
}

public void OnLibraryRemoved(const char[] name) {
	CheckLib(name, false);
}

void CheckLib(const char[] name, bool state) {
	if (strcmp(name, "skill_detect") == 0) {
		g_skillDetectLoaded = state;
	}
}
*/
Action Cmd_My_Stats(int client, int args) {
	PrintToChat(client, "IP: %s", g_players[client].ip);
	PrintToChat(client, "SteamID: %s", g_players[client].steamId);
	PrintToChat(client, "Nickname: %s", g_players[client].nickname);
	PrintToChat(client, "GameTime: %d", g_players[client].gametime);
	PrintToChat(client, "Headshot: %d", g_players[client].headshot);
	PrintToChat(client, "Melee: %d", g_players[client].melee);
	PrintToChat(client, "CI Killed: %d", g_players[client].ciKilled);
	PrintToChat(client, "Smoker Killed: %d", g_players[client].smokerKilled);
	PrintToChat(client, "Boomer Killed: %d", g_players[client].boomerKilled);
	PrintToChat(client, "Hunter Killed: %d", g_players[client].hunterKilled);
	PrintToChat(client, "Spitter Killed: %d", g_players[client].spitterKilled);
	PrintToChat(client, "Jockey Killed: %d", g_players[client].jockeyKilled);
	PrintToChat(client, "Charger Killed: %d", g_players[client].chargerKilled);
	PrintToChat(client, "Witch Killed: %d", g_players[client].witchKilled);
	PrintToChat(client, "Tank Killed: %d", g_players[client].tankKilled);
	PrintToChat(client, "SI Damage Value: %d", g_players[client].siDamageValue);
	PrintToChat(client, "SI Damage Percent: %.2f", g_players[client].siDamagePercent);
	PrintToChat(client, "Total FF: %d", g_players[client].totalFF);
	PrintToChat(client, "Total FF Received: %d", g_players[client].totalFFReceived);
	PrintToChat(client, "Total FF Percent: %.2f", g_players[client].totalFFPercent);
	PrintToChat(client, "Adrenaline Used: %d", g_players[client].adrenalineUsed);
	PrintToChat(client, "Pills Used: %d", g_players[client].pillsUsed);
	PrintToChat(client, "Medkit Used: %d", g_players[client].medkitUsed);
	PrintToChat(client, "Teammate Protected: %d", g_players[client].teammateProtected);
	PrintToChat(client, "Teammate Revived: %d", g_players[client].teammateRevived);
	PrintToChat(client, "Incapacitated: %d", g_players[client].incapacitated);
	PrintToChat(client, "Ledge Hanged: %d", g_players[client].ledgeHanged);
	PrintToChat(client, "Mission Completed: %d", g_players[client].missionCompleted);
	PrintToChat(client, "Mission Lost: %d", g_players[client].missionLost);
	PrintToChat(client, "Smoker Tongue Cut: %d", g_players[client].smokerTongueCut);
	PrintToChat(client, "Smoker Self Cleared: %d", g_players[client].smokerSelfCleared);
	PrintToChat(client, "Hunter Skeeted: %d", g_players[client].hunterSkeeted);
	PrintToChat(client, "Charger Leveled: %d", g_players[client].chargerLeveled);
	PrintToChat(client, "Witch Crowned: %d", g_players[client].witchCrowned);
	PrintToChat(client, "Tank Rock Skeeted: %d", g_players[client].tankRockSkeeted);
	PrintToChat(client, "Tank Rock Eaten: %d", g_players[client].tankRockEaten);
	PrintToChat(client, "Alarm Triggered: %d", g_players[client].alarmTriggered);
	PrintToChat(client, "Avg Insta-Clear Time: %.2f", g_players[client].avgInstaClearTime);

	PrintToChat(client, "Insta-Clear Array: ");
	PrintToChat(client, "[");
	for (int i = 0; i < g_players[client].instaClearTime.Length; i++) {
		PrintToChat(client, "\t%.2f", g_players[client].instaClearTime.Get(i));
	}
	PrintToChat(client, "]");
	return Plugin_Continue;
}

public void OnClientAuthorized(int client) {
	// 玩家进入游戏
	if (IsFakeClient(client)) {
		return;
	}

	// 初始化玩家本局缓存数据
	InitCachedPlayerInfo(client);
	// 保存玩家连接记录
	SQL_InsertConnectLog(client);
}

public void OnMapEnd() {
	// 章节结束，重置回合数
	g_mapRound = 0;
}

public void OnPluginEnd() {
	CloseHandle(g_db);
}

void Event_AdrenalineUsed(Event event, const char[] name, bool dontBroadcast) {
	// 玩家使用肾上腺素
	int client = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N used adrenaline!", client, client);
	if (IsValidClient(client)) {
		g_players[client].adrenalineUsed++;
	}
}

void Event_PillsUsed(Event event, const char[] name, bool dontBroadcast) {
	// 玩家使用止痛药
	int client = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N used pills!", client, client);
	if (IsValidClient(client)) {
		g_players[client].pillsUsed++;
	}
}

void Event_HealSuccess(Event event, const char[] name, bool dontBroadcast) {
	// 玩家使用医疗包
	int client = GetClientOfUserId(event.GetInt("subject"));
	// int helper = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N healed %d:%N", helper, helper, client, client);
	if (IsValidClient(client)) {
		g_players[client].medkitUsed++;
	}
}

void Event_AwardEarned(Event event, const char[] name, bool dontBroadcast) {
	// 玩家保护队友
	int client = GetClientOfUserId(event.GetInt("userid"));
	int subjectEnt = GetClientOfUserId(event.GetInt("subjectEntid"));
	int awardId = GetEventInt(event, "award");

	// PrintToChatAll("%d:%N protected %d:%N, awardId = %i", client, client, subjectEnt, subjectEnt, awardId);
	if (IsValidClient(client) && IsValidClient(subjectEnt) && awardId == 67) {
		g_players[client].teammateProtected++;
	}
}

void Event_ReviveSuccess(Event event, const char[] name, bool dontBroadcast) {
	// 玩家救起队友
	// int client = GetClientOfUserId(event.GetInt("subject"));
	int helper = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N revived %d:%N", helper, helper, client, client);
	if (IsValidClient(helper)) {
		g_players[helper].teammateRevived++;
	}
}

void Event_PlayerIncapacitated(Event event, const char[] name, bool dontBroadcast) {
	// 玩家倒地
	int client = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N incapped!", client, client);
	if (IsValidClient(client)) {
		g_players[client].incapacitated++;
	}
}

void Event_PlayerLedgeGrab(Event event, const char[] name, bool dontBroadcast) {
	// 玩家挂边
	int client = GetClientOfUserId(event.GetInt("userid"));
	// PrintToChatAll("%d:%N hanged on ledge!", client, client);
	if (IsValidClient(client)) {
		g_players[client].ledgeHanged++;
	}
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) {
	// 玩家退出
	int client = GetClientOfUserId(event.GetInt("userid"));

	int currentTime = RoundToNearest(GetEngineTime());
	g_players[client].gametime = currentTime - g_players[client].gametime;
	g_players[client].siDamagePercent = allSiDamage == 0 ? (g_players[client].siDamageValue > 0 ? 1.0 : 0.0) : float(g_players[client].siDamageValue) / float(allSiDamage);
	g_players[client].totalFFPercent = allFF == 0 ? (g_players[client].totalFF > 0 ? 1.0 : 0.0) : float(g_players[client].totalFF) / float(allFF);
	float allInstaClearTime = 0.0;
	for (int j = 0; j < g_players[client].instaClearTime.Length; j++) {
		char eachClearTime[8];
		FormatEx(eachClearTime, sizeof(eachClearTime), "%.2f", g_players[client].instaClearTime.Get(j));
		LogMessage("Client: %d:%N, Insta-Clear Time Array Content[%d]: %s", client, client, j, eachClearTime);
		allInstaClearTime += StringToFloat(eachClearTime);
	}
	g_players[client].avgInstaClearTime = g_players[client].instaClearTime.Length > 0 ? allInstaClearTime / g_players[client].instaClearTime.Length : 0.0;

	// 保存此玩家本局缓存数据 -> 数据库
	SQL_UpdatePlayerInfo(client);

	// 清除此client缓存数据
	ClearCachedPlayerInfo(client);
	g_playersInGame[client] = "";
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	// 回合开始
	g_mapRound++;
	GetCurrentMap(g_serverMap, sizeof(g_serverMap));
	FindConVar("mp_gamemode").GetString(g_serverMode, sizeof(g_serverMode));

	// 重置所有玩家本局缓存数据
	for (int i = 1; i <= MaxClients; i++) {
		ResetCachedPlayerInfo(i);
	}
	allSiDamage = 0;
	allFF = 0;
}

void Event_MissionLost(Event event, const char[] name, bool dontBroadcast) {
	// 回合结束（团灭），保存所有玩家本局缓存数据 -> 数据库
	int currentTime = RoundToNearest(GetEngineTime());
	for (int i = 1; i <= MaxClients; i++) {
		g_players[i].gametime = currentTime - g_players[i].gametime;
		g_players[i].siDamagePercent = allSiDamage == 0 ? (g_players[i].siDamageValue > 0 ? 1.0 : 0.0) : float(g_players[i].siDamageValue) / float(allSiDamage);
		g_players[i].totalFFPercent = allFF == 0 ? (g_players[i].totalFF > 0 ? 1.0 : 0.0) : float(g_players[i].totalFF) / float(allFF);
		g_players[i].missionLost++;

		float allInstaClearTime = 0.0;
		for (int j = 0; j < g_players[i].instaClearTime.Length; j++) {
			char eachClearTime[8];
			FormatEx(eachClearTime, sizeof(eachClearTime), "%.2f", g_players[i].instaClearTime.Get(j));
			LogMessage("Client: %d:%N, Insta-Clear Time Array Content[%d]: %s", i, i, j, eachClearTime);
			allInstaClearTime += StringToFloat(eachClearTime);
		}
		g_players[i].avgInstaClearTime = g_players[i].instaClearTime.Length > 0 ? allInstaClearTime / g_players[i].instaClearTime.Length : 0.0;

		SQL_UpdatePlayerInfo(i);
		SQL_InsertPlayerRoundDetail(i);
	}
}

void Event_MissionCompleted(Event event, const char[] name, bool dontBroadcast) {
	// 回合结束（过关），保存所有玩家本局缓存数据 -> 数据库
	int currentTime = RoundToNearest(GetEngineTime());
	for (int i = 1; i <= MaxClients; i++) {
		g_players[i].gametime = currentTime - g_players[i].gametime;
		g_players[i].siDamagePercent = allSiDamage == 0 ? (g_players[i].siDamageValue > 0 ? 1.0 : 0.0) : float(g_players[i].siDamageValue) / float(allSiDamage);
		g_players[i].totalFFPercent = allFF == 0 ? (g_players[i].totalFF > 0 ? 1.0 : 0.0) : float(g_players[i].totalFF) / float(allFF);
		g_players[i].missionCompleted++;

		float allInstaClearTime = 0.0;
		for (int j = 0; j < g_players[i].instaClearTime.Length; j++) {
			char eachClearTime[8];
			FormatEx(eachClearTime, sizeof(eachClearTime), "%.2f", g_players[i].instaClearTime.Get(j));
			LogMessage("Client: %d:%N, Insta-Clear Time Array Content[%d]: %s", i, i, j, eachClearTime);
			allInstaClearTime += StringToFloat(eachClearTime);
		}
		g_players[i].avgInstaClearTime = g_players[i].instaClearTime.Length > 0 ? allInstaClearTime / g_players[i].instaClearTime.Length : 0.0;

		SQL_UpdatePlayerInfo(i);
		SQL_InsertPlayerRoundDetail(i);
	}
}



/*
Such actions will trigger such events.

KillCI
	Infected Hurt
	Infected Death
	Player Death

KillSI
	Player Hurt
	Player Death

KillWitch
	Infected Hurt
	Infected Death
	Player Death
	Witch Death

KillTank
	Player Hurt
	Player Death
*/

// KillCI, KillWitch
void Event_InfectedHurt(Event event, const char[] name, bool dontBroadcast) {
	// 感染者受伤，统计玩家对Witch伤害
	int victimEntId = GetEventInt(event, "entityid");

	if (IsWitch(victimEntId)) {
		int attackerId = GetEventInt(event, "attacker");
		int attacker = GetClientOfUserId(attackerId);
		int damageDone = GetEventInt(event, "amount");

		if (attackerId && IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
			g_players[attacker].siDamageValue += damageDone;
			allSiDamage += damageDone;
		}
	}
}

// KillCI, KillWitch
void Event_InfectedDeath(Event event, const char[] name, bool dontBroadcast) {
	// 感染者死亡，统计玩家普通感染者击杀数
	int victimEntId = GetEventInt(event, "entityid");

	if (!IsWitch(victimEntId)) {
		int attackerId = GetEventInt(event, "attacker");
		int attacker = GetClientOfUserId(attackerId);

		if (attackerId && IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
			g_players[attacker].ciKilled++;
		}
	}
}

// KillSI, KillTank, FF
void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) {
	// 玩家受伤，统计玩家对特感伤害/玩家友伤
	int victimId = GetEventInt(event, "userid");
	int victim = GetClientOfUserId(victimId);
	int attackerId = GetEventInt(event, "attacker");
	int attacker = GetClientOfUserId(attackerId);
	int damageDone = GetEventInt(event, "dmg_health");

	if (victimId && attackerId && IsValidClient(attacker)) {
		// 生还者攻击特感
		if (GetClientTeam(attacker) == TEAM_SURVIVOR && GetClientTeam(victim) == TEAM_INFECTED) {
			g_players[attacker].siDamageValue += damageDone;
			allSiDamage += damageDone;
		}

		// 生还者攻击生还者
		else if (GetClientTeam(attacker) == TEAM_SURVIVOR && GetClientTeam(victim) == TEAM_SURVIVOR && !IsPlayerIncapacitated(victim)) {
			g_players[attacker].totalFF += damageDone;
			g_players[victim].totalFFReceived += damageDone;
			allFF += damageDone;
		}
	}
}

// KillCI, KillSI, KillWitch, KillTank
void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	// 玩家死亡，统计玩家特感击杀数
	int victimId = GetEventInt(event, "userid");
	int victim = GetClientOfUserId(victimId);
	int attackerId = GetEventInt(event, "attacker");
	int attacker = GetClientOfUserId(attackerId);
	bool headshot = GetEventBool(event, "headshot");
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));

	// 统计6种特感 + Tank 击杀数 (Witch需单独处理)
	if (victimId && attackerId && IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR && GetClientTeam(victim) == TEAM_INFECTED) {
		int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");

		if (zombieClass == ZC_SMOKER) {
			g_players[attacker].smokerKilled++;
		}
		else if (zombieClass == ZC_BOOMER) {
			g_players[attacker].boomerKilled++;
		}
		else if (zombieClass == ZC_HUNTER) {
			g_players[attacker].hunterKilled++;
		}
		else if (zombieClass == ZC_SPITTER) {
			g_players[attacker].spitterKilled++;
		}
		else if (zombieClass == ZC_JOCKEY) {
			g_players[attacker].jockeyKilled++;
		}
		else if (zombieClass == ZC_CHARGER) {
			g_players[attacker].chargerKilled++;
		}
		else if (zombieClass == ZC_TANK) {
			g_players[attacker].tankKilled++;
		}
	}

	// 统计爆头数
	if (headshot) {
		g_players[attacker].headshot++;
	}

	// 统计近战击杀数
	if (IsMeleeWeapon(weapon)) {
		g_players[attacker].melee++;
	}
}

void Event_WitchDeath(Event event, const char[] name, bool dontBroadcast) {
	// Witch死亡，统计玩家Witch击杀数
	int attackerId = event.GetInt("userid");
	int attacker = GetClientOfUserId(attackerId);
	if (attackerId && IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
		g_players[attacker].witchKilled++;
	}
}


// -------------------- [skill_detect] Start --------------------

public void OnTongueCut(int attacker, int victim) {
	// 玩家近战砍断Smoker舌头
	if (IsValidClient(attacker)) {
		g_players[attacker].smokerTongueCut++;
	}
}

public void OnSmokerSelfClear(int attacker, int victim, bool withShove) {
	// 玩家自解Smoker舌头
	if (IsValidClient(attacker)) {
		g_players[attacker].smokerSelfCleared++;
	}
}

public void OnSkeet(int attacker, int victim) {
	// 玩家空爆Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetGL(int attacker, int victim) {
	// 玩家榴弹空爆Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetHurt(int attacker, int victim, int damage) {
	// 玩家空爆残血Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetMelee(int attacker, int victim) {
	// 玩家近战空爆Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetMeleeHurt(int attacker, int victim, int damage) {
	// 玩家近战空爆残血Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetSniper(int attacker, int victim) {
	// 玩家狙击空爆Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnSkeetSniperHurt(int attacker, int victim, int damage) {
	// 玩家狙击空爆残血Hunter
	if (IsValidClient(attacker)) {
		g_players[attacker].hunterSkeeted++;
	}
}

public void OnChargerLevel(int attacker, int victim) {
	// 玩家近战砍死冲锋Charger
	if (IsValidClient(attacker)) {
		g_players[attacker].chargerLeveled++;
	}
}

public void OnChargerLevelHurt(int attacker, int victim, int damage) {
	// 玩家近战砍死残血冲锋Charger
	if (IsValidClient(attacker)) {
		g_players[attacker].chargerLeveled++;
	}
}

public void OnWitchCrown(int attacker, int damage) {
	// 玩家秒杀Witch
	if (IsValidClient(attacker)) {
		g_players[attacker].witchCrowned++;
	}
}

public void OnWitchDrawCrown(int attacker, int damage, int chipdamage) {
	// 玩家引秒Witch
	if (IsValidClient(attacker)) {
		g_players[attacker].witchCrowned++;
	}
}

public void OnTankRockSkeeted(int attacker, int victim) {
	// 玩家打碎Tank石头
	if (IsValidClient(attacker)) {
		g_players[attacker].tankRockSkeeted++;
	}
}

public void OnTankRockEaten(int attacker, int victim) {
	// 玩家被Tank石头砸中
	if (IsValidClient(attacker)) {
		g_players[victim].tankRockEaten++;
	}
}

public void OnCarAlarmTriggered(int survivor, int infected) {
	// 玩家触发警报
	if (IsValidClient(survivor)) {
		g_players[survivor].alarmTriggered++;
	}
}

public void OnSpecialClear(int clearer, int pinner, int pinvictim, int zombieClass, float timeA, float timeB, bool withShove) {
	// 玩家解救被控队友
	float clearTime = timeA;
	if (zombieClass == ZC_CHARGER || zombieClass == ZC_SMOKER) { 
		clearTime = timeB;
	}

	if (IsValidClient(clearer) && clearTime > 0.0 && clearTime < 60.0) {
		g_players[clearer].instaClearTime.Push(clearTime);
	}
}

// -------------------- [skill_detect] End --------------------


bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}
/*
bool IsRealClient(int client) {
	return IsValidClient(client) && !IsFakeClient(client);
}
*/
bool IsWitch(int entity) {
	if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity)) {
		char edictClassName[64];
		GetEdictClassname(entity, edictClassName, sizeof(edictClassName));
		return StrEqual(edictClassName, "witch");
	}
	return false;
}

bool IsPlayerIncapacitated(int client) {
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

bool IsMeleeWeapon(char[] weaponName) {
	return StrEqual(weaponName, "melee", false) || StrEqual(weaponName, "chainsaw", false);
}

void SQL_InsertConnectLog(int client) {
	if (StrEqual(g_players[client].steamId, "") || StrEqual(g_players[client].steamId, "BOT")) {
		return;
	}

	char query[2048];
	FormatEx(query, sizeof(query), "select 1 from t_player where steam_id = '%s'", g_players[client].steamId);
	LogMessage(query);
	g_db.Query(PlayerJoinQueryCallback, query, client);

	if (!StrEqual(g_playersInGame[client], g_players[client].steamId)) {
		g_playersInGame[client] = g_players[client].steamId;

		char insert[2048];
		FormatEx(insert, sizeof(insert), "insert into t_player_connect_log (steam_id, connect_ip) values ('%s', '%s')", g_players[client].steamId, g_players[client].ip);
		LogMessage(insert);
		g_db.Query(DatabaseInsertCallback, insert, client);
/*
		char insert[2048];
		char insertError[2048];
		FormatEx(insert, sizeof(insert), "insert into t_player_connect_log (steam_id, connect_ip) values (?, ?)");
		DBStatement stmt = SQL_PrepareQuery(g_db, insert, insertError, sizeof(insertError));
		SQL_BindParamString(stmt, 0, g_players[client].steamId, false);
		SQL_BindParamString(stmt, 1, g_players[client].ip, false);
		if (!SQL_Execute(stmt)) {
			LogError("Insert t_player_connect_log record failed. %s", insertError);
		}
		CloseHandle(stmt);
*/
	}
}

void SQL_UpdatePlayerInfo(int client) {
	if (StrEqual(g_players[client].steamId, "") || StrEqual(g_players[client].steamId, "BOT")) {
		return;
	}

	char update[2048];
	FormatEx(update, sizeof(update), 
		"update t_player set "
	...	"gametime = gametime + %d, "
	...	"headshot = headshot + %d, "
	...	"melee = melee + %d, "
	...	"ci_killed = ci_killed + %d, "
	...	"smoker_killed = smoker_killed + %d, "
	...	"boomer_killed = boomer_killed + %d, "
	...	"hunter_killed = hunter_killed + %d, "
	...	"spitter_killed = spitter_killed + %d, "
	...	"jockey_killed = jockey_killed + %d, "
	...	"charger_killed = charger_killed + %d, "
	...	"witch_killed = witch_killed + %d, "
	...	"tank_killed = tank_killed + %d, "
	...	"total_ff = total_ff + %d, "
	...	"total_ff_received = total_ff_received + %d, "
	...	"teammate_protected = teammate_protected + %d, "
	...	"teammate_revived = teammate_revived + %d, "
	...	"incapacitated = incapacitated + %d, "
	...	"ledge_hanged = ledge_hanged + %d, "
	...	"mission_completed = mission_completed + %d, "
	...	"mission_lost = mission_lost + %d, "
	...	"smoker_tongue_cut = smoker_tongue_cut + %d, "
	...	"smoker_self_cleared = smoker_self_cleared + %d, "
	...	"hunter_skeeted = hunter_skeeted + %d, "
	...	"charger_leveled = charger_leveled + %d, "
	...	"witch_crowned = witch_crowned + %d, "
	...	"tank_rock_skeeted = tank_rock_skeeted + %d, "
	...	"tank_rock_eaten = tank_rock_eaten + %d, "
	...	"alarm_triggered = alarm_triggered + %d "
	...	"where steam_id = '%s'", 
		g_players[client].gametime, 
		g_players[client].headshot, 
		g_players[client].melee, 
		g_players[client].ciKilled, 
		g_players[client].smokerKilled, 
		g_players[client].boomerKilled, 
		g_players[client].hunterKilled, 
		g_players[client].spitterKilled, 
		g_players[client].jockeyKilled, 
		g_players[client].chargerKilled, 
		g_players[client].witchKilled, 
		g_players[client].tankKilled, 
		g_players[client].totalFF, 
		g_players[client].totalFFReceived, 
		g_players[client].teammateProtected, 
		g_players[client].teammateRevived, 
		g_players[client].incapacitated, 
		g_players[client].ledgeHanged, 
		g_players[client].missionCompleted, 
		g_players[client].missionLost, 
		g_players[client].smokerTongueCut, 
		g_players[client].smokerSelfCleared, 
		g_players[client].hunterSkeeted, 
		g_players[client].chargerLeveled, 
		g_players[client].witchCrowned, 
		g_players[client].tankRockSkeeted, 
		g_players[client].tankRockEaten, 
		g_players[client].alarmTriggered, 
		g_players[client].steamId
	);
	LogMessage(update);
	g_db.Query(DatabaseUpdateCallback, update);
/*
	char update[2048];
	char updateError[2048];
	FormatEx(update, sizeof(update), 
		"update t_player set "
	...	"gametime = gametime + ?, "
	...	"headshot = headshot + ?, "
	...	"melee = melee + ?, "
	...	"ci_killed = ci_killed + ?, "
	...	"smoker_killed = smoker_killed + ?, "
	...	"boomer_killed = boomer_killed + ?, "
	...	"hunter_killed = hunter_killed + ?, "
	...	"spitter_killed = spitter_killed + ?, "
	...	"jockey_killed = jockey_killed + ?, "
	...	"charger_killed = charger_killed + ?, "
	...	"witch_killed = witch_killed + ?, "
	...	"tank_killed = tank_killed + ?, "
	...	"total_ff = total_ff + ?, "
	...	"total_ff_received = total_ff_received + ?, "
	...	"teammate_protected = teammate_protected + ?, "
	...	"teammate_revived = teammate_revived + ?, "
	...	"incapacitated = incapacitated + ?, "
	...	"ledge_hanged = ledge_hanged + ?, "
	...	"mission_completed = mission_completed + ?, "
	...	"mission_lost = mission_lost + ?, "
	...	"smoker_tongue_cut = smoker_tongue_cut + ?, "
	...	"smoker_self_cleared = smoker_self_cleared + ?, "
	...	"hunter_skeeted = hunter_skeeted + ?, "
	...	"charger_leveled = charger_leveled + ?, "
	...	"witch_crowned = witch_crowned + ?, "
	...	"tank_rock_skeeted = tank_rock_skeeted + ?, "
	...	"tank_rock_eaten = tank_rock_eaten + ?, "
	...	"alarm_triggered = alarm_triggered + ? "
	...	"where steam_id = ?"
	);
	DBStatement stmt = SQL_PrepareQuery(g_db, update, updateError, sizeof(updateError));
	SQL_BindParamInt(stmt, 0, g_players[client].gametime, false);
	SQL_BindParamInt(stmt, 1, g_players[client].headshot, false);
	SQL_BindParamInt(stmt, 2, g_players[client].melee, false);
	SQL_BindParamInt(stmt, 3, g_players[client].ciKilled, false);
	SQL_BindParamInt(stmt, 4, g_players[client].smokerKilled, false);
	SQL_BindParamInt(stmt, 5, g_players[client].boomerKilled, false);
	SQL_BindParamInt(stmt, 6, g_players[client].hunterKilled, false);
	SQL_BindParamInt(stmt, 7, g_players[client].spitterKilled, false);
	SQL_BindParamInt(stmt, 8, g_players[client].jockeyKilled, false);
	SQL_BindParamInt(stmt, 9, g_players[client].chargerKilled, false);
	SQL_BindParamInt(stmt, 10, g_players[client].witchKilled, false);
	SQL_BindParamInt(stmt, 11, g_players[client].tankKilled, false);
	SQL_BindParamInt(stmt, 12, g_players[client].totalFF, false);
	SQL_BindParamInt(stmt, 13, g_players[client].totalFFReceived, false);
	SQL_BindParamInt(stmt, 14, g_players[client].teammateProtected, false);
	SQL_BindParamInt(stmt, 15, g_players[client].teammateRevived, false);
	SQL_BindParamInt(stmt, 16, g_players[client].incapacitated, false);
	SQL_BindParamInt(stmt, 17, g_players[client].ledgeHanged, false);
	SQL_BindParamInt(stmt, 18, g_players[client].missionCompleted, false);
	SQL_BindParamInt(stmt, 19, g_players[client].missionLost, false);
	SQL_BindParamInt(stmt, 20, g_players[client].smokerTongueCut, false);
	SQL_BindParamInt(stmt, 21, g_players[client].smokerSelfCleared, false);
	SQL_BindParamInt(stmt, 22, g_players[client].hunterSkeeted, false);
	SQL_BindParamInt(stmt, 23, g_players[client].chargerLeveled, false);
	SQL_BindParamInt(stmt, 24, g_players[client].witchCrowned, false);
	SQL_BindParamInt(stmt, 25, g_players[client].tankRockSkeeted, false);
	SQL_BindParamInt(stmt, 26, g_players[client].tankRockEaten, false);
	SQL_BindParamInt(stmt, 27, g_players[client].alarmTriggered, false);
	SQL_BindParamString(stmt, 28, g_players[client].steamId, false);
	if (!SQL_Execute(stmt)) {
		LogError("Update t_player record failed. %s", updateError);
	}
	CloseHandle(stmt);
*/
}

void SQL_InsertPlayerRoundDetail(int client) {
	if (StrEqual(g_players[client].steamId, "") || StrEqual(g_players[client].steamId, "BOT")) {
		return;
	}

	char insert[2048];
	FormatEx(insert, sizeof(insert), 
		"insert into t_player_round_detail ("
	...	"steam_id, "
	...	"server_ip, "
	...	"server_port, "
	...	"server_map, "
	...	"server_mode, "
	...	"map_round, "
	...	"headshot, "
	...	"melee, "
	...	"ci_killed, "
	...	"smoker_killed, "
	...	"boomer_killed, "
	...	"hunter_killed, "
	...	"spitter_killed, "
	...	"jockey_killed, "
	...	"charger_killed, "
	...	"witch_killed, "
	...	"tank_killed, "
	...	"si_damage_value, "
	...	"si_damage_percent, "
	...	"total_ff, "
	...	"total_ff_received, "
	...	"total_ff_percent, "
	...	"adrenaline_used, "
	...	"pills_used, "
	...	"medkit_used, "
	...	"teammate_protected, "
	...	"teammate_revived, "
	...	"incapacitated, "
	...	"ledge_hanged, "
	...	"smoker_tongue_cut, "
	...	"smoker_self_cleared, "
	...	"hunter_skeeted, "
	...	"charger_leveled, "
	...	"witch_crowned, "
	...	"tank_rock_skeeted, "
	...	"tank_rock_eaten, "
	...	"alarm_triggered, "
	...	"avg_insta_clear_time) "
	...	"values ('%s', '%s', '%s', '%s', '%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %.2f, %d, %d, %.2f, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %.2f)", 
		g_players[client].steamId, 
		g_serverIP, 
		g_serverPort, 
		g_serverMap, 
		g_serverMode, 
		g_mapRound, 
		g_players[client].headshot, 
		g_players[client].melee, 
		g_players[client].ciKilled, 
		g_players[client].smokerKilled, 
		g_players[client].boomerKilled, 
		g_players[client].hunterKilled, 
		g_players[client].spitterKilled, 
		g_players[client].jockeyKilled, 
		g_players[client].chargerKilled, 
		g_players[client].witchKilled, 
		g_players[client].tankKilled, 
		g_players[client].siDamageValue, 
		g_players[client].siDamagePercent, 
		g_players[client].totalFF, 
		g_players[client].totalFFReceived, 
		g_players[client].totalFFPercent, 
		g_players[client].adrenalineUsed, 
		g_players[client].pillsUsed, 
		g_players[client].medkitUsed, 
		g_players[client].teammateProtected, 
		g_players[client].teammateRevived, 
		g_players[client].incapacitated, 
		g_players[client].ledgeHanged, 
		g_players[client].smokerTongueCut, 
		g_players[client].smokerSelfCleared, 
		g_players[client].hunterSkeeted, 
		g_players[client].chargerLeveled, 
		g_players[client].witchCrowned, 
		g_players[client].tankRockSkeeted, 
		g_players[client].tankRockEaten, 
		g_players[client].alarmTriggered, 
		g_players[client].avgInstaClearTime
	);
	LogMessage(insert);
	g_db.Query(DatabaseInsertCallback, insert);
/*
	char insert[2048];
	char insertError[2048];
	FormatEx(insert, sizeof(insert), 
		"insert into t_player_round_detail ("
	...	"steam_id, "
	...	"server_ip, "
	...	"server_port, "
	...	"server_map, "
	...	"server_mode, "
	...	"map_round, "
	...	"headshot, "
	...	"melee, "
	...	"ci_killed, "
	...	"smoker_killed, "
	...	"boomer_killed, "
	...	"hunter_killed, "
	...	"spitter_killed, "
	...	"jockey_killed, "
	...	"charger_killed, "
	...	"witch_killed, "
	...	"tank_killed, "
	...	"si_damage_value, "
	...	"si_damage_percent, "
	...	"total_ff, "
	...	"total_ff_received, "
	...	"total_ff_percent, "
	...	"adrenaline_used, "
	...	"pills_used, "
	...	"medkit_used, "
	...	"teammate_protected, "
	...	"teammate_revived, "
	...	"incapacitated, "
	...	"ledge_hanged, "
	...	"smoker_tongue_cut, "
	...	"smoker_self_cleared, "
	...	"hunter_skeeted, "
	...	"charger_leveled, "
	...	"witch_crowned, "
	...	"tank_rock_skeeted, "
	...	"tank_rock_eaten, "
	...	"alarm_triggered, "
	...	"avg_insta_clear_time) "
	...	"values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
	);
	DBStatement stmt2 = SQL_PrepareQuery(g_db, update, insertError, sizeof(insertError));
	SQL_BindParamString(stmt2, 0, g_players[client].steamId, false);
	SQL_BindParamString(stmt2, 1, g_serverIP, false);
	SQL_BindParamString(stmt2, 2, g_serverPort, false);
	SQL_BindParamString(stmt2, 3, g_serverMap, false);
	SQL_BindParamString(stmt2, 4, g_serverMode, false);
	SQL_BindParamInt(stmt2, 5, g_mapRound, false);
	SQL_BindParamInt(stmt2, 6, g_players[client].headshot, false);
	SQL_BindParamInt(stmt2, 7, g_players[client].melee, false);
	SQL_BindParamInt(stmt2, 8, g_players[client].ciKilled, false);
	SQL_BindParamInt(stmt2, 9, g_players[client].smokerKilled, false);
	SQL_BindParamInt(stmt2, 10, g_players[client].boomerKilled, false);
	SQL_BindParamInt(stmt2, 11, g_players[client].hunterKilled, false);
	SQL_BindParamInt(stmt2, 12, g_players[client].spitterKilled, false);
	SQL_BindParamInt(stmt2, 13, g_players[client].jockeyKilled, false);
	SQL_BindParamInt(stmt2, 14, g_players[client].chargerKilled, false);
	SQL_BindParamInt(stmt2, 15, g_players[client].witchKilled, false);
	SQL_BindParamInt(stmt2, 16, g_players[client].tankKilled, false);
	SQL_BindParamInt(stmt2, 17, g_players[client].siDamageValue, false);
	SQL_BindParamFloat(stmt2, 18, g_players[client].siDamagePercent);
	SQL_BindParamInt(stmt2, 19, g_players[client].totalFF, false);
	SQL_BindParamInt(stmt2, 20, g_players[client].totalFFReceived, false);
	SQL_BindParamFloat(stmt2, 21, g_players[client].totalFFPercent);
	SQL_BindParamInt(stmt2, 22, g_players[client].adrenalineUsed, false);
	SQL_BindParamInt(stmt2, 23, g_players[client].pillsUsed, false);
	SQL_BindParamInt(stmt2, 24, g_players[client].medkitUsed, false);
	SQL_BindParamInt(stmt2, 25, g_players[client].teammateProtected, false);
	SQL_BindParamInt(stmt2, 26, g_players[client].teammateRevived, false);
	SQL_BindParamInt(stmt2, 27, g_players[client].incapacitated, false);
	SQL_BindParamInt(stmt2, 28, g_players[client].ledgeHanged, false);
	SQL_BindParamInt(stmt2, 29, g_players[client].smokerTongueCut, false);
	SQL_BindParamInt(stmt2, 30, g_players[client].smokerSelfCleared, false);
	SQL_BindParamInt(stmt2, 31, g_players[client].hunterSkeeted, false);
	SQL_BindParamInt(stmt2, 32, g_players[client].chargerLeveled, false);
	SQL_BindParamInt(stmt2, 33, g_players[client].witchCrowned, false);
	SQL_BindParamInt(stmt2, 34, g_players[client].tankRockSkeeted, false);
	SQL_BindParamInt(stmt2, 35, g_players[client].tankRockEaten, false);
	SQL_BindParamInt(stmt2, 36, g_players[client].alarmTriggered, false);
	SQL_BindParamFloat(stmt2, 37, g_players[client].avgInstaClearTime);
	if (!SQL_Execute(stmt2)) {
		LogError("Insert t_player_round_detail record failed. %s", insertError);
	}
	CloseHandle(stmt2);
*/
}

void ConnectCallback(Database db, const char[] error, any data) {
	if (db == INVALID_HANDLE) {
		LogError("Database connect failure: %s.", error);
		return;
	}

	g_db = db;
	g_db.SetCharset("utf8mb4");
}

void PlayerJoinQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (results.RowCount == 0) {
		char insert[2048];
		FormatEx(insert, sizeof(insert), "insert into t_player (steam_id, nickname) values ('%s', '%s')", g_players[client].steamId, g_players[client].nickname);
		LogMessage(insert);
		g_db.Query(DatabaseInsertCallback, insert);
/*
		char insert[2048];
		char insertError[2048];
		FormatEx(insert, sizeof(insert), "insert into t_player (steam_id, nickname) values (?, ?)");
		DBStatement stmt = SQL_PrepareQuery(g_db, insert, insertError, sizeof(insertError));
		SQL_BindParamString(stmt, 0, g_players[client].steamId, false);
		SQL_BindParamString(stmt, 1, g_players[client].nickname, false);

		LogMessage(insert);
		if (!SQL_Execute(stmt)) {
			LogError("Insert t_player record failed. %s", insertError);
		}
		CloseHandle(stmt);
*/
	}
	else {
		char update[2048];
		FormatEx(update, sizeof(update), "update t_player set nickname = '%s' where steam_id = '%s'", g_players[client].nickname, g_players[client].steamId);
		LogMessage(update);
		g_db.Query(DatabaseUpdateCallback, update);
/*
		char update[2048];
		char updateError[2048];
		FormatEx(update, sizeof(update), "update t_player set nickname = ? where steam_id = ?");
		DBStatement stmt = SQL_PrepareQuery(g_db, update, updateError, sizeof(updateError));
		SQL_BindParamString(stmt, 0, g_players[client].nickname, false);
		SQL_BindParamString(stmt, 1, g_players[client].steamId, false);

		LogMessage(update);
		if (!SQL_Execute(stmt)) {
			LogError("Update t_player record failed. %s", updateError);
		}
		CloseHandle(stmt);
*/
	}
}

void DatabaseInsertCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (!StrEqual(error, "")) {
		LogError("Insert error. %s", error);
	}
}

void DatabaseUpdateCallback(Database db, DBResultSet results, const char[] error, any data) {
	if (!StrEqual(error, "")) {
		LogError("Update error. %s", error);
	}
}

void InitCachedPlayerInfo(int client) {
	char ip[16];
	char steamId[32];
	char nickname[32];
	GetClientIP(client, ip, sizeof(ip));
	GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
	GetClientName(client, nickname, sizeof(nickname));

	g_players[client].ip = ip;
	g_players[client].steamId = steamId;
	g_players[client].nickname = nickname;

	ResetCachedPlayerInfo(client);
}

void ClearCachedPlayerInfo(int client) {
	ResetCachedPlayerInfo(client);
	g_players[client].ip = "";
	g_players[client].steamId = "";
	g_players[client].nickname = "";
	g_players[client].gametime = 0;
}

void ResetCachedPlayerInfo(int client) {
	g_players[client].gametime = RoundToNearest(GetEngineTime());
	g_players[client].headshot = 0;
	g_players[client].melee = 0;
	g_players[client].ciKilled = 0;
	g_players[client].smokerKilled = 0;
	g_players[client].boomerKilled = 0;
	g_players[client].hunterKilled = 0;
	g_players[client].spitterKilled = 0;
	g_players[client].jockeyKilled = 0;
	g_players[client].chargerKilled = 0;
	g_players[client].witchKilled = 0;
	g_players[client].tankKilled = 0;
	g_players[client].siDamageValue = 0;
	g_players[client].siDamagePercent = 0.0;
	g_players[client].totalFF = 0;
	g_players[client].totalFFReceived = 0;
	g_players[client].totalFFPercent = 0.0;
	g_players[client].adrenalineUsed = 0;
	g_players[client].pillsUsed = 0;
	g_players[client].medkitUsed = 0;
	g_players[client].teammateProtected = 0;
	g_players[client].teammateRevived = 0;
	g_players[client].incapacitated = 0;
	g_players[client].ledgeHanged = 0;
	g_players[client].missionCompleted = 0;
	g_players[client].missionLost = 0;
	g_players[client].smokerTongueCut = 0;
	g_players[client].smokerSelfCleared = 0;
	g_players[client].hunterSkeeted = 0;
	g_players[client].chargerLeveled = 0;
	g_players[client].witchCrowned = 0;
	g_players[client].tankRockSkeeted = 0;
	g_players[client].tankRockEaten = 0;
	g_players[client].alarmTriggered = 0;
	g_players[client].avgInstaClearTime = 0.0;
	g_players[client].instaClearTime.Clear();
}
