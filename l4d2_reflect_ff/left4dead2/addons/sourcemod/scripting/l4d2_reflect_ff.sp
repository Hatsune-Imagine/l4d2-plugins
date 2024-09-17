#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>

#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3
#define DMG_CUSTOM_FIRE 2056
#define DMG_CUSTOM_ONFIRE 268435464
#define DMG_CUSTOM_PIPEBOMB 134217792
#define DMG_CUSTOM_PROPANE 16777280
#define DMG_CUSTOM_OXYGEN 33554432
#define DMG_CUSTOM_GL 1107296256

ConVar g_cvEnable, g_cvEnableBot, g_cvEnableIncap, g_cvEnableFire, g_cvEnableExplode, g_cvDamageShield, g_cvDamageMulti;

public Plugin myinfo = {
	name = "L4D2 Reflect Friendly Fire",
	author = "HatsuneImagine",
	description = "Reflect survivor friendly fires.",
	version = "1.0",
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}


public void OnPluginStart() {
	RegAdminCmd("sm_rf", CmdReflect, ADMFLAG_ROOT, "Toggle reflect friendly fire function. (Note: If you prefer using this command to toggle reflect friendly fire function, you should better commented out the 'l4d2_reflect_ff_enable' in the cfg file.)");
	RegAdminCmd("sm_reflect", CmdReflect, ADMFLAG_ROOT, "Toggle reflect friendly fire function. (Note: If you prefer using this command to toggle reflect friendly fire function, you should better commented out the 'l4d2_reflect_ff_enable' in the cfg file.)");

	g_cvEnable = CreateConVar("l4d2_reflect_ff_enable", "0", "Enable Plugin [0=Disable,1=Enable]");
	g_cvEnableBot = CreateConVar("l4d2_reflect_ff_enable_bot", "0", "Enable reflect damage even if victim is a bot.\n0=Off\n1=On");
	g_cvEnableIncap = CreateConVar("l4d2_reflect_ff_enable_incap", "0", "Enable reflect damage even if victim is incapacitated.\n0=Off\n1=On");
	g_cvEnableFire = CreateConVar("l4d2_reflect_ff_enable_fire", "0", "Enable reflect damage of Molotov, Gascan and Firework Crate.\n0=Off\n1=On");
	g_cvEnableExplode = CreateConVar("l4d2_reflect_ff_enable_explode", "0", "Enable reflect damage of Pipe Bomb, Propane Tank, Oxygen Tank and Grenade Launcher.\n0=Off\n1=On");
	g_cvDamageShield = CreateConVar("l4d2_reflect_ff_damage_shield", "0", "Enable reflect damage only if damage is greater than or equal to this value. (0=Always reflects)");
	g_cvDamageMulti = CreateConVar("l4d2_reflect_ff_damage_multi", "1.0", "Multiply friendly fire damage value and reflect to attacker. (1.0=Original damage value)");

	AutoExecConfig(true, "l4d2_reflect_ff");
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

Action CmdReflect(int client, int args) {
	g_cvEnable.BoolValue = args == 1 ? GetCmdArgInt(1) >= 1 : !g_cvEnable.BoolValue;
	PrintToChatAll("\x03%s \x05Reflect Friendly Fire.", g_cvEnable.BoolValue ? "Enabled" : "Disabled");
	return Plugin_Continue;
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	// PrintToChatAll("[DEBUG] %d attacked %d, damage: %d, damagetype: %d", attacker, victim, RoundToFloor(damage), damagetype);
	if (!IsValidClient(attacker) || !IsValidClient(victim)) return Plugin_Continue;
	if (!g_cvEnable.BoolValue) return Plugin_Continue;
	if (!g_cvEnableBot.BoolValue && IsFakeClient(victim)) return Plugin_Continue;
	if (!g_cvEnableIncap.BoolValue && IsIncapacitated(victim)) return Plugin_Continue;
	if (!g_cvEnableFire.BoolValue && (damagetype == DMG_BURN || damagetype == DMG_CUSTOM_FIRE || damagetype == DMG_CUSTOM_ONFIRE)) return Plugin_Continue;
	if (!g_cvEnableExplode.BoolValue && (damagetype == DMG_CUSTOM_PIPEBOMB || damagetype == DMG_CUSTOM_PROPANE || damagetype == DMG_CUSTOM_OXYGEN || damagetype == DMG_CUSTOM_GL)) return Plugin_Continue;
	if (g_cvDamageShield.IntValue > RoundToFloor(damage)) return Plugin_Continue;

	if (attacker != victim && GetClientTeam(attacker) == TEAM_SURVIVOR && GetClientTeam(victim) == TEAM_SURVIVOR && !IsPinned(victim) && !IsClientInGodFrame(victim)) {
		// PrintToChatAll("[DEBUG] reflect damage %.1f to %d:%s", damage, attacker, attacker);
		SDKHooks_TakeDamage(attacker, attacker, attacker, damage * g_cvDamageMulti.FloatValue, DMG_BULLET);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

bool IsIncapacitated(int client) {
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

bool IsPinned(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 || GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 || GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 || GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0 || GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0;
}

bool IsClientInGodFrame(int client) {
	CountdownTimer timer = L4D2Direct_GetInvulnerabilityTimer(client);
	if (timer == CTimer_Null) return false;
	return CTimer_GetRemainingTime(timer) > 0.0;
}

bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}
