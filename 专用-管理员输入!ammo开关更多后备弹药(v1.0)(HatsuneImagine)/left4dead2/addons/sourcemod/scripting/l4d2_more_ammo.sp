#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define VERSION "1.0"

bool enabled;

public Plugin myinfo = 
{
	name = "L4D2 More Ammo",
	author = "HatsuneImagine",
	description = "More backup ammos.",
	version = VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_ammo", MoreAmmo, ADMFLAG_ROOT, "管理员开启或关闭更多后备弹药.");
}

public Action MoreAmmo(int client, int args)
{
	enabled = !enabled;

	if (enabled) {
		SetConVarInt(FindConVar("ammo_smg_max"), 950);
		SetConVarInt(FindConVar("ammo_shotgun_max"), 144);
		SetConVarInt(FindConVar("ammo_autoshotgun_max"), 180);
		SetConVarInt(FindConVar("ammo_assaultrifle_max"), 720);
		SetConVarInt(FindConVar("ammo_huntingrifle_max"), 300);
		SetConVarInt(FindConVar("ammo_sniperrifle_max"), 360);
		SetConVarInt(FindConVar("ammo_grenadelauncher_max"), 60);

		PrintToChatAll("\x03已开启\x05更多后备弹药.");
	}
	else {
		ResetConVar(FindConVar("ammo_smg_max"));
		ResetConVar(FindConVar("ammo_shotgun_max"));
		ResetConVar(FindConVar("ammo_autoshotgun_max"));
		ResetConVar(FindConVar("ammo_assaultrifle_max"));
		ResetConVar(FindConVar("ammo_huntingrifle_max"));
		ResetConVar(FindConVar("ammo_sniperrifle_max"));
		ResetConVar(FindConVar("ammo_grenadelauncher_max"));

		PrintToChatAll("\x03已关闭\x05更多后备弹药.");
	}

	return Plugin_Continue;
}
