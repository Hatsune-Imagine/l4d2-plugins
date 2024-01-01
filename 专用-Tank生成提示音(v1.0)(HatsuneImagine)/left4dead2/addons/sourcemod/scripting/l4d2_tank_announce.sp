#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools_sound>

#define PLUGIN_VERSION "1.0"
#define DANG "ui/pickup_secret01.wav"

public Plugin myinfo = 
{
	name = "L4D2 Tank Announcer",
	author = "HatsuneImagine",
	description = "Play a sound when a Tank has spawned",
	version = PLUGIN_VERSION,
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
};

public void OnPluginStart()
{
	HookEvent("tank_spawn", Event_TankSpawn);
}

public void OnMapStart()
{
	PrecacheSound(DANG);
}

public void Event_TankSpawn(Event event, char[] name, bool dontBroadcast)
{
	EmitSoundToAll(DANG);
}
