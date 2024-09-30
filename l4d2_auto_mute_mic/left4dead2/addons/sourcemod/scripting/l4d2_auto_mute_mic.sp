#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <basecomm>
#include <sdktools_voice>

ConVar g_cvAutoMuteVoxMic, g_cvAutoMuteEnable, g_cvAutoMuteTime, g_cvAutoUnmuteTime;
int g_clientVox[MAXPLAYERS + 1];
bool g_voxStatus[MAXPLAYERS + 1];
bool g_speakStatus[MAXPLAYERS + 1];
Handle g_speakTimers[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "L4D2 Auto Mute Mic",
	author = "HatsuneImagine",
	description = "Auto mute player microphone voices if constantly speaking for too long.",
	version = "1.2",
	url = "https://github.com/Hatsune-Imagine/l4d2-plugins"
}


public void OnPluginStart() {
	g_cvAutoMuteVoxMic = CreateConVar("l4d2_auto_mute_vox_mic", "1", "Enable auto mute vox-style (always on) mic.\n0=Off\n1=On");
	g_cvAutoMuteEnable = CreateConVar("l4d2_auto_mute_enable", "1", "Enable auto mute long speech mic.\n0=Off\n1=On");
	g_cvAutoMuteTime = CreateConVar("l4d2_auto_mute_time", "15.0", "Auto mute player mic if constantly speaking for these seconds.");
	g_cvAutoUnmuteTime = CreateConVar("l4d2_auto_unmute_time", "5.0", "Auto unmute after these seconds.");
	AutoExecConfig(true, "l4d2_auto_mute_mic");
}

public void OnClientDisconnect(int client) {
	if (IsFakeClient(client)) return;
	g_clientVox[client] = 0;
	g_voxStatus[client] = false;
	g_speakStatus[client] = false;
}

public void OnClientSpeaking(int client) {
	if (!IsValidClient(client)) return;
	if (g_speakStatus[client]) return;
	g_speakStatus[client] = true;
	if (g_cvAutoMuteVoxMic.BoolValue) {
		QueryClientConVar(client, "voice_vox", OnQueryFinished);
		if (g_clientVox[client] != 0) {
			g_voxStatus[client] = true;
			PrintToChat(client, "\x05检测到你是\x03开放式麦克风\x05, 已自动闭麦, 设置为\x03按键通话\x05后可恢复.");
			BaseComm_SetClientMute(client, true);
			return;
		}
		else if (g_voxStatus[client]) {
			g_voxStatus[client] = false;
			PrintToChat(client, "\x05检测到你是\x03按键通话\x05, 已解除闭麦限制.");
			BaseComm_SetClientMute(client, false);
			return;
		}
	}
	if (g_cvAutoMuteEnable.BoolValue) {
		g_speakTimers[client] = CreateTimer(g_cvAutoMuteTime.FloatValue, Timer_DelayMute, client);
	}
}

public void OnClientSpeakingEnd(int client) {
	if (!IsValidClient(client)) return;
	g_speakStatus[client] = false;
	if (g_cvAutoMuteEnable.BoolValue) {
		if (IsValidHandle(g_speakTimers[client])) {
			KillTimer(g_speakTimers[client]);
			g_speakTimers[client] = INVALID_HANDLE;
		}
	}
}

Action Timer_DelayMute(Handle timer, int client) {
	if (!IsValidClient(client)) return Plugin_Continue;
	PrintToChat(client, "\x05已达到\x03 %.1f \x05秒开麦时长限制,\x03 %.1f \x05秒后可再次开麦.", g_cvAutoMuteTime.FloatValue, g_cvAutoUnmuteTime.FloatValue);
	BaseComm_SetClientMute(client, true);
	CreateTimer(g_cvAutoUnmuteTime.FloatValue, Timer_DelayUnmute, client);
	return Plugin_Continue;
}

Action Timer_DelayUnmute(Handle timer, int client) {
	if (!IsValidClient(client)) return Plugin_Continue;
	BaseComm_SetClientMute(client, false);
	return Plugin_Continue;
}

void OnQueryFinished(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue) {
	if (result == ConVarQuery_Okay) {
		g_clientVox[client] = StringToInt(cvarValue);
	}
}

bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}
