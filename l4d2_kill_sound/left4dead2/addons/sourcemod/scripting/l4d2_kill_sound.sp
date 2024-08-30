#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define Team_Survivor 2
#define Team_Infected 3
#define Flesh_Impact_Sound1 "physics/flesh/flesh_squishy_impact_hard1.wav"
#define Flesh_Impact_Sound2 "physics/flesh/flesh_squishy_impact_hard2.wav"
#define Flesh_Impact_Sound3 "physics/flesh/flesh_squishy_impact_hard3.wav"
#define Flesh_Impact_Sound4 "physics/flesh/flesh_squishy_impact_hard4.wav"
#define Body_Break_Sound1 "physics/body/body_medium_break2.wav"
#define Body_Break_Sound2 "physics/body/body_medium_break3.wav"
#define Fall_Damage_Sound1 "player/damage1.wav"
#define Fall_Damage_Sound2 "player/damage2.wav"
#define Zombie_Slice_Sound1 "player/pz/hit/zombie_slice_1.wav"
#define Zombie_Slice_Sound2 "player/pz/hit/zombie_slice_2.wav"
#define Zombie_Slice_Sound3 "player/pz/hit/zombie_slice_3.wav"
#define Zombie_Slice_Sound4 "player/pz/hit/zombie_slice_4.wav"
#define Zombie_Slice_Sound5 "player/pz/hit/zombie_slice_5.wav"
#define Zombie_Slice_Sound6 "player/pz/hit/zombie_slice_6.wav"
#define Bullet_Impact_Sound1 "npc/infected/gore/bullets/bullet_impact_01.wav"
#define Bullet_Impact_Sound2 "npc/infected/gore/bullets/bullet_impact_02.wav"
#define Bullet_Impact_Sound3 "npc/infected/gore/bullets/bullet_impact_03.wav"
#define Bullet_Impact_Sound4 "npc/infected/gore/bullets/bullet_impact_04.wav"
#define Bullet_Impact_Sound5 "npc/infected/gore/bullets/bullet_impact_05.wav"
#define Bullet_Impact_Sound6 "npc/infected/gore/bullets/bullet_impact_06.wav"
#define Bullet_Impact_Sound7 "npc/infected/gore/bullets/bullet_impact_07.wav"
#define Bullet_Impact_Sound8 "npc/infected/gore/bullets/bullet_impact_08.wav"
#define Pitchfork_Impact_Sound1 "weapons/pitchfork/pitchfork_impact_flesh1.wav"
#define Pitchfork_Impact_Sound2 "weapons/pitchfork/pitchfork_impact_flesh2.wav"
#define Pitchfork_Impact_Sound3 "weapons/pitchfork/pitchfork_impact_flesh3.wav"
#define Pitchfork_Impact_Sound4 "weapons/pitchfork/pitchfork_impact_flesh4.wav"
#define Hunter_Hit_Sound "player/hunter/hit/tackled_1.wav"

ConVar g_hEnable, g_hOtherEnable;
char g_cFleshImpact[][] = {Flesh_Impact_Sound1, Flesh_Impact_Sound2, Flesh_Impact_Sound3, Flesh_Impact_Sound4};
char g_cBodyBreak[][] = {Body_Break_Sound1, Body_Break_Sound2};
char g_cFallDamage[][] = {Fall_Damage_Sound1, Fall_Damage_Sound2};
char g_cZombieSlice[][] = {Zombie_Slice_Sound1, Zombie_Slice_Sound2, Zombie_Slice_Sound3, Zombie_Slice_Sound4, Zombie_Slice_Sound5, Zombie_Slice_Sound6};
char g_cBulletImpact[][] = {Bullet_Impact_Sound1, Bullet_Impact_Sound2, Bullet_Impact_Sound3, Bullet_Impact_Sound4, Bullet_Impact_Sound5, Bullet_Impact_Sound6, Bullet_Impact_Sound7, Bullet_Impact_Sound8};
char g_cPitchforkImpact[][] = {Pitchfork_Impact_Sound1, Pitchfork_Impact_Sound2, Pitchfork_Impact_Sound3, Pitchfork_Impact_Sound4};

public Plugin myinfo = {
	name 			= "L4D2 Kill Sound",
	author 			= "夜羽真白, HatsuneImagine",
	description 	= "When a CI or SI get killed, a unique sound will be played.",
	version 		= "2.0",
	url 			= "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart() {
	char game[32];
	GetGameFolderName(game, sizeof(game));
	if (!StrEqual(game, "left4dead2", false))
		SetFailState("This plugin only supports L4D2.");

	g_hEnable = CreateConVar("l4d2_kill_sound_enable", "1", "是否启用击杀提示音.\n0=关闭, 1=启用", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hOtherEnable = CreateConVar("l4d2_kill_sound_other_enable", "0", "当普通感染者或特殊感染者死于土制炸弹爆炸或燃烧瓶时, 是否启用击杀提示音.\n0=关闭, 1=启用", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookEvent("player_death", Event_Player_Death);
}

public void OnMapStart() {
	PrecacheSound(Flesh_Impact_Sound1, true);
	PrecacheSound(Flesh_Impact_Sound2, true);
	PrecacheSound(Flesh_Impact_Sound3, true);
	PrecacheSound(Flesh_Impact_Sound4, true);
	PrecacheSound(Body_Break_Sound1, true);
	PrecacheSound(Body_Break_Sound2, true);
	PrecacheSound(Fall_Damage_Sound1, true);
	PrecacheSound(Fall_Damage_Sound2, true);
	PrecacheSound(Zombie_Slice_Sound1, true);
	PrecacheSound(Zombie_Slice_Sound2, true);
	PrecacheSound(Zombie_Slice_Sound3, true);
	PrecacheSound(Zombie_Slice_Sound4, true);
	PrecacheSound(Zombie_Slice_Sound5, true);
	PrecacheSound(Zombie_Slice_Sound6, true);
	PrecacheSound(Bullet_Impact_Sound1, true);
	PrecacheSound(Bullet_Impact_Sound2, true);
	PrecacheSound(Bullet_Impact_Sound3, true);
	PrecacheSound(Bullet_Impact_Sound4, true);
	PrecacheSound(Bullet_Impact_Sound5, true);
	PrecacheSound(Bullet_Impact_Sound6, true);
	PrecacheSound(Bullet_Impact_Sound7, true);
	PrecacheSound(Bullet_Impact_Sound8, true);
	PrecacheSound(Pitchfork_Impact_Sound1, true);
	PrecacheSound(Pitchfork_Impact_Sound2, true);
	PrecacheSound(Pitchfork_Impact_Sound3, true);
	PrecacheSound(Pitchfork_Impact_Sound4, true);
	PrecacheSound(Hunter_Hit_Sound, true);
}

Action Event_Player_Death(Event event, const char[] name, bool dontBroadcast) {
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	bool headshot = event.GetBool("headshot");
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	float victimPos[3];
	GetEntPropVector(event.GetInt("entityid"), Prop_Send, "m_vecOrigin", victimPos);
	// PrintToChatAll("[Debug] damage type: %s", weapon);

	if (!g_hEnable.BoolValue) return Plugin_Continue;
	if (!g_hOtherEnable.BoolValue && (strcmp(weapon, "pipe_bomb") == 0 || strcmp(weapon, "inferno") == 0)) return Plugin_Continue;
	if (killer && killer <= MaxClients && IsClientInGame(killer) && GetClientTeam(killer) == Team_Survivor) {
		// CI: victim == 0
		// SI: victim > 0
		if (victim) {
			bool skeet;
			int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
			int sequence = GetEntProp(victim, Prop_Send, "m_nSequence");
			if (zombieClass == 7 || zombieClass == 8) return Plugin_Continue;
			if (zombieClass == 3 && (sequence == 64 || sequence == 67)) skeet = true;
			else if (zombieClass == 5 && sequence == 10) skeet = true;
			else if (zombieClass == 6 && sequence == 5) skeet = true;
			else if (zombieClass == 1 && (sequence == 27 || sequence == 30)) skeet = true;
			if (skeet) {
				EmitAmbientSound(Hunter_Hit_Sound, victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitSoundToClient(killer, Hunter_Hit_Sound, _, SNDCHAN_AUTO, 500, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			}
		}
		if (StrEqual(weapon, "chainsaw", false)) {
			EmitAmbientSound(g_cZombieSlice[GetRandomInt(0, 5)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
			EmitSoundToClient(killer, g_cZombieSlice[GetRandomInt(0, 5)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			EmitSoundToClient(killer, g_cZombieSlice[GetRandomInt(0, 5)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		}
		else if (StrEqual(weapon, "melee", false)) {
			if (headshot) {
				EmitAmbientSound(g_cPitchforkImpact[GetRandomInt(0, 3)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitSoundToClient(killer, g_cBodyBreak[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
				EmitSoundToClient(killer, g_cBodyBreak[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 500, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			}
			else {
				EmitAmbientSound(g_cPitchforkImpact[GetRandomInt(0, 3)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitSoundToClient(killer, g_cFleshImpact[GetRandomInt(0, 3)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
				EmitSoundToClient(killer, g_cFallDamage[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			}
		}
		else {
			if (headshot) {
				EmitAmbientSound(g_cBodyBreak[GetRandomInt(0, 1)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitAmbientSound(g_cBodyBreak[GetRandomInt(0, 1)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitSoundToClient(killer, g_cBodyBreak[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 500, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
				EmitSoundToClientDelay(killer, g_cPitchforkImpact[GetRandomInt(0, 3)], 350, 0.095);
				EmitSoundToClientDelay(killer, g_cBulletImpact[GetRandomInt(0, 7)], 350, 0.15);
				EmitSoundToClientDelay(killer, g_cFallDamage[GetRandomInt(0, 1)], 350, 0.295);
			}
			else {
				EmitAmbientSound(g_cBulletImpact[GetRandomInt(0, 7)], victimPos, SOUND_FROM_WORLD, 255, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, 0.0);
				EmitSoundToClient(killer, g_cFleshImpact[GetRandomInt(0, 3)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
				EmitSoundToClient(killer, g_cFallDamage[GetRandomInt(0, 1)], _, SNDCHAN_AUTO, 350, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			}
		}
	}
	return Plugin_Continue;
}

void EmitSoundToClientDelay(int client, char[] soundStr, int level, float delay) {
	DataPack dp;
	CreateDataTimer(delay, Delay_Sound, dp);
	dp.WriteCell(client);
	dp.WriteString(soundStr);
	dp.WriteCell(level);
}

Action Delay_Sound(Handle timer, DataPack dp) {
	dp.Reset();
	int client = dp.ReadCell();
	char soundStr[64];
	dp.ReadString(soundStr, sizeof(soundStr));
	int level = dp.ReadCell();
	if (client > 0 && client <= MaxClients && IsClientInGame(client)) {
		EmitSoundToClient(client, soundStr, _, SNDCHAN_AUTO, level, _, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	}
	return Plugin_Continue;
}
