#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define TEAM_SPECTATOR	1
#define TEAM_SURVIVOR	2
#define TEAM_INFECTED	3

char g_rating[][] = {"E", "D", "C", "B", "A", "A+"};

enum struct PlayerInfo
{
	char steamId[32];
	char nickname[32];
	char connectTime[32];
	char connectIP[16];
	char country[64];
	char region[64];
	char city[64];
	char gametimeBuffer[32]; // calculated field
	int gametime;
	int headshot;
	int melee;
	int ciKilled;
	int siKilled; // calculated field
	int smokerKilled;
	int boomerKilled;
	int hunterKilled;
	int spitterKilled;
	int jockeyKilled;
	int chargerKilled;
	int witchKilled;
	int tankKilled;
	int totalFF;
	int totalFFReceived;
	int teammateProtected;
	int teammateRevived;
	int teammateIncapped;
	int teammateKilled;
	int ledgeHanged;
	int incapped;
	int dead;
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
	float totalHeadshotRate; // calculated field
	float avgSIDamagePercent;
	float avgTotalFFPercent;
	float avgInstaClearTime;
	char totalHeadshotRateStars[32]; // calculated field
	char avgSIDamagePercentStars[32]; // calculated field
	char avgTotalFFPercentStars[32]; // calculated field
	char avgInstaClearTimeStars[32]; // calculated field
	char comprehensiveRating[4]; // calculated field

	void Init() {
		this.steamId = "";
		this.nickname = "";
		this.connectTime = "";
		this.connectIP = "";
		this.country = "";
		this.region = "";
		this.city = "";
		this.gametimeBuffer = "";
		this.gametime = 0;
		this.headshot = 0;
		this.melee = 0;
		this.ciKilled = 0;
		this.siKilled = 0;
		this.smokerKilled = 0;
		this.boomerKilled = 0;
		this.hunterKilled = 0;
		this.spitterKilled = 0;
		this.jockeyKilled = 0;
		this.chargerKilled = 0;
		this.witchKilled = 0;
		this.tankKilled = 0;
		this.totalFF = 0;
		this.totalFFReceived = 0;
		this.teammateProtected = 0;
		this.teammateRevived = 0;
		this.teammateIncapped = 0;
		this.teammateKilled = 0;
		this.ledgeHanged = 0;
		this.incapped = 0;
		this.dead = 0;
		this.missionCompleted = 0;
		this.missionLost = 0;
		this.smokerTongueCut = 0;
		this.smokerSelfCleared = 0;
		this.hunterSkeeted = 0;
		this.chargerLeveled = 0;
		this.witchCrowned = 0;
		this.tankRockSkeeted = 0;
		this.tankRockEaten = 0;
		this.alarmTriggered = 0;
		this.totalHeadshotRate = 0.0;
		this.avgSIDamagePercent = 0.0;
		this.avgTotalFFPercent = 0.0;
		this.avgInstaClearTime = 0.0;
		this.totalHeadshotRateStars = "";
		this.avgSIDamagePercentStars = "";
		this.avgTotalFFPercentStars = "";
		this.avgInstaClearTimeStars = "";
		this.comprehensiveRating = "";
	}

	void InitWithDBResultSet(DBResultSet results) {
		results.FetchString(0, this.steamId, sizeof(this.steamId));
		results.FetchString(1, this.nickname, sizeof(this.nickname));
		results.FetchString(2, this.connectTime, sizeof(this.connectTime));
		results.FetchString(3, this.connectIP, sizeof(this.connectIP));
		results.FetchString(4, this.country, sizeof(this.country));
		results.FetchString(5, this.region, sizeof(this.region));
		results.FetchString(6, this.city, sizeof(this.city));
		this.gametime = results.FetchInt(7);
		this.headshot = results.FetchInt(8);
		this.melee = results.FetchInt(9);
		this.ciKilled = results.FetchInt(10);
		this.smokerKilled = results.FetchInt(11);
		this.boomerKilled = results.FetchInt(12);
		this.hunterKilled = results.FetchInt(13);
		this.spitterKilled = results.FetchInt(14);
		this.jockeyKilled = results.FetchInt(15);
		this.chargerKilled = results.FetchInt(16);
		this.witchKilled = results.FetchInt(17);
		this.tankKilled = results.FetchInt(18);
		this.totalFF = results.FetchInt(19);
		this.totalFFReceived = results.FetchInt(20);
		this.teammateProtected = results.FetchInt(21);
		this.teammateRevived = results.FetchInt(22);
		this.teammateIncapped = results.FetchInt(23);
		this.teammateKilled = results.FetchInt(24);
		this.ledgeHanged = results.FetchInt(25);
		this.incapped = results.FetchInt(26);
		this.dead = results.FetchInt(27);
		this.missionCompleted = results.FetchInt(28);
		this.missionLost = results.FetchInt(29);
		this.smokerTongueCut = results.FetchInt(30);
		this.smokerSelfCleared = results.FetchInt(31);
		this.hunterSkeeted = results.FetchInt(32);
		this.chargerLeveled = results.FetchInt(33);
		this.witchCrowned = results.FetchInt(34);
		this.tankRockSkeeted = results.FetchInt(35);
		this.tankRockEaten = results.FetchInt(36);
		this.alarmTriggered = results.FetchInt(37);
		this.avgSIDamagePercent = results.FetchFloat(38);
		this.avgTotalFFPercent = results.FetchFloat(39);
		this.avgInstaClearTime = results.FetchFloat(40);

		this.siKilled = this.smokerKilled + this.boomerKilled + this.hunterKilled + this.spitterKilled + this.jockeyKilled + this.chargerKilled + this.witchKilled + this.tankKilled;
		this.totalHeadshotRate = this.headshot / float(this.ciKilled + this.siKilled);

		int seconds = this.gametime % 60;
		int minutes = this.gametime / 60 % 60;
		int hours = this.gametime / 60 / 60;
		if (hours > 0) Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%dh %dm %ds", hours, minutes, seconds);
		else if (minutes > 0) Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%dm %ds", minutes, seconds);
		else Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%ds", seconds);

		if (this.totalHeadshotRate >= 0.50) this.totalHeadshotRateStars = "★★★★★";
		else if (this.totalHeadshotRate >= 0.40) this.totalHeadshotRateStars = "★★★★";
		else if (this.totalHeadshotRate >= 0.30) this.totalHeadshotRateStars = "★★★";
		else if (this.totalHeadshotRate >= 0.20) this.totalHeadshotRateStars = "★★";
		else if (this.totalHeadshotRate >= 0.10) this.totalHeadshotRateStars = "★";
		else this.totalHeadshotRateStars = "";

		if (this.avgSIDamagePercent >= 0.50) this.avgSIDamagePercentStars = "★★★★★";
		else if (this.avgSIDamagePercent >= 0.45) this.avgSIDamagePercentStars = "★★★★";
		else if (this.avgSIDamagePercent >= 0.40) this.avgSIDamagePercentStars = "★★★";
		else if (this.avgSIDamagePercent >= 0.35) this.avgSIDamagePercentStars = "★★";
		else if (this.avgSIDamagePercent >= 0.30) this.avgSIDamagePercentStars = "★";
		else this.avgSIDamagePercentStars = "";

		if (this.avgTotalFFPercent <= 0.05) this.avgTotalFFPercentStars = "★★★★★";
		else if (this.avgTotalFFPercent <= 0.06) this.avgTotalFFPercentStars = "★★★★";
		else if (this.avgTotalFFPercent <= 0.07) this.avgTotalFFPercentStars = "★★★";
		else if (this.avgTotalFFPercent <= 0.08) this.avgTotalFFPercentStars = "★★";
		else if (this.avgTotalFFPercent <= 0.09) this.avgTotalFFPercentStars = "★";
		else this.avgTotalFFPercentStars = "";

		if (this.avgInstaClearTime > 0 && this.avgInstaClearTime <= 1.25) this.avgInstaClearTimeStars = "★★★★★";
		else if (this.avgInstaClearTime <= 1.50) this.avgInstaClearTimeStars = "★★★★";
		else if (this.avgInstaClearTime <= 1.75) this.avgInstaClearTimeStars = "★★★";
		else if (this.avgInstaClearTime <= 2.00) this.avgInstaClearTimeStars = "★★";
		else if (this.avgInstaClearTime <= 2.25) this.avgInstaClearTimeStars = "★";
		else this.avgInstaClearTimeStars = "";

		int ratingIndex = RoundToCeil((strlen(this.totalHeadshotRateStars) + strlen(this.avgSIDamagePercentStars) + strlen(this.avgTotalFFPercentStars) + strlen(this.avgInstaClearTimeStars)) / 12.0);
		if (ratingIndex < 0) Format(this.comprehensiveRating, sizeof(this.comprehensiveRating), g_rating[0]);
		else if (ratingIndex > 5) Format(this.comprehensiveRating, sizeof(this.comprehensiveRating), g_rating[5]);
		else Format(this.comprehensiveRating, sizeof(this.comprehensiveRating), g_rating[ratingIndex]);
	}
}

enum struct PlayerRoundDetailInfo
{
	ArrayList recentQueryIdList;
	int recentQueryPageIndex;

	int roundDetailId;
	char createTime[32];
	char serverMap[32];
	char serverMode[32];
	int mapRound;
	char gametimeBuffer[32]; // calculated field
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
	int teammateIncapped;
	int teammateKilled;
	int ledgeHanged;
	int incapped;
	int dead;
	int smokerTongueCut;
	int smokerSelfCleared;
	int hunterSkeeted;
	int chargerLeveled;
	int witchCrowned;
	int tankRockSkeeted;
	int tankRockEaten;
	int alarmTriggered;
	float avgInstaClearTime;

	void Init() {
		this.recentQueryIdList = new ArrayList();
		this.recentQueryPageIndex = 0;

		this.roundDetailId = 0;
		this.createTime = "";
		this.serverMap = "";
		this.serverMode = "";
		this.mapRound = 0;
		this.gametimeBuffer = "";
		this.gametime = 0;
		this.headshot = 0;
		this.melee = 0;
		this.ciKilled = 0;
		this.smokerKilled = 0;
		this.boomerKilled = 0;
		this.hunterKilled = 0;
		this.spitterKilled = 0;
		this.jockeyKilled = 0;
		this.chargerKilled = 0;
		this.witchKilled = 0;
		this.tankKilled = 0;
		this.siDamageValue = 0;
		this.siDamagePercent = 0.0;
		this.totalFF = 0;
		this.totalFFReceived = 0;
		this.totalFFPercent = 0.0;
		this.adrenalineUsed = 0;
		this.pillsUsed = 0;
		this.medkitUsed = 0;
		this.teammateProtected = 0;
		this.teammateRevived = 0;
		this.teammateIncapped = 0;
		this.teammateKilled = 0;
		this.ledgeHanged = 0;
		this.incapped = 0;
		this.dead = 0;
		this.smokerTongueCut = 0;
		this.smokerSelfCleared = 0;
		this.hunterSkeeted = 0;
		this.chargerLeveled = 0;
		this.witchCrowned = 0;
		this.tankRockSkeeted = 0;
		this.tankRockEaten = 0;
		this.alarmTriggered = 0;
		this.avgInstaClearTime = 0.0;
	}

	void InitWithDBResultSet(DBResultSet results) {
		this.roundDetailId = results.FetchInt(0);
		results.FetchString(1, this.createTime, sizeof(this.createTime));
		results.FetchString(2, this.serverMap, sizeof(this.serverMap));
		results.FetchString(3, this.serverMode, sizeof(this.serverMode));
		this.mapRound = results.FetchInt(4);
		this.gametime = results.FetchInt(5);
		this.headshot = results.FetchInt(6);
		this.melee = results.FetchInt(7);
		this.ciKilled = results.FetchInt(8);
		this.smokerKilled = results.FetchInt(9);
		this.boomerKilled = results.FetchInt(10);
		this.hunterKilled = results.FetchInt(11);
		this.spitterKilled = results.FetchInt(12);
		this.jockeyKilled = results.FetchInt(13);
		this.chargerKilled = results.FetchInt(14);
		this.witchKilled = results.FetchInt(15);
		this.tankKilled = results.FetchInt(16);
		this.siDamageValue = results.FetchInt(17);
		this.siDamagePercent = results.FetchFloat(18);
		this.totalFF = results.FetchInt(19);
		this.totalFFReceived = results.FetchInt(20);
		this.totalFFPercent = results.FetchFloat(21);
		this.adrenalineUsed = results.FetchInt(22);
		this.pillsUsed = results.FetchInt(23);
		this.medkitUsed = results.FetchInt(24);
		this.teammateProtected = results.FetchInt(25);
		this.teammateRevived = results.FetchInt(26);
		this.teammateIncapped = results.FetchInt(27);
		this.teammateKilled = results.FetchInt(28);
		this.ledgeHanged = results.FetchInt(29);
		this.incapped = results.FetchInt(30);
		this.dead = results.FetchInt(31);
		this.smokerTongueCut = results.FetchInt(32);
		this.smokerSelfCleared = results.FetchInt(33);
		this.hunterSkeeted = results.FetchInt(34);
		this.chargerLeveled = results.FetchInt(35);
		this.witchCrowned = results.FetchInt(36);
		this.tankRockSkeeted = results.FetchInt(37);
		this.tankRockEaten = results.FetchInt(38);
		this.alarmTriggered = results.FetchInt(39);
		this.avgInstaClearTime = results.FetchFloat(40);

		int seconds = this.gametime % 60;
		int minutes = this.gametime / 60 % 60;
		int hours = this.gametime / 60 / 60;
		if (hours > 0) Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%dh %dm %ds", hours, minutes, seconds);
		else if (minutes > 0) Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%dm %ds", minutes, seconds);
		else Format(this.gametimeBuffer, sizeof(this.gametimeBuffer), "%ds", seconds);
	}
}

enum struct PlayerConnectLogInfo
{
	ArrayList recentQueryIdList;
	int recentQueryPageIndex;

	int connectLogId;
	char connectTime[32];
	char serverName[32];
	char serverIP[16];
	char serverPort[8];
	char connectIP[16];
	char country[64];
	char region[64];
	char city[64];
	float latitude;
	float longitude;

	void Init() {
		this.recentQueryIdList = new ArrayList();
		this.recentQueryPageIndex = 0;

		this.connectLogId = 0;
		this.connectTime = "";
		this.serverName = "";
		this.serverIP = "";
		this.serverPort = "";
		this.connectIP = "";
		this.country = "";
		this.region = "";
		this.city = "";
		this.latitude = 0.0;
		this.longitude = 0.0;
	}

	void InitWithDBResultSet(DBResultSet results) {
		this.connectLogId = results.FetchInt(0);
		results.FetchString(1, this.connectTime, sizeof(this.connectTime));
		results.FetchString(2, this.serverName, sizeof(this.serverName));
		results.FetchString(3, this.serverIP, sizeof(this.serverIP));
		results.FetchString(4, this.serverPort, sizeof(this.serverPort));
		results.FetchString(5, this.connectIP, sizeof(this.connectIP));
		results.FetchString(6, this.country, sizeof(this.country));
		results.FetchString(7, this.region, sizeof(this.region));
		results.FetchString(8, this.city, sizeof(this.city));
		this.latitude = results.FetchFloat(9);
		this.longitude = results.FetchFloat(10);
	}
}

Database g_db;
ConVar g_cvEnableTab;
ConVar g_cvEnableSpec;
ConVar g_cvSensitiveOnlyAdmin;
PlayerInfo g_playerRecentLookingAt[MAXPLAYERS + 1];
PlayerRoundDetailInfo g_playerRecentLookingAtRound[MAXPLAYERS + 1];
PlayerConnectLogInfo g_playerRecentLookingAtConnectLog[MAXPLAYERS + 1];
int g_playerRecentLookingAtChatLogPageIndex[MAXPLAYERS + 1];
int g_btnPressed[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "L4D2 Player Stats Panel",
	author = "HatsuneImagine",
	description = "Query & Show player stats in the panel from databases.",
	version = "2.3",
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart() {
	g_cvEnableTab = CreateConVar("l4d2_player_stats_panel_enable_tab", "1", "Enable holding 'TAB' button for a while to open player stats panel. (0=No, 1=Yes)");
	g_cvEnableSpec = CreateConVar("l4d2_player_stats_panel_enable_spec", "1", "Enable auto open player stats panel when spectating other players. (0=No, 1=Yes)");
	g_cvSensitiveOnlyAdmin = CreateConVar("l4d2_player_stats_panel_sensitive_only_admin", "0", "Display sensitive data only to admins. (0=No, 1=Yes)");
	RegConsoleCmd("sm_mystats", Cmd_Show_Panel, "Show stats panel.");
	RegConsoleCmd("sm_my_stats", Cmd_Show_Panel, "Show stats panel.");
	RegConsoleCmd("sm_show_stats", Cmd_Show_Panel, "Show stats panel.");
	RegConsoleCmd("sm_stats", Cmd_Stats_Menu, "Open player select menu.");

	for (int i = 0; i < MAXPLAYERS + 1; i++) {
		g_playerRecentLookingAt[i].Init();
		g_playerRecentLookingAtRound[i].Init();
		g_playerRecentLookingAtConnectLog[i].Init();
		g_playerRecentLookingAtChatLogPageIndex[i] = 0;
		g_btnPressed[i] = 0;
	}

	Database.Connect(ConnectCallback, "player_stats");
	LoadTranslations("l4d2_player_stats_panel.phrases");
	AutoExecConfig(true, "l4d2_player_stats_panel");
	AddCommandListener(SpecCommandListener, "spec_prev");
	AddCommandListener(SpecCommandListener, "spec_next");
}

public void OnPluginEnd() {
	CloseHandle(g_db);
}

public void OnConfigsExecuted() {
	if (!IsValidHandle(g_db)) {
		Database.Connect(ConnectCallback, "player_stats");
	}
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2]) {
	if (g_cvEnableTab.BoolValue && (buttons & IN_SCORE)) {
		g_btnPressed[client]++;
		if (g_btnPressed[client] > 50) {
			g_btnPressed[client] = 0;
			char steamId[32];
			if (GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId))) {
				SQL_QueryPlayer(client, steamId);
			}
		}
	}
}

Action SpecCommandListener(int client, char[] command, int argc) {
	if (g_cvEnableSpec.BoolValue && IsValidClient(client)) {
		RequestFrame(OnNextFrame, client);
	}
	return Plugin_Continue;
}

void OnNextFrame(int client) {
	int viewingClient = GetClientViewingPlayer(client);
	if (IsValidClient(viewingClient)) {
		char steamId[32];
		if (IsFakeClient(viewingClient)) {
			char buffer[128];
			Panel panel = new Panel();
			Format(buffer, sizeof(buffer), "▸ %N%T", viewingClient, "PLAYER_STATS", client);
			panel.SetTitle(buffer, false);
			panel.DrawText("————————————————————");

			Format(buffer, sizeof(buffer), "SteamID: BOT");
			panel.DrawText(buffer);

			panel.Send(client, EmptyPanelHandler, MENU_TIME_FOREVER);
			g_btnPressed[client] = 0;
		}
		else if (GetClientAuthId(viewingClient, AuthId_Steam2, steamId, sizeof(steamId))) {
			SQL_QueryPlayer(client, steamId);
		}
	}
}

Action Cmd_Show_Panel(int client, int args) {
	char steamId[32];
	GetCmdArgString(steamId, sizeof(steamId));
	HandleSpecialChar(steamId, sizeof(steamId));
	TrimString(steamId);

	if (strlen(steamId) > 0) {
		SQL_QueryPlayer(client, steamId);
	}
	else if (GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId))) {
		SQL_QueryPlayer(client, steamId);
	}

	return Plugin_Continue;
}

Action Cmd_Stats_Menu(int client, int args) {
	char title[128];
	char info[8];
	char display[32];
	Menu menu = new Menu(SelectPlayer_MenuHandler);
	Format(title, sizeof(title), "▸ %T", "SELECT_PLAYER", client);
	menu.SetTitle(title);
	for (int i = 1; i <= MaxClients; i++) {
		if (IsRealClient(i)) {
			Format(info, sizeof(info), "%d", i);
			Format(display, sizeof(display), "%N", i);
			menu.AddItem(info, display);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Continue;
}

int SelectPlayer_MenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char info[8];
			char steamId[32];
			menu.GetItem(param2, info, sizeof(info));
			if (GetClientAuthId(StringToInt(info), AuthId_Steam2, steamId, sizeof(steamId))) {
				SQL_QueryPlayer(param1, steamId);
			}
		}

		case MenuAction_Cancel: {
			delete menu;
		}

		case MenuAction_End: {
			delete menu;
		}
	}
	return 0;
}

void SQL_QueryPlayer(int client, char[] steamId) {
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"p.steam_id, "
	...	"p.nickname, "
	...	"(select connect_time from t_player_connect_log where steam_id = p.steam_id order by id desc limit 1) connect_time, "
	...	"(select connect_ip from t_player_connect_log where steam_id = p.steam_id order by id desc limit 1) ip, "
	...	"(select ip_country from t_player_connect_log where steam_id = p.steam_id order by id desc limit 1) country, "
	...	"(select ip_region from t_player_connect_log where steam_id = p.steam_id order by id desc limit 1) region, "
	...	"(select ip_city from t_player_connect_log where steam_id = p.steam_id order by id desc limit 1) city, "
	...	"p.gametime, "
	...	"p.headshot, "
	...	"p.melee, "
	...	"p.ci_killed, "
	...	"p.smoker_killed, "
	...	"p.boomer_killed, "
	...	"p.hunter_killed, "
	...	"p.spitter_killed, "
	...	"p.jockey_killed, "
	...	"p.charger_killed, "
	...	"p.witch_killed, "
	...	"p.tank_killed, "
	...	"p.total_ff, "
	...	"p.total_ff_received, "
	...	"p.teammate_protected, "
	...	"p.teammate_revived, "
	...	"p.teammate_incapped, "
	...	"p.teammate_killed, "
	...	"p.ledge_hanged, "
	...	"p.incapped, "
	...	"p.dead, "
	...	"p.mission_completed, "
	...	"p.mission_lost, "
	...	"p.smoker_tongue_cut, "
	...	"p.smoker_self_cleared, "
	...	"p.hunter_skeeted, "
	...	"p.charger_leveled, "
	...	"p.witch_crowned, "
	...	"p.tank_rock_skeeted, "
	...	"p.tank_rock_eaten, "
	...	"p.alarm_triggered, "
	...	"ifnull((select avg(si_damage_percent) from t_player_round_detail where steam_id = p.steam_id and si_damage_percent > 0), 0.0) avg_si_damage_percent, "
	...	"ifnull((select avg(total_ff_percent) from t_player_round_detail where steam_id = p.steam_id and total_ff_percent < 1), 0.0) avg_total_ff_percent, "
	...	"ifnull((select avg(avg_insta_clear_time) from t_player_round_detail where steam_id = p.steam_id and avg_insta_clear_time > 0), 0.0) avg_insta_clear_time "
	...	"from t_player p "
	...	"where p.steam_id = '%s'"
	, steamId);

	LogMessage(query);
	g_db.Query(PlayerQueryCallback, query, client);
}

void PlayerQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player info error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}
	if (results.RowCount == 0) {
		ReplyToCommand(client, "%t", "PLAYER_NOT_EXISTS");
		return;
	}
	if (results.FetchRow()) {
		g_playerRecentLookingAt[client].InitWithDBResultSet(results);
		ShowPlayerStatsPanel(client);
	}
}

void ShowPlayerStatsPanel(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %s%T", g_playerRecentLookingAt[client].nickname, "PLAYER_STATS", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "SteamID: %s", g_playerRecentLookingAt[client].steamId);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "RECENT_CONNECT_TIME", client, g_playerRecentLookingAt[client].connectTime);
	panel.DrawText(buffer);

	if (!g_cvSensitiveOnlyAdmin.BoolValue || g_cvSensitiveOnlyAdmin.BoolValue && IsClientAdmin(client)) {
		Format(buffer, sizeof(buffer), "%T: %s", "RECENT_CONNECT_IP", client, g_playerRecentLookingAt[client].connectIP);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "COUNTRY", client, g_playerRecentLookingAt[client].country);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "REGION", client, g_playerRecentLookingAt[client].region);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "CITY", client, g_playerRecentLookingAt[client].city);
		panel.DrawText(buffer);
	}

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "%T: %s", "GAMETIME", client, g_playerRecentLookingAt[client].gametimeBuffer);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CI_KILLED", client, g_playerRecentLookingAt[client].ciKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SI_KILLED", client, g_playerRecentLookingAt[client].siKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MISSION_COMPLETED", client, g_playerRecentLookingAt[client].missionCompleted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MISSION_LOST", client, g_playerRecentLookingAt[client].missionLost);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "%T: %.2f%%  %s", "AVG_SI_DAMAGE_PERCENT", client, g_playerRecentLookingAt[client].avgSIDamagePercent * 100, g_playerRecentLookingAt[client].avgSIDamagePercentStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%%  %s", "AVG_FF_PERCENT", client, g_playerRecentLookingAt[client].avgTotalFFPercent * 100, g_playerRecentLookingAt[client].avgTotalFFPercentStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%T  %s", "AVG_INSTA_CLEAR_TIME", client, g_playerRecentLookingAt[client].avgInstaClearTime, "SECONDS", client, g_playerRecentLookingAt[client].avgInstaClearTimeStars);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "1. %T", "MORE_INFO", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerStatsPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int EmptyPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		g_btnPressed[param1] = 0;
		delete menu;
	}
	return 0;
}

int PlayerStatsPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 1) {
			ShowMoreInfoPanel(param1);
		}
		else {
			g_btnPressed[param1] = 0;
			delete menu;
		}
	}
	return 0;
}

void ShowMoreInfoPanel(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T", "MORE_INFO", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "1. %T", "DETAIL", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "2. %T", "RANK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "3. %T", "RECENT_ROUND_DETAIL", client);
	panel.DrawText(buffer);

	if (!g_cvSensitiveOnlyAdmin.BoolValue || g_cvSensitiveOnlyAdmin.BoolValue && IsClientAdmin(client)) {
		Format(buffer, sizeof(buffer), "4. %T", "RECENT_CONNECT_LOG", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "5. %T", "RECENT_CHAT_LOG", client);
		panel.DrawText(buffer);
	}

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	panel.DrawText(" ");

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, MoreInfoPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int MoreInfoPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 1) {
			ShowPlayerDetailPanel1(param1);
		}
		else if (param2 == 2) {
			SQL_QueryPlayerRank(param1, g_playerRecentLookingAt[param1].steamId);
		}
		else if (param2 == 3) {
			SQL_QueryPlayerRoundDetailList(param1, g_playerRecentLookingAt[param1].steamId, 0);
		}
		else if (param2 == 4 && (!g_cvSensitiveOnlyAdmin.BoolValue || g_cvSensitiveOnlyAdmin.BoolValue && IsClientAdmin(param1))) {
			SQL_QueryPlayerConnectLogList(param1, g_playerRecentLookingAt[param1].steamId, 0);
		}
		else if (param2 == 5 && (!g_cvSensitiveOnlyAdmin.BoolValue || g_cvSensitiveOnlyAdmin.BoolValue && IsClientAdmin(param1))) {
			SQL_QueryPlayerChatLogList(param1, g_playerRecentLookingAt[param1].steamId, 0);
		}
		else if (param2 == 8) {
			SQL_QueryPlayer(param1, g_playerRecentLookingAt[param1].steamId);
		}
		else if (param2 == 9) {
			ShowMoreInfoPanel(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowMoreInfoPanel(param1);
		}
	}
	return 0;
}

void ShowPlayerDetailPanel1(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T", "DETAIL", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "SteamID: %s", g_playerRecentLookingAt[client].steamId);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "NICKNAME", client, g_playerRecentLookingAt[client].nickname);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "GAMETIME", client, g_playerRecentLookingAt[client].gametimeBuffer);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HEADSHOT", client, g_playerRecentLookingAt[client].headshot);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MELEE", client, g_playerRecentLookingAt[client].melee);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CI_KILLED", client, g_playerRecentLookingAt[client].ciKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_KILLED", client, g_playerRecentLookingAt[client].smokerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "BOOMER_KILLED", client, g_playerRecentLookingAt[client].boomerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HUNTER_KILLED", client, g_playerRecentLookingAt[client].hunterKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SPITTER_KILLED", client, g_playerRecentLookingAt[client].spitterKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "JOCKEY_KILLED", client, g_playerRecentLookingAt[client].jockeyKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CHARGER_KILLED", client, g_playerRecentLookingAt[client].chargerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "WITCH_KILLED", client, g_playerRecentLookingAt[client].witchKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_KILLED", client, g_playerRecentLookingAt[client].tankKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TOTAL_FF", client, g_playerRecentLookingAt[client].totalFF);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TOTAL_FF_RECEIVED", client, g_playerRecentLookingAt[client].totalFFReceived);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerDetailPanel1Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerDetailPanel1Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowMoreInfoPanel(param1);
		}
		else if (param2 == 9) {
			ShowPlayerDetailPanel2(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerDetailPanel1(param1);
		}
	}
	return 0;
}

void ShowPlayerDetailPanel2(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T", "DETAIL", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_PROTECTED", client, g_playerRecentLookingAt[client].teammateProtected);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_REVIVED", client, g_playerRecentLookingAt[client].teammateRevived);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_INCAPPED", client, g_playerRecentLookingAt[client].teammateIncapped);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_KILLED", client, g_playerRecentLookingAt[client].teammateKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "LEDGE_HANGED", client, g_playerRecentLookingAt[client].ledgeHanged);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "INCAPPED", client, g_playerRecentLookingAt[client].incapped);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "DEAD", client, g_playerRecentLookingAt[client].dead);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MISSION_COMPLETED", client, g_playerRecentLookingAt[client].missionCompleted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MISSION_LOST", client, g_playerRecentLookingAt[client].missionLost);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerDetailPanel2Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerDetailPanel2Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerDetailPanel1(param1);
		}
		else if (param2 == 9) {
			ShowPlayerDetailPanel3(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerDetailPanel2(param1);
		}
	}
	return 0;
}

void ShowPlayerDetailPanel3(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T", "DETAIL", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_TONGUE_CUT", client, g_playerRecentLookingAt[client].smokerTongueCut);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_SELF_CLEARED", client, g_playerRecentLookingAt[client].smokerSelfCleared);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HUNTER_SKEETED", client, g_playerRecentLookingAt[client].hunterSkeeted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CHARGER_LEVELED", client, g_playerRecentLookingAt[client].chargerLeveled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "WITCH_CROWNED", client, g_playerRecentLookingAt[client].witchCrowned);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_ROCK_SKEETED", client, g_playerRecentLookingAt[client].tankRockSkeeted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_ROCK_EATEN", client, g_playerRecentLookingAt[client].tankRockEaten);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "ALARM_TRIGGERED", client, g_playerRecentLookingAt[client].alarmTriggered);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerDetailPanel3Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerDetailPanel3Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerDetailPanel2(param1);
		}
		else if (param2 == 9) {
			ShowPlayerDetailPanel4(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerDetailPanel3(param1);
		}
	}
	return 0;
}

void ShowPlayerDetailPanel4(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T", "DETAIL", client);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %.2f%%  %s", "TOTAL_HEADSHOT_RATE", client, g_playerRecentLookingAt[client].totalHeadshotRate * 100, g_playerRecentLookingAt[client].totalHeadshotRateStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%%  %s", "AVG_SI_DAMAGE_PERCENT", client, g_playerRecentLookingAt[client].avgSIDamagePercent * 100, g_playerRecentLookingAt[client].avgSIDamagePercentStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%%  %s", "AVG_FF_PERCENT", client, g_playerRecentLookingAt[client].avgTotalFFPercent * 100, g_playerRecentLookingAt[client].avgTotalFFPercentStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%T  %s", "AVG_INSTA_CLEAR_TIME", client, g_playerRecentLookingAt[client].avgInstaClearTime, "SECONDS", client, g_playerRecentLookingAt[client].avgInstaClearTimeStars);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: [%s]", "COMPREHENSIVE_RATING", client, g_playerRecentLookingAt[client].comprehensiveRating);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	panel.DrawText(" ");

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerDetailPanel4Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerDetailPanel4Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerDetailPanel3(param1);
		}
		else if (param2 == 9) {
			ShowPlayerDetailPanel4(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerDetailPanel4(param1);
		}
	}
	return 0;
}

void SQL_QueryPlayerRank(int client, char[] steamId) {
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select b.total_player, a.player_rank "
	...	"from "
	...	"("
	...	"select tmp.steam_id, row_number() over (order by tmp.total_kill desc) player_rank from ( "
	...	"select p.steam_id, p.ci_killed + p.smoker_killed + p.boomer_killed + p.hunter_killed + p.spitter_killed + p.jockey_killed + p.charger_killed + p.witch_killed + p.tank_killed total_kill  "
	...	"from t_player p "
	...	") tmp "
	...	") a, "
	...	"("
	...	"select count(0) total_player from t_player"
	...	") b "
	...	"where a.steam_id = '%s'"
	, steamId);

	LogMessage(query);
	g_db.Query(PlayerRankQueryCallback, query, client);
}

void PlayerRankQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player rank info error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}
	if (results.RowCount == 0) {
		ReplyToCommand(client, "%t", "PLAYER_RANK_NOT_EXISTS");
		return;
	}
	if (results.FetchRow()) {
		int totalPlayer = results.FetchInt(0);
		int playerRank = results.FetchInt(1);
		char buffer[128];
		Panel panel = new Panel();
		Format(buffer, sizeof(buffer), "▸ %T", "RANK", client);
		panel.SetTitle(buffer, false);
		panel.DrawText("————————————————————");

		Format(buffer, sizeof(buffer), "%T: #%d", "PLAYER_RANK", client, playerRank);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %d", "TOTAL_PLAYER", client, totalPlayer);
		panel.DrawText(buffer);

		panel.DrawText(" ");
		Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
		panel.DrawText(buffer);

		panel.DrawText(" ");

		Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
		panel.DrawText(buffer);

		panel.Send(client, PlayerRankPanelHandler, MENU_TIME_FOREVER);
		g_btnPressed[client] = 0;
	}
}

int PlayerRankPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowMoreInfoPanel(param1);
		}
		else if (param2 == 9) {
			SQL_QueryPlayerRank(param1, g_playerRecentLookingAt[param1].steamId);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			SQL_QueryPlayerRank(param1, g_playerRecentLookingAt[param1].steamId);
		}
	}
	return 0;
}

void SQL_QueryPlayerRoundDetailList(int client, char[] steamId, int pageIndex) {
	g_playerRecentLookingAtRound[client].recentQueryPageIndex = pageIndex;
	int limit = 5;
	int offset = pageIndex * limit;
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"prd.id, "
	...	"prd.create_time, "
	...	"prd.server_map "
	...	"from t_player_round_detail prd "
	...	"where prd.steam_id = '%s' "
	...	"order by prd.id desc limit %d, %d"
	, steamId, offset, limit);

	LogMessage(query);
	g_db.Query(PlayerRoundDetailListQueryCallback, query, client);
}

void PlayerRoundDetailListQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player round detail list error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}

	g_playerRecentLookingAtRound[client].recentQueryIdList.Clear();

	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T  %T: %d", "RECENT_ROUND_DETAIL", client, "PAGE", client, g_playerRecentLookingAtRound[client].recentQueryPageIndex + 1);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	if (results.RowCount == 0) {
		panel.DrawText(" ");
		Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
		panel.DrawText(buffer);

		panel.Send(client, PlayerRoundDetailListPanelHandler, MENU_TIME_FOREVER);
		g_btnPressed[client] = 0;
		return;
	}

	int count = 1;
	while (results.FetchRow()) {
		int roundDetailId;
		char createTime[32];
		char serverMap[32];

		roundDetailId = results.FetchInt(0);
		results.FetchString(1, createTime, sizeof(createTime));
		results.FetchString(2, serverMap, sizeof(serverMap));

		g_playerRecentLookingAtRound[client].recentQueryIdList.Push(roundDetailId);

		Format(buffer, sizeof(buffer), "%d. %T #%d", count++, "ROUND", client, roundDetailId);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "SERVER_MAP", client, serverMap);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "TIME", client, createTime);
		panel.DrawText(buffer);

		panel.DrawText(" ");
	}

	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerRoundDetailListPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerRoundDetailListPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			if (g_playerRecentLookingAtRound[param1].recentQueryPageIndex > 0) SQL_QueryPlayerRoundDetailList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtRound[param1].recentQueryPageIndex - 1);
			else ShowMoreInfoPanel(param1);
		}
		else if (param2 == 9) {
			SQL_QueryPlayerRoundDetailList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtRound[param1].recentQueryPageIndex + 1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else if (param2 - 1 >= 0 && param2 - 1 < g_playerRecentLookingAtRound[param1].recentQueryIdList.Length) {
			SQL_QueryPlayerRoundDetail(param1, g_playerRecentLookingAtRound[param1].recentQueryIdList.Get(param2 - 1));
		}
		else {
			SQL_QueryPlayerRoundDetailList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtRound[param1].recentQueryPageIndex);
		}
	}
	return 0;
}

void SQL_QueryPlayerRoundDetail(int client, int roundDetailId) {
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"prd.id, "
	...	"prd.create_time, "
	...	"prd.server_map, "
	...	"prd.server_mode, "
	...	"prd.map_round, "
	...	"prd.gametime, "
	...	"prd.headshot, "
	...	"prd.melee, "
	...	"prd.ci_killed, "
	...	"prd.smoker_killed, "
	...	"prd.boomer_killed, "
	...	"prd.hunter_killed, "
	...	"prd.spitter_killed, "
	...	"prd.jockey_killed, "
	...	"prd.charger_killed, "
	...	"prd.witch_killed, "
	...	"prd.tank_killed, "
	...	"prd.si_damage_value, "
	...	"prd.si_damage_percent, "
	...	"prd.total_ff, "
	...	"prd.total_ff_received, "
	...	"prd.total_ff_percent, "
	...	"prd.adrenaline_used, "
	...	"prd.pills_used, "
	...	"prd.medkit_used, "
	...	"prd.teammate_protected, "
	...	"prd.teammate_revived, "
	...	"prd.teammate_incapped, "
	...	"prd.teammate_killed, "
	...	"prd.ledge_hanged, "
	...	"prd.incapped, "
	...	"prd.dead, "
	...	"prd.smoker_tongue_cut, "
	...	"prd.smoker_self_cleared, "
	...	"prd.hunter_skeeted, "
	...	"prd.charger_leveled, "
	...	"prd.witch_crowned, "
	...	"prd.tank_rock_skeeted, "
	...	"prd.tank_rock_eaten, "
	...	"prd.alarm_triggered, "
	...	"prd.avg_insta_clear_time "
	...	"from t_player_round_detail prd "
	...	"where prd.id = %d"
	, roundDetailId);

	LogMessage(query);
	g_db.Query(PlayerRoundDetailQueryCallback, query, client);
}

void PlayerRoundDetailQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player round detail error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}
	if (results.RowCount == 0) {
		ReplyToCommand(client, "%t", "PLAYER_ROUND_DETAIL_NOT_EXISTS");
		return;
	}
	if (results.FetchRow()) {
		g_playerRecentLookingAtRound[client].InitWithDBResultSet(results);
		ShowPlayerRoundDetailPanel1(client);
	}
}

void ShowPlayerRoundDetailPanel1(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T #%d", "ROUND", client, g_playerRecentLookingAtRound[client].roundDetailId);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %s", "GAMETIME_ROUND", client, g_playerRecentLookingAtRound[client].gametimeBuffer);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "SteamID: %s", g_playerRecentLookingAt[client].steamId);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "NICKNAME", client, g_playerRecentLookingAt[client].nickname);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "SERVER_MAP", client, g_playerRecentLookingAtRound[client].serverMap);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "SERVER_MODE", client, g_playerRecentLookingAtRound[client].serverMode);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MAP_ROUND", client, g_playerRecentLookingAtRound[client].mapRound);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HEADSHOT", client, g_playerRecentLookingAtRound[client].headshot);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MELEE", client, g_playerRecentLookingAtRound[client].melee);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CI_KILLED", client, g_playerRecentLookingAtRound[client].ciKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_KILLED", client, g_playerRecentLookingAtRound[client].smokerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "BOOMER_KILLED", client, g_playerRecentLookingAtRound[client].boomerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HUNTER_KILLED", client, g_playerRecentLookingAtRound[client].hunterKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SPITTER_KILLED", client, g_playerRecentLookingAtRound[client].spitterKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "JOCKEY_KILLED", client, g_playerRecentLookingAtRound[client].jockeyKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CHARGER_KILLED", client, g_playerRecentLookingAtRound[client].chargerKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "WITCH_KILLED", client, g_playerRecentLookingAtRound[client].witchKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_KILLED", client, g_playerRecentLookingAtRound[client].tankKilled);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerRoundDetailPanel1Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerRoundDetailPanel1Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			SQL_QueryPlayerRoundDetailList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtRound[param1].recentQueryPageIndex);
		}
		else if (param2 == 9) {
			ShowPlayerRoundDetailPanel2(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerRoundDetailPanel1(param1);
		}
	}
	return 0;
}

void ShowPlayerRoundDetailPanel2(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T #%d", "ROUND", client, g_playerRecentLookingAtRound[client].roundDetailId);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %d", "SI_DAMAGE_VALUE", client, g_playerRecentLookingAtRound[client].siDamageValue);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d%%", "SI_DAMAGE_PERCENT", client, RoundToNearest(g_playerRecentLookingAtRound[client].siDamagePercent * 100));
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TOTAL_FF", client, g_playerRecentLookingAtRound[client].totalFF);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TOTAL_FF_RECEIVED", client, g_playerRecentLookingAtRound[client].totalFFReceived);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d%%", "TOTAL_FF_PERCENT", client, RoundToNearest(g_playerRecentLookingAtRound[client].totalFFPercent * 100));
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "ADRENALINE_USED", client, g_playerRecentLookingAtRound[client].adrenalineUsed);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "PILLS_USED", client, g_playerRecentLookingAtRound[client].pillsUsed);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "MEDKIT_USED", client, g_playerRecentLookingAtRound[client].medkitUsed);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerRoundDetailPanel2Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerRoundDetailPanel2Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerRoundDetailPanel1(param1);
		}
		else if (param2 == 9) {
			ShowPlayerRoundDetailPanel3(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerRoundDetailPanel2(param1);
		}
	}
	return 0;
}

void ShowPlayerRoundDetailPanel3(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T #%d", "ROUND", client, g_playerRecentLookingAtRound[client].roundDetailId);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_PROTECTED", client, g_playerRecentLookingAtRound[client].teammateProtected);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_REVIVED", client, g_playerRecentLookingAtRound[client].teammateRevived);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_INCAPPED", client, g_playerRecentLookingAtRound[client].teammateIncapped);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TEAMMATE_KILLED", client, g_playerRecentLookingAtRound[client].teammateKilled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "LEDGE_HANGED", client, g_playerRecentLookingAtRound[client].ledgeHanged);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "INCAPPED", client, g_playerRecentLookingAtRound[client].incapped);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "DEAD", client, g_playerRecentLookingAtRound[client].dead);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerRoundDetailPanel3Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerRoundDetailPanel3Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerRoundDetailPanel2(param1);
		}
		else if (param2 == 9) {
			ShowPlayerRoundDetailPanel4(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerRoundDetailPanel3(param1);
		}
	}
	return 0;
}

void ShowPlayerRoundDetailPanel4(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T #%d", "ROUND", client, g_playerRecentLookingAtRound[client].roundDetailId);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_TONGUE_CUT", client, g_playerRecentLookingAtRound[client].smokerTongueCut);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "SMOKER_SELF_CLEARED", client, g_playerRecentLookingAtRound[client].smokerSelfCleared);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "HUNTER_SKEETED", client, g_playerRecentLookingAtRound[client].hunterSkeeted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "CHARGER_LEVELED", client, g_playerRecentLookingAtRound[client].chargerLeveled);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "WITCH_CROWNED", client, g_playerRecentLookingAtRound[client].witchCrowned);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_ROCK_SKEETED", client, g_playerRecentLookingAtRound[client].tankRockSkeeted);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "TANK_ROCK_EATEN", client, g_playerRecentLookingAtRound[client].tankRockEaten);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %d", "ALARM_TRIGGERED", client, g_playerRecentLookingAtRound[client].alarmTriggered);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.2f%T", "AVG_INSTA_CLEAR_TIME", client, g_playerRecentLookingAtRound[client].avgInstaClearTime, "SECONDS", client);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	panel.DrawText(" ");

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerRoundDetailPanel4Handler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerRoundDetailPanel4Handler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			ShowPlayerRoundDetailPanel3(param1);
		}
		else if (param2 == 9) {
			ShowPlayerRoundDetailPanel4(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerRoundDetailPanel4(param1);
		}
	}
	return 0;
}

void SQL_QueryPlayerConnectLogList(int client, char[] steamId, int pageIndex) {
	g_playerRecentLookingAtConnectLog[client].recentQueryPageIndex = pageIndex;
	int limit = 5;
	int offset = pageIndex * limit;
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"pcl.id, "
	...	"pcl.connect_time "
	...	"from t_player_connect_log pcl "
	...	"where pcl.steam_id = '%s' "
	...	"order by pcl.id desc limit %d, %d"
	, steamId, offset, limit);

	LogMessage(query);
	g_db.Query(PlayerConnectLogListQueryCallback, query, client);
}

void PlayerConnectLogListQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player connect log list error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}

	g_playerRecentLookingAtConnectLog[client].recentQueryIdList.Clear();

	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T  %T: %d", "RECENT_CONNECT_LOG", client, "PAGE", client, g_playerRecentLookingAtConnectLog[client].recentQueryPageIndex + 1);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	if (results.RowCount == 0) {
		panel.DrawText(" ");
		Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
		panel.DrawText(buffer);

		panel.Send(client, PlayerConnectLogListPanelHandler, MENU_TIME_FOREVER);
		g_btnPressed[client] = 0;
		return;
	}

	int count = 1;
	while (results.FetchRow()) {
		int connectLogId;
		char connectTime[32];

		connectLogId = results.FetchInt(0);
		results.FetchString(1, connectTime, sizeof(connectTime));

		g_playerRecentLookingAtConnectLog[client].recentQueryIdList.Push(connectLogId);

		Format(buffer, sizeof(buffer), "%d. %T #%d", count++, "CONNECT_LOG", client, connectLogId);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "%T: %s", "TIME", client, connectTime);
		panel.DrawText(buffer);

		panel.DrawText(" ");
	}

	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerConnectLogListPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerConnectLogListPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			if (g_playerRecentLookingAtConnectLog[param1].recentQueryPageIndex > 0) SQL_QueryPlayerConnectLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtConnectLog[param1].recentQueryPageIndex - 1);
			else ShowMoreInfoPanel(param1);
		}
		else if (param2 == 9) {
			SQL_QueryPlayerConnectLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtConnectLog[param1].recentQueryPageIndex + 1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else if (param2 - 1 >= 0 && param2 - 1 < g_playerRecentLookingAtConnectLog[param1].recentQueryIdList.Length) {
			SQL_QueryPlayerConnectLog(param1, g_playerRecentLookingAtConnectLog[param1].recentQueryIdList.Get(param2 - 1));
		}
		else {
			SQL_QueryPlayerConnectLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtConnectLog[param1].recentQueryPageIndex);
		}
	}
	return 0;
}

void SQL_QueryPlayerConnectLog(int client, int connectLogId) {
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"pcl.id, "
	...	"pcl.connect_time, "
	...	"ifnull(s.server_name, '<N/A>') server_name, "
	...	"ifnull(s.server_ip, '<N/A>') server_ip, "
	...	"ifnull(s.server_port, '<N/A>') server_port, "
	...	"pcl.connect_ip, "
	...	"pcl.ip_country, "
	...	"pcl.ip_region, "
	...	"pcl.ip_city, "
	...	"pcl.latitude, "
	...	"pcl.longitude "
	...	"from t_player_connect_log pcl "
	...	"left join t_server s on pcl.server_id = s.id "
	...	"where pcl.id = %d"
	, connectLogId);

	LogMessage(query);
	g_db.Query(PlayerConnectLogQueryCallback, query, client);
}

void PlayerConnectLogQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player connect log error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}
	if (results.RowCount == 0) {
		ReplyToCommand(client, "%t", "PLAYER_CONNECT_LOG_NOT_EXISTS");
		return;
	}
	if (results.FetchRow()) {
		g_playerRecentLookingAtConnectLog[client].InitWithDBResultSet(results);
		ShowPlayerConnectLogPanel(client);
	}
}

void ShowPlayerConnectLogPanel(int client) {
	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T #%d", "CONNECT_LOG", client, g_playerRecentLookingAtConnectLog[client].connectLogId);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	Format(buffer, sizeof(buffer), "SteamID: %s", g_playerRecentLookingAt[client].steamId);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "NICKNAME", client, g_playerRecentLookingAt[client].nickname);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "TIME", client, g_playerRecentLookingAtConnectLog[client].connectTime);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "SERVER_NAME", client, g_playerRecentLookingAtConnectLog[client].serverName);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s:%s", "SERVER_ADDRESS", client, g_playerRecentLookingAtConnectLog[client].serverIP, g_playerRecentLookingAtConnectLog[client].serverPort);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "IP: %s", g_playerRecentLookingAtConnectLog[client].connectIP);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "COUNTRY", client, g_playerRecentLookingAtConnectLog[client].country);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "REGION", client, g_playerRecentLookingAtConnectLog[client].region);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %s", "CITY", client, g_playerRecentLookingAtConnectLog[client].city);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.6f", "LATITUDE", client, g_playerRecentLookingAtConnectLog[client].latitude);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "%T: %.6f", "LONGITUDE", client, g_playerRecentLookingAtConnectLog[client].longitude);
	panel.DrawText(buffer);

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	panel.DrawText(" ");

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerConnectLogPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerConnectLogPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			SQL_QueryPlayerConnectLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtConnectLog[param1].recentQueryPageIndex);
		}
		else if (param2 == 9) {
			ShowPlayerConnectLogPanel(param1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			ShowPlayerConnectLogPanel(param1);
		}
	}
	return 0;
}

void SQL_QueryPlayerChatLogList(int client, char[] steamId, int pageIndex) {
	g_playerRecentLookingAtChatLogPageIndex[client] = pageIndex;
	int limit = 5;
	int offset = pageIndex * limit;
	char query[2048];
	FormatEx(query, sizeof(query), 
	"select "
	...	"pcl.create_time, "
	...	"pcl.content "
	...	"from t_player_chat_log pcl "
	...	"where pcl.steam_id = '%s' "
	...	"order by pcl.id desc limit %d, %d"
	, steamId, offset, limit);

	LogMessage(query);
	g_db.Query(PlayerChatLogListQueryCallback, query, client);
}

void PlayerChatLogListQueryCallback(Database db, DBResultSet results, const char[] error, any client) {
	if (strlen(error) > 0) {
		LogError("Query player chat log list error. %s", error);
		ReplyToCommand(client, "%t", "QUERY_ERROR");
		return;
	}

	char buffer[128];
	Panel panel = new Panel();
	Format(buffer, sizeof(buffer), "▸ %T  %T: %d", "RECENT_CHAT_LOG", client, "PAGE", client, g_playerRecentLookingAtChatLogPageIndex[client] + 1);
	panel.SetTitle(buffer, false);
	panel.DrawText("————————————————————");

	if (results.RowCount == 0) {
		panel.DrawText(" ");
		Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
		panel.DrawText(buffer);

		Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
		panel.DrawText(buffer);

		panel.Send(client, PlayerChatLogListPanelHandler, MENU_TIME_FOREVER);
		g_btnPressed[client] = 0;
		return;
	}

	while (results.FetchRow()) {
		char createTime[32];
		char content[128];

		results.FetchString(0, createTime, sizeof(createTime));
		results.FetchString(1, content, sizeof(content));

		Format(buffer, sizeof(buffer), "%s  %s", createTime, content);
		panel.DrawText(buffer);
	}

	panel.DrawText(" ");
	Format(buffer, sizeof(buffer), "8. %T", "BACK", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "9. %T", "NEXT", client);
	panel.DrawText(buffer);

	Format(buffer, sizeof(buffer), "0. %T", "EXIT", client);
	panel.DrawText(buffer);

	panel.Send(client, PlayerChatLogListPanelHandler, MENU_TIME_FOREVER);
	g_btnPressed[client] = 0;
}

int PlayerChatLogListPanelHandler(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (param2 == 8) {
			if (g_playerRecentLookingAtChatLogPageIndex[param1] > 0) SQL_QueryPlayerChatLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtChatLogPageIndex[param1] - 1);
			else ShowMoreInfoPanel(param1);
		}
		else if (param2 == 9) {
			SQL_QueryPlayerChatLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtChatLogPageIndex[param1] + 1);
		}
		else if (param2 == 10) {
			g_btnPressed[param1] = 0;
			delete menu;
		}
		else {
			SQL_QueryPlayerChatLogList(param1, g_playerRecentLookingAt[param1].steamId, g_playerRecentLookingAtChatLogPageIndex[param1]);
		}
	}
	return 0;
}


bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

bool IsRealClient(int client) {
	return IsValidClient(client) && !IsFakeClient(client);
}

bool IsClientAdmin(int client) {
	return GetUserAdmin(client) != INVALID_ADMIN_ID;
}

int GetClientViewingPlayer(int client) {
	int observerTarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	return observerTarget > 0 ? observerTarget : client;
}

void HandleSpecialChar(char[] str, int size) {
	ReplaceString(str, size, "\\", "\\\\");
	ReplaceString(str, size, "/", "\\/");
	ReplaceString(str, size, "\"", "\\\"");
	ReplaceString(str, size, "'", "\\'");
	ReplaceString(str, size, "-", "\\-");
	ReplaceString(str, size, "#", "\\#");
	ReplaceString(str, size, ";", "\\;");
	ReplaceString(str, size, "`", "\\`");
}

void ConnectCallback(Database db, const char[] error, any data) {
	if (!IsValidHandle(db)) {
		LogError("Database connect failure: %s.", error);
		return;
	}

	g_db = db;
	g_db.SetCharset("utf8mb4");
}
