//Based off retsam code but i have done a complete rewrite with new ffunctions  and more features

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

native LMC_GetClientOverlayModel(iClient);

#define PLUGIN_VERSION "2.0.2"

static Handle:hCvar_Enabled = INVALID_HANDLE;
static Handle:hCvar_GlowEnabled = INVALID_HANDLE;
static Handle:hCvar_GlowColour = INVALID_HANDLE;
static Handle:hCvar_GlowRange = INVALID_HANDLE;
static Handle:hCvar_GlowFlash = INVALID_HANDLE;
static Handle:hCvar_NoticeType = INVALID_HANDLE;
static Handle:hCvar_TeamNoticeType = INVALID_HANDLE;
static Handle:hCvar_HintRange = INVALID_HANDLE;
static Handle:hCvar_HintTime = INVALID_HANDLE;
static Handle:hCvar_HintColour = INVALID_HANDLE;


static bool:bEnabled = false;
static bool:bGlowEnabled = false;
static iGlowColour;
static iGlowRange = 1800;
static iGlowFlash = 30;
static iNoticeType = 2;
static iTeamNoticeType = 2;
static iHintRange = 600;
static Float:fHintTime = 5.0;
static String:sHintColour[17];

static String:sCharName[17];
static bool:bGlow[MAXPLAYERS+1] = {false, ...};

static bool:bLMC_Available = false;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}
	MarkNativeAsOptional("LMC_GetClientOverlayModel");
	return APLRes_Success;
}

public OnAllPluginsLoaded()
{
	bLMC_Available = LibraryExists("LMCCore");
}

public OnLibraryAdded(const String:sName[])
{
	if(StrEqual(sName, "LMCCore"))
	bLMC_Available = true;
}

public OnLibraryRemoved(const String:sName[])
{
	if(StrEqual(sName, "LMCCore"))
	bLMC_Available = false;
}

public Plugin:myinfo =
{
	name = "L4D2 Black and White Notifier",
	author = "Lux",
	description = "Notify people when player is black and white Using LMC model if any",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2449184#post2449184"
}

#define AUTO_EXEC true
public OnPluginStart()
{
	CreateConVar("lmc_bwnotice_version", PLUGIN_VERSION, "Version of black and white notification plugin", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	hCvar_Enabled = CreateConVar("lmc_blackandwhite", "1", "Enable black and white notification plugin?(1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowEnabled = CreateConVar("lmc_glow", "1", "Enable making black white players glow?(1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowColour = CreateConVar("lmc_glowcolour", "255 255 255", "Glow(255 255 255)", FCVAR_NOTIFY);
	hCvar_GlowRange = CreateConVar("lmc_glowrange", "800.0", "Glow range before you don't see the glow max distance", FCVAR_NOTIFY, true, 1.0);
	hCvar_GlowFlash = CreateConVar("lmc_glowflash", "20", "while black and white if below 20(Def) start pulsing (0 = disable)", FCVAR_NOTIFY, true, 0.0);
	hCvar_NoticeType = CreateConVar("lmc_noticetype", "3", "Type to use for notification. (0= off, 1=chat, 2=hint text, 3=director hint)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	hCvar_TeamNoticeType = CreateConVar("lmc_teamnoticetype", "0", "Method of notification. (0=survivors only, 1=infected only, 2=all players)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	hCvar_HintRange = CreateConVar("lmc_hintrange", "600", "Director hint On Black and white", FCVAR_NOTIFY, true, 1.0, true, 9999.0);
	hCvar_HintTime = CreateConVar("lmc_hinttime", "5.0", "Director hint Timeout (in seconds)", FCVAR_NOTIFY, true, 1.0, true, 20.0);
	hCvar_HintColour = CreateConVar("lmc_hintcolour", "255 0 0", "Director hint colour Layout(255 255 255)", FCVAR_NOTIFY);
	
	HookEvent("revive_success", eReviveSuccess);
	HookEvent("heal_success", eHealSuccess);
	HookEvent("player_death", ePlayerDeath);
	HookEvent("player_spawn", ePlayerSpawn);
	HookEvent("player_team", eTeamChange);
	HookEvent("pills_used", eItemUsedPill);
	HookEvent("adrenaline_used", eItemUsed);
	
	HookConVarChange(hCvar_Enabled, eConvarChanged);
	HookConVarChange(hCvar_GlowEnabled, eConvarChanged);
	HookConVarChange(hCvar_GlowColour, eConvarChanged);
	HookConVarChange(hCvar_GlowRange, eConvarChanged);
	HookConVarChange(hCvar_GlowFlash, eConvarChanged);
	HookConVarChange(hCvar_NoticeType, eConvarChanged);
	HookConVarChange(hCvar_TeamNoticeType, eConvarChanged);
	HookConVarChange(hCvar_HintRange, eConvarChanged);
	HookConVarChange(hCvar_HintTime, eConvarChanged);
	HookConVarChange(hCvar_HintColour, eConvarChanged);
	
	#if AUTO_EXEC
	AutoExecConfig(true, "l4d2_black_and_white_notifier");
	#endif
	CvarsChanged();
	
}

public OnMapStart()
{
	CvarsChanged();
}

public eConvarChanged(Handle:hCvar, const String:sOldVal[], const String:sNewVal[])
{
	CvarsChanged();
}

CvarsChanged()
{
	bEnabled = GetConVarInt(hCvar_Enabled) > 0;
	bGlowEnabled = GetConVarInt(hCvar_GlowEnabled) > 0;
	decl String:sGlowColour[13];
	GetConVarString(hCvar_GlowColour, sGlowColour, sizeof(sGlowColour));
	iGlowColour = GetColor(sGlowColour);
	iGlowRange = GetConVarInt(hCvar_GlowRange);
	iGlowFlash = GetConVarInt(hCvar_GlowFlash);
	iNoticeType = GetConVarInt(hCvar_NoticeType);
	iTeamNoticeType = GetConVarInt(hCvar_TeamNoticeType);
	iHintRange = GetConVarInt(hCvar_HintRange);
	fHintTime = GetConVarFloat(hCvar_HintTime);
	GetConVarString(hCvar_HintColour, sHintColour, sizeof(sHintColour));
}

public eReviveSuccess(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
	return;
	
	if(!GetEventBool(hEvent, "lastlife"))
	return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "subject"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
	return;
	
	static iEntity;
	iEntity = -1;
	
	if(bGlowEnabled)
	{
		bGlow[iClient] = true;
		if(bLMC_Available)
		{
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", iGlowColour);
				SetEntProp(iEntity, Prop_Send, "m_nGlowRange", iGlowRange);
				
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
				SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
			}
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
		}
	}
	
	GetModelName(iClient, iEntity);
	
	switch(iTeamNoticeType)
	{
		case 0:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i) || i == iClient)
				continue;
				
				if(iNoticeType == 1)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
				if(iNoticeType == 2)
				PrintHintText(i, "[B&W] %N(%s\x04) is Black&White", iClient, sCharName);
				if(iNoticeType == 3)
				DirectorHint(iClient, i);
			}
			
		}
		case 1:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i))
				continue;
				
				if(iNoticeType == 1)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
				if(iNoticeType == 2)
				PrintHintText(i, "[B&W] %N(%s\x04) is Black&White", iClient, sCharName);
				if(iNoticeType == 3)
				PrintHintText(i, "[B&W] %N(%s\x04) is Black&White", iClient, sCharName);
			}
		}
		case 2:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i) || i == iClient)
				continue;
				
				if(iNoticeType == 1)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
				if(iNoticeType == 2)
				PrintHintText(i, "[B&W] %N(%s) is Black&White", iClient, sCharName);
				if(GetClientTeam(i) !=2)
				{
					PrintHintText(i, "[B&W] %N(%s) is Black&White", iClient, sCharName);
					continue;
				}
				if(iNoticeType == 3)
				DirectorHint(iClient, i);
			}
		}
	}
}

public eHealSuccess(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
	return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "subject"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	static iEntity;
	iEntity = -1;
	if(bGlowEnabled)
	{
		bGlow[iClient] = false;
		if(bLMC_Available)
		{
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				ResetGlows(iEntity);
			}
			else
			{
				ResetGlows(iClient);
			}
		}
		else
		{
			ResetGlows(iClient);
		}
	}
	
	GetModelName(iClient, iEntity);
	static iHealer;
	iHealer = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	switch(iTeamNoticeType)
	{
		case 0:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i) || i == iClient || i == iHealer)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is no longer Black&White", iClient, sCharName);
				else
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) healed themselves", iClient, sCharName);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[B&W] %N(%s) is no longer Black&White", iClient, sCharName);
				else
				PrintHintText(i, "[B&W] %N(%s) healed themselves", iClient, sCharName);
				
				if(iNoticeType == 3)
				DirectorHintAll(iClient, iHealer, i);
			}
		}
		case 1:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i) || i == iClient || i == iHealer)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is no longer Black&White", iClient, sCharName);
				else
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) healed themselve", iClient, sCharName);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[B&W] %N(%s) is no longer Black&White", iClient);
				else
				PrintHintText(i, "[B&W] %N(%s) healed themselvee", iClient, sCharName);
				
				if(iNoticeType == 3)
				if(iClient != iHealer)
				PrintHintText(i, "[B&W] %N(%s) is no longer Black&White", iClient);
				else
				PrintHintText(i, "[B&W] %N(%s) healed themselves", iClient, sCharName);
			}
		}
		case 2:
		{
			for(new i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i) || i == iClient || i == iHealer)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) is no longer Black&White", iClient, sCharName);
				else
				PrintToChat(i, "\x04[B&W] \x03%N\x04(\x03%s\x04) healed themselves", iClient, sCharName);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[B&W] %N(%s) is no longer Black&White", iClient, sCharName);
				else
				PrintHintText(i, "[B&W] %N(%s) healed themselves", iClient, sCharName);
				
				if(GetClientTeam(i) !=2)
				if(iClient != iHealer)
				{
					PrintHintText(i, "[B&W] %N(%s) is no longer Black&White", iClient, sCharName);
					continue;
				}
				else
				{
					PrintHintText(i, "[B&W] %N(%s) healed themselves", iClient, sCharName);
					continue;
				}
				if(iNoticeType == 3)
				DirectorHintAll(iClient, iHealer, i);
			}
		}
	}
}

public ePlayerDeath(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
	return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!bGlow[iClient])
	return;
	
	bGlow[iClient] = false;
	
	if(bLMC_Available)
	{
		static iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			ResetGlows(iEntity);
		}
		else
		{
			ResetGlows(iClient);
		}
	}
	else
	{
		ResetGlows(iClient);
	}
}

public ePlayerSpawn(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
		return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2)
		return;
		
	if(GetEntProp(iClient, Prop_Send, "m_currentReviveCount") < GetMaxReviveCount())
	{
		if(bLMC_Available)
		{
			static iEntity;
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				ResetGlows(iEntity);
			}
			else
			{
				ResetGlows(iClient);
			}
		}
		else
		{
			ResetGlows(iClient);
		}
		bGlow[iClient] = false;
		return;
	}
	
	
	bGlow[iClient] = true;
	if(bLMC_Available)
	{
		static iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", iGlowRange);
			
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
		}
	}
	else
	{
		SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
		SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
		SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
	}
}

public eTeamChange(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
		return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(bLMC_Available)
	{
		static iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", 0);
			SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
			SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
		}
	}
	else
	{
		SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
		SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
		SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
	
}


public LMC_OnClientModelApplied(iClient, iEntity, const String:sModel[PLATFORM_MAX_PATH], bBaseReattach)
{
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!bGlow[iClient])
	return;
	
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", GetEntProp(iClient, Prop_Send, "m_iGlowType"));
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", GetEntProp(iClient, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", GetEntProp(iClient, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iEntity, Prop_Send, "m_bFlashing", GetEntProp(iClient, Prop_Send, "m_bFlashing", 1), 1);
	
	SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
	SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
	SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
}

public LMC_OnClientModelDestroyed(iClient, iEntity)
{
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!IsValidEntity(iEntity))
	return;
	
	if(!bGlow[iClient])
	return;
	
	SetEntProp(iClient, Prop_Send, "m_iGlowType", GetEntProp(iEntity, Prop_Send, "m_iGlowType"));
	SetEntProp(iClient, Prop_Send, "m_glowColorOverride", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iClient, Prop_Send, "m_nGlowRange", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iClient, Prop_Send, "m_bFlashing", GetEntProp(iEntity, Prop_Send, "m_bFlashing", 1), 1);
}

static GetModelName(iClient, iEntity)
{
	static String:sModel[64];
	if(!IsValidEntity(iEntity))
	{
		GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		if(StrContains(sModel, "teenangst", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Zoey");
		else if(StrContains(sModel, "biker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Francis");
		else if(StrContains(sModel, "manager", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Louis");
		else if(StrContains(sModel, "namvet", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Bill");
		else if(StrContains(sModel, "producer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Rochelle");
		else if(StrContains(sModel, "mechanic", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Ellis");
		else if(StrContains(sModel, "coach", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Coach");
		else if(StrContains(sModel, "gambler", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Nick");
		else if(StrContains(sModel, "adawong", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "AdaWong");
		else
		strcopy(sCharName, sizeof(sCharName), "Unknown");
	}
	else if(IsValidEntity(iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		if(StrContains(sModel, "Bride", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Witch Bride");
		else if(StrContains(sModel, "Witch", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Witch");
		else if(StrContains(sModel, "hulk", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Tank");
		else if(StrContains(sModel, "boomer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Boomer");
		else if(StrContains(sModel, "boomette", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Female Boomer");
		else if(StrContains(sModel, "hunter", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Hunter");
		else if(StrContains(sModel, "smoker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Smoker");
		else if(StrContains(sModel, "teenangst", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Zoey");
		else if(StrContains(sModel, "biker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Francis");
		else if(StrContains(sModel, "manager", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Louis");
		else if(StrContains(sModel, "namvet", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Bill");
		else if(StrContains(sModel, "producer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Rochelle");
		else if(StrContains(sModel, "mechanic", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Ellis");
		else if(StrContains(sModel, "coach", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Coach");
		else if(StrContains(sModel, "gambler", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Nick");
		else if(StrContains(sModel, "adawong", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "AdaWong");
		else if(StrContains(sModel, "rescue", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Chopper Pilot");
		else if(StrContains(sModel, "common", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Infected");
		else
		strcopy(sCharName, sizeof(sCharName), "Unknown");
	}
}

static DirectorHint(iClient, i)
{
	static iEntity;
	iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
	return;
	
	static String:sValues[51];
	FormatEx(sValues, sizeof(sValues), "hint%d", iClient);
	DispatchKeyValue(iClient, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	FormatEx(sValues, sizeof(sValues), "%i", iHintRange);
	DispatchKeyValue(iEntity, "hint_range", sValues);
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_alert");
	
	FormatEx(sValues, sizeof(sValues), "%f", fHintTime);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	FormatEx(sValues, sizeof(sValues), "%N(%s) is Black&White", iClient, sCharName);
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", sHintColour);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", fHintTime);
	SetVariantString(sValues);
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}

static DirectorHintAll(iClient, iHealer, i)
{
	static iEntity;
	iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
	return;
	
	static String:sValues[62];
	FormatEx(sValues, sizeof(sValues), "hint%d", i);
	DispatchKeyValue(i, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	DispatchKeyValue(iEntity, "hint_range", "0.1");
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_info");
	
	FormatEx(sValues, sizeof(sValues), "%f", fHintTime);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	if(iClient == iHealer)
	FormatEx(sValues, sizeof(sValues), "%N(%s) healed themselves", iClient, sCharName);
	else
	FormatEx(sValues, sizeof(sValues), "%N(%s) is no longer Black&White", iClient, sCharName);
	
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", sHintColour);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", fHintTime);
	SetVariantString(sValues);
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}

//silvers colour converter
GetColor(String:sTemp[13])
{
	decl String:sColors[3][4];
	ExplodeString(sTemp, " ", sColors, 3, 4);
	
	new color;
	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);
	return color;
}

public OnClientPutInServer(iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamage, eOnTakeDamage);
}

public Action:eOnTakeDamage(iVictim, &iAttacker, &iInflictor, &Float:fDamage, &iDamagetype)
{
	if(!bEnabled)
		return;
	
	if(iVictim < 1 || iVictim > MaxClients)
	return;
	
	if(!IsClientInGame(iVictim) || GetClientTeam(iVictim) != 2)
	return;
	
	if(!bGlow[iVictim])
	return;
	
	static iEntity;
	iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(iVictim);
	
	
	if(L4D_GetPlayerTempHealth(iVictim) + GetEntProp(iVictim, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(iVictim, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(iVictim, Prop_Send, "m_bFlashing", 1, 1);
		
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(iVictim, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(iVictim, Prop_Send, "m_bFlashing", 0, 1);
	}
}

static L4D_GetPlayerTempHealth(client)
{
	static Handle:painPillsDecayCvar = INVALID_HANDLE;
	if (painPillsDecayCvar == INVALID_HANDLE)
	{
		painPillsDecayCvar = FindConVar("pain_pills_decay_rate");
		if (painPillsDecayCvar == INVALID_HANDLE)
		{
			return -1;
		}
	}
	
	new tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(painPillsDecayCvar))) - 1;
	return tempHealth < 0 ? 0 : tempHealth;
}
static GetMaxReviveCount()
{
	static Handle:hMaxReviveCount = INVALID_HANDLE;
	if (hMaxReviveCount == INVALID_HANDLE)
	{
		hMaxReviveCount = FindConVar("survivor_max_incapacitated_count");
		if (hMaxReviveCount == INVALID_HANDLE)
		{
			return -1;
		}
	}
	
	return GetConVarInt(hMaxReviveCount);
}

public eItemUsedPill(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
		return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "subject"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	static iEntity;
	iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(iClient);
	
	if(L4D_GetPlayerTempHealth(iClient) + GetEntProp(iClient, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
		
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
}

public eItemUsed(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	if(!bEnabled)
		return;
	
	static iClient;
	iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	static iEntity;
	iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(iClient);
	
	if(L4D_GetPlayerTempHealth(iClient) + GetEntProp(iClient, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
		
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
}

static ResetGlows(iEntity)
{
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", 0);
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", 0);
	SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
}

