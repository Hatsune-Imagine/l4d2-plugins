#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define DMG_CUSTOM_FIRE      2056
#define DMG_CUSTOM_ONFIRE    268435464
#define DMG_CUSTOM_PIPEBOMB  134217792
#define DMG_CUSTOM_PROPANE   16777280
#define DMG_CUSTOM_OXYGEN    33554432
#define DMG_CUSTOM_GRENADE   1107296256

#define VERSION "1.0"

bool bFF = true;

public Plugin myinfo = 
{
	name = "L4D2 No Friendly Fire",
	author = "HatsuneImagine",
	description = "Disable friendly fire.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_noff", DisableFF, ADMFLAG_ROOT, "管理员开启或关闭队友伤害.");
	RegAdminCmd("sm_black", DisableFF, ADMFLAG_ROOT, "管理员开启或关闭队友伤害.");
}

public Action DisableFF(int client, int args)
{
	bFF = !bFF;
	PrintToChatAll("\x03%s\x05幸存者队友伤害.", bFF ? "已开启" : "已关闭");

	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{ 
	if (!bFF)
	{
		if(IsValidClient(client) && GetClientTeam(client) == 2)
		{
			if(IsValidClient(attacker) && GetClientTeam(attacker) == 2)
				return Plugin_Handled;
			else
				if(IsOtherDamageTypes(damagetype))
					return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool IsOtherDamageTypes(int damagetype)
{
	return damagetype == DMG_BURN || damagetype == DMG_CUSTOM_FIRE || damagetype == DMG_CUSTOM_ONFIRE //火焰伤害.
	|| damagetype == DMG_CUSTOM_PIPEBOMB || damagetype == DMG_CUSTOM_PROPANE || damagetype == DMG_CUSTOM_OXYGEN //土制炸弹,煤气罐,氧气罐爆炸伤害.
	|| damagetype == DMG_CUSTOM_GRENADE;//榴弹发射器伤害.
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}
