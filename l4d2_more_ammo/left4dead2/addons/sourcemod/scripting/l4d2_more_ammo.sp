#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define VERSION "1.3"

#define DEFAULT_AMMO_SMG 650
#define DEFAULT_AMMO_SHOTGUN 72
#define DEFAULT_AMMO_AUTO_SHOTGUN 90
#define DEFAULT_AMMO_ASSAULT_RIFLE 360
#define DEFAULT_AMMO_HUNTING_RIFLE 150
#define DEFAULT_AMMO_SNIPER_RIFLE 180
#define DEFAULT_AMMO_GRENADE_LAUNCHER 30

int multiple;

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
	RegAdminCmd("sm_mammo", MoreAmmo, ADMFLAG_ROOT, "管理员开启或关闭更多后备弹药.");
}

public Action MoreAmmo(int client, int args)
{
	multiple = args > 0 ? GetCmdArgInt(1) : multiple == 1 || multiple == 0 ? 2 : 0;

	if (multiple > 1)
	{
		SetConVarInt(FindConVar("ammo_smg_max"), multiple == 2 ? 950 : DEFAULT_AMMO_SMG * multiple);
		SetConVarInt(FindConVar("ammo_shotgun_max"), DEFAULT_AMMO_SHOTGUN * multiple);
		SetConVarInt(FindConVar("ammo_autoshotgun_max"), DEFAULT_AMMO_AUTO_SHOTGUN * multiple);
		SetConVarInt(FindConVar("ammo_assaultrifle_max"), DEFAULT_AMMO_ASSAULT_RIFLE * multiple);
		SetConVarInt(FindConVar("ammo_huntingrifle_max"), DEFAULT_AMMO_HUNTING_RIFLE * multiple);
		SetConVarInt(FindConVar("ammo_sniperrifle_max"), DEFAULT_AMMO_SNIPER_RIFLE * multiple);
		SetConVarInt(FindConVar("ammo_grenadelauncher_max"), DEFAULT_AMMO_GRENADE_LAUNCHER * multiple);

		PrintToChatAll("\x03已开启\x05%d倍后备弹药.", multiple);
	}
	else if (multiple < 0)
	{
		SetConVarInt(FindConVar("ammo_smg_max"), -2);
		SetConVarInt(FindConVar("ammo_shotgun_max"), -2);
		SetConVarInt(FindConVar("ammo_autoshotgun_max"), -2);
		SetConVarInt(FindConVar("ammo_assaultrifle_max"), -2);
		SetConVarInt(FindConVar("ammo_huntingrifle_max"), -2);
		SetConVarInt(FindConVar("ammo_sniperrifle_max"), -2);
		SetConVarInt(FindConVar("ammo_grenadelauncher_max"), -2);

		PrintToChatAll("\x03已开启\x05无限后备弹药.");
	}
	else
	{
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
