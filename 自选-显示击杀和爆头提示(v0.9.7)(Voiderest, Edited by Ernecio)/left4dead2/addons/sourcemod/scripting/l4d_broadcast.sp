#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_NAME 				"[L4D/L4D2] Broadcast"
#define PLUGIN_AUTHOR 				"Voiderest, Edited by Ernecio"
#define PLUGIN_DESCRIPTION 			"Displays extra info for kills and friendly fire."
#define PLUGIN_VERSION 				"0.9.7"
#define PLUGIN_URL 					"<URL>"

#define CVAR_FLAGS 					FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION 	FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define CONFIG_FILENAME 			"l4d_broadcast"

public Plugin myinfo = 
{
	name 		= PLUGIN_NAME,
	author 		= PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version 	= PLUGIN_VERSION,
	url 		= PLUGIN_URL
}

Handle broadcast 			= INVALID_HANDLE;
Handle broadcast_con 		= INVALID_HANDLE;
Handle broadcast_attack 	= INVALID_HANDLE;
Handle broadcast_victim 	= INVALID_HANDLE;
Handle kill_timers			[MAXPLAYERS+1][3];
int kill_counts				[MAXPLAYERS+1][3];

public void OnPluginStart() 
{
	CreateConVar("l4d_broadcast_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, CVAR_FLAGS_PLUGIN_VERSION);
	
	broadcast 			= CreateConVar("l4d_broadcast_kill", 	"1", 	"0 = Plugin Disable.\n1 = Plugin Enable.\n2 = Show Headshots Only.", CVAR_FLAGS, true, 0.0, true, 2.0);
	broadcast_con 		= CreateConVar("l4d_broadcast_con", 	"0", 	"Printing Console:\n0 = Don't Print In Console.\n1 = Print In Console", CVAR_FLAGS, true, 0.0, true,1.0);
	broadcast_attack 	= CreateConVar("l4d_broadcast_ff", 		"0", 	"Print To Attacker:\n0 = Disable Ads.\n1 = Print To Hint.\n2 = Print To Hint + Print To Chat.\n3 = Print To Chat", CVAR_FLAGS, true, 0.0, true, 3.0);
	broadcast_victim 	= CreateConVar("l4d_broadcast_hit", 	"0", 	"Print Victim Damage Alert Via Chat:\n0 = Don't Show Friendly Fire To Victim.\n1 = Show Friendly Fire To Victim.", CVAR_FLAGS,true, 0.0, true, 1.0);
	
	//hook events
	HookEvent("player_hurt", Event_Player_Hurt, EventHookMode_Post);
	HookEvent("player_death", Event_Player_Death, EventHookMode_Pre);
	
	LoadTranslations("l4d_broadcast.phrases");
	// AutoExecConfig(true, CONFIG_FILENAME);
}

public Action Event_Player_Death(Handle event, const char[] name, bool dontBroadcast) 
{
	int attacker_userid = GetEventInt(event, "attacker");
	int attacker = GetClientOfUserId(attacker_userid);
	bool headshot = GetEventBool(event, "headshot");
	
	if (attacker == 0 || GetClientTeam(attacker) == 1)
	{
		return Plugin_Continue;
	}
	
	printkillinfo(attacker, headshot);
	
	return Plugin_Continue;
}

void printkillinfo(int attacker, bool headshot)
{
	int intbroad = GetConVarInt(broadcast);
	int murder;
	
	if ((intbroad >= 1) && headshot)
	{
		murder = kill_counts[attacker][0];
		
		if (murder > 1)
		{
			PrintCenterText(attacker, "%t +%d", "headshot", murder);
			KillTimer(kill_timers[attacker][0]);
		}
		else
		{
			PrintCenterText(attacker, "%t", "headshot");
		}
		
		kill_timers[attacker][0] = CreateTimer(5.0, KillCountTimer, (attacker * 10));
		kill_counts[attacker][0] = murder+1;
	}
	else if (intbroad == 1)
	{
		murder = kill_counts[attacker][1];
		
		if (murder >= 1)
		{
			PrintCenterText(attacker, "%t +%d", "kill", murder);
			KillTimer(kill_timers[attacker][1]);
		}
		else
		{
			PrintCenterText(attacker, "%t", "kill");
		}
		
		kill_timers[attacker][1] = CreateTimer(5.0, KillCountTimer, ((attacker * 10) + 1));
		kill_counts[attacker][1] = murder+1;
	}
}

public Action KillCountTimer(Handle timer, any info) 
{
	int id = info - (info % 10);
	info = info - id;
	id = id / 10;
	
	kill_counts [id] [info] = 0;
	
	return Plugin_Continue;
}

public Action Event_Player_Hurt(Handle event, const char[] name, bool dontBroadcast) 
{	
	int client_userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(client_userid);
	int attacker_userid = GetEventInt(event, "attacker");
	int attacker = GetClientOfUserId(attacker_userid);

	int ff_attack = GetConVarInt(broadcast_attack);
	int ff_victim = GetConVarInt(broadcast_victim);
	int ff_con = GetConVarInt(broadcast_con);
	
	//Kill everything if...
	if (attacker == 0 || client == 0 || GetClientTeam(attacker) != GetClientTeam(client) || (ff_attack == 0 && ff_victim == 0 && ff_con == 0))
	{
		return Plugin_Continue;
	}
	
	int id = kill_counts[attacker][2];
	kill_timers[attacker][2] = CreateTimer(5.0, KillCountTimer, ((attacker * 10) + 2));
	kill_counts[attacker][2] = client;
	
	char hit[32];
	switch (GetEventInt(event, "hitgroup"))
	{
		case 1:
		{
			hit="head";
		}
		case 2:
		{
			hit="chest";
		}
		case 3:
		{
			hit="stomach";
		}
		case 4:
		{
			hit="left_arm";
		}
		case 5:
		{
			hit="right_arm";
		}
		case 6:
		{
			hit="left_leg";
		}
		case 7:
		{
			hit="right_leg";
		}
		default:
		{}
	}
	
	//char buf[128];
	//Format(buf, 128, "%N hit %N%s.", attacker, client, hit);
	//PrintToServer(buf);
	
	if ((ff_attack == 1 || ff_attack == 2) && (id != client))
	{
		PrintHintText(attacker, "You hit %N.", client);
	}
	
	if (ff_attack == 2 || ff_attack == 3)
	{
		PrintToChat(attacker, "You hit %N%t.", client, hit);
	}
	else if (ff_con == 1)
	{
		PrintToConsole(attacker, "You hit %N%t.", client, hit);
	}
	
	// ReplaceString(hit, 32, "'s", "r");
	if (ff_victim == 1)
	{
		PrintToChat(client, "%N hit %t%t.", attacker, "you", hit);
	}
	else if (ff_con == 1)
	{
		PrintToConsole(client, "%N hit %t%t.", attacker, "you", hit);
	}
	
	return Plugin_Continue;
}
