#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define VERSION "1.0"

public Plugin myinfo = 
{
	name = "L4D2 More Medical",
	author = "HatsuneImagine",
	description = "More medical items based on player counts.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnClientConnected(int client)
{
	SetMoreMedical(RoundToCeil(GetAllPlayerCount() / 4.0));
}

public void OnClientDisconnect(int client)
{
	SetMoreMedical(RoundToCeil(GetAllPlayerCount() / 4.0));
}

void SetMoreMedical(int count)
{
	char gameMode[32];
	GetConVarString(FindConVar("mp_gamemode"), gameMode, sizeof(gameMode));
	if (StrContains(gameMode, "versus") > -1 || StrContains(gameMode, "scavenge") > -1)
		return;

	char entCount[2];
	IntToString(count, entCount, sizeof(entCount));
	SetEntCount("weapon_defibrillator_spawn", entCount);	//电击器
	SetEntCount("weapon_first_aid_kit_spawn", entCount);	//医疗包
	SetEntCount("weapon_pain_pills_spawn", entCount);		//止痛药
}

void SetEntCount(const char[] entName, const char[] entCount)
{
	int edictIndex = FindEntityByClassname(-1, entName);
	
	while(edictIndex != -1)
	{
		DispatchKeyValue(edictIndex, "count", entCount);
		edictIndex = FindEntityByClassname(edictIndex, entName);
	}
}

int GetAllPlayerCount()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientConnected(i) && !IsFakeClient(i))
			count++;
	
	return count;
}
