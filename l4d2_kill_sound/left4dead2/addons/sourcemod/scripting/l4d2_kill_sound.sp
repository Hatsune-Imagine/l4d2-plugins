#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define Team_Survivor 2
#define Team_Infected 3
#define Kill_Sound1 "physics/flesh/flesh_squishy_impact_hard1.wav"
#define Kill_Sound2 "physics/flesh/flesh_squishy_impact_hard2.wav"
#define Kill_Sound3 "physics/flesh/flesh_squishy_impact_hard3.wav"
#define Kill_Sound4 "physics/flesh/flesh_squishy_impact_hard4.wav"
#define Kill_Sound5 "player/damage1.wav"
#define Kill_Sound6 "player/damage2.wav"
#define HeadShot_Sound1 "physics/body/body_medium_break2.wav"
#define HeadShot_Sound2 "physics/body/body_medium_break3.wav"

ConVar g_hEnable, g_hOtherEnable;
char g_cKillSound[][] = {Kill_Sound1, Kill_Sound2, Kill_Sound3, Kill_Sound4, Kill_Sound5, Kill_Sound6};
char g_cHeadshotSound[][] = {HeadShot_Sound1, HeadShot_Sound2};


public Plugin myinfo =
{
	name 			= "L4D2 Kill Sound",
	author 			= "夜羽真白, HatsuneImagine",
	description 	= "When a CI or SI get killed, a unique sound will be played.",
	version 		= "1.1",
	url 			= "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	char game[32];
	GetGameFolderName(game, sizeof(game));
	if (!StrEqual(game, "left4dead2", false))
		SetFailState("This plugin only supports L4D2.");

	g_hEnable = CreateConVar("l4d2_kill_sound_enable", "1", "是否启用击杀提示音.\n0=关闭, 1=启用", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hOtherEnable = CreateConVar("l4d2_kill_sound_other_enable", "0", "当普通感染者或特殊感染者死于土制炸弹爆炸或燃烧瓶时, 是否启用击杀提示音.\n0=关闭, 1=启用", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookEvent("infected_death", Event_CI_Death);
	HookEvent("player_death", Event_SI_Death);
}

public void OnMapStart()
{
	PrecacheSound(Kill_Sound1, true);
	PrecacheSound(Kill_Sound2, true);
	PrecacheSound(Kill_Sound3, true);
	PrecacheSound(Kill_Sound4, true);
	PrecacheSound(HeadShot_Sound1, true);
	PrecacheSound(HeadShot_Sound2, true);
}

Action Event_CI_Death(Event event, const char[] name, bool dontBroadcast)
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	int damagetype = event.GetInt("weapon_id");
	bool headshot = GetEventBool(event, "headshot");
	// PrintToChatAll("[Debug] damage type: %d", damagetype);
	if (killer && killer <= MaxClients && !IsFakeClient(killer) && IsClientInGame(killer) && GetClientTeam(killer) == Team_Survivor)
	{
		if (g_hEnable.BoolValue)
		{
			if (!g_hOtherEnable.BoolValue && damagetype == 0) return Plugin_Continue;
			PlaySound(killer, headshot);
		}
	}
	return Plugin_Continue;
}

Action Event_SI_Death(Event event, const char[] name, bool dontBroadcast)
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	bool headshot = GetEventBool(event, "headshot");
	// PrintToChatAll("[Debug] damage type: %s", weapon);
	if (victim && killer && killer <= MaxClients && !IsFakeClient(killer) && IsClientInGame(killer) && GetClientTeam(killer) == Team_Survivor)
	{
		int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
		if (zombieClass == 7 || zombieClass == 8)
			return Plugin_Continue;
		if (g_hEnable.BoolValue)
		{
			if (!g_hOtherEnable.BoolValue && (strcmp(weapon, "pipe_bomb") == 0 || strcmp(weapon, "inferno") == 0)) return Plugin_Continue;
			PlaySound(killer, headshot);
		}
	}
	return Plugin_Continue;
}

void PlaySound(int client, bool headshot)
{
	if (headshot)
	{
		EmitSoundToClient(client, g_cHeadshotSound[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, 100);
		EmitSoundToClient(client, g_cHeadshotSound[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 500, _, SNDVOL_NORMAL, 100);
	}
	else
	{
		EmitSoundToClient(client, g_cKillSound[GetRandomInt(0, 3)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, 100);
		EmitSoundToClient(client, g_cKillSound[GetRandomInt(4, 5)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, 100);
	}
}
