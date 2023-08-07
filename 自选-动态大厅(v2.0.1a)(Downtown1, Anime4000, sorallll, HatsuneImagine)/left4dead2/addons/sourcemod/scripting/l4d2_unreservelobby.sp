#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>

#define PLUGIN_NAME				"L4D 1/2 Remove Lobby Reservation"
#define PLUGIN_AUTHOR			"Downtown1, Anime4000, sorallll, HatsuneImagine"
#define PLUGIN_DESCRIPTION		"Removes lobby reservation when server is full"
#define PLUGIN_VERSION			"2.0.1a"
#define PLUGIN_URL				"http://forums.alliedmods.net/showthread.php?t=87759"

ConVar
	g_cvUnreserve,
	g_cvSvAllowLobbyCo;

bool
	g_bUnreserve;

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart() {
	CreateConVar("l4d_unreserve_version", PLUGIN_VERSION, "Version of the Lobby Unreserve plugin.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvUnreserve =			CreateConVar("l4d_unreserve_full",	"1",	"Automatically unreserve server after a full lobby joins", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_cvSvAllowLobbyCo =	FindConVar("sv_allow_lobby_connect_only");

	g_cvUnreserve.AddChangeHook(CvarChanged);

	RegAdminCmd("sm_unreserve", cmdUnreserve, ADMFLAG_BAN, "sm_unreserve - manually force removes the lobby reservation");
}

Action cmdUnreserve(int client, int args) {
	L4D_LobbyUnreserve();
	SetAllowLobby(0);
	ReplyToCommand(client, "[UL] Lobby reservation has been removed.");
	return Plugin_Handled;
}

public void OnConfigsExecuted() {
	GetCvars();
}

void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
}

void GetCvars() {
	g_bUnreserve = g_cvUnreserve.BoolValue;
}

public void OnClientConnected(int client) {
	if (!g_bUnreserve)
		return;

	if (IsFakeClient(client))
		return;

	if (!IsServerLobbyFull(-1))
		return;

	L4D_LobbyUnreserve();
	SetAllowLobby(0);
}

bool IsServerLobbyFull(int client) {
	return GetConnectedPlayer(client) >= 4;
}

int GetConnectedPlayer(int client) {
	int count;
	for (int i = 1; i <= MaxClients; i++) {
		if (i != client && IsClientConnected(i) && !IsFakeClient(i))
			count++;
	}
	return count;
}

void SetAllowLobby(int value) {
	g_cvSvAllowLobbyCo.IntValue = value;
}