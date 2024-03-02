#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define DMG_CUSTOM_PIPEBOMB             134217792
#define DMG_CUSTOM_PROPANE              16777280
#define DMG_CUSTOM_OXYGEN               33554432
#define DMG_CUSTOM_GRENADE_LAUNCHER     1107296256

#define VERSION "1.1"

bool enabled = true;

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
	enabled = args == 1 ? GetCmdArgInt(1) >= 1 : !enabled;
	PrintToChatAll("\x03%s\x05生还者队友伤害.", enabled ? "已开启" : "已关闭");
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{ 
	if (!enabled)
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
	return damagetype == DMG_CUSTOM_PIPEBOMB || damagetype == DMG_CUSTOM_PROPANE || damagetype == DMG_CUSTOM_OXYGEN //土制炸弹,煤气罐,氧气罐爆炸伤害.
	|| damagetype == DMG_CUSTOM_GRENADE_LAUNCHER;//榴弹发射器伤害.
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}
