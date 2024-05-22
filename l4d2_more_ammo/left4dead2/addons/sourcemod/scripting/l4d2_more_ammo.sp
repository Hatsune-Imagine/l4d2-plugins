#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define VERSION "1.2"

bool enabled;
ConVar cv_moreAmmoType, cv_smgMax, cv_shotgunMax, cv_autoshotgunMax, cv_assaultrifleMax, cv_huntingrifleMax, cv_sniperrifleMax, cv_grenadelauncherMax;

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
	cv_moreAmmoType = CreateConVar("l4d2_more_ammo_type", "1", "更多后备弹药类型. 1=双倍后备弹药 2=自定义数量后备弹药.");
	cv_smgMax = CreateConVar("l4d2_more_ammo_smg_max", "950", "冲锋枪后备弹药量.");
	cv_shotgunMax = CreateConVar("l4d2_more_ammo_shotgun_max", "144", "单喷后备弹药量.");
	cv_autoshotgunMax = CreateConVar("l4d2_more_ammo_autoshotgun_max", "180", "连喷后备弹药量.");
	cv_assaultrifleMax = CreateConVar("l4d2_more_ammo_assaultrifle_max", "720", "步枪后备弹药量.");
	cv_huntingrifleMax = CreateConVar("l4d2_more_ammo_huntingrifle_max", "300", "猎枪后备弹药量.");
	cv_sniperrifleMax = CreateConVar("l4d2_more_ammo_sniperrifle_max", "360", "军用狙击枪后备弹药量.");
	cv_grenadelauncherMax = CreateConVar("l4d2_more_ammo_grenadelauncher_max", "60", "榴弹发射器后备弹药量.");

	AutoExecConfig(true, "l4d2_more_ammo");
}

public Action MoreAmmo(int client, int args)
{
	enabled = args == 1 ? GetCmdArgInt(1) >= 1 : !enabled;

	if (enabled) {
		if (cv_moreAmmoType.IntValue == 1) {
			SetConVarInt(FindConVar("ammo_smg_max"), 950);
			SetConVarInt(FindConVar("ammo_shotgun_max"), 144);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), 180);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), 720);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), 300);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), 360);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), 60);
		}
		else {
			SetConVarInt(FindConVar("ammo_smg_max"), cv_smgMax.IntValue);
			SetConVarInt(FindConVar("ammo_shotgun_max"), cv_shotgunMax.IntValue);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), cv_autoshotgunMax.IntValue);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), cv_assaultrifleMax.IntValue);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), cv_huntingrifleMax.IntValue);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), cv_sniperrifleMax.IntValue);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), cv_grenadelauncherMax.IntValue);
		}

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
