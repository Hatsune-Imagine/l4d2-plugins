#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>

#define FLAG_CHAT 1
#define FLAG_HINT_TEXT 2
#define FLAG_CENTER_TEXT 4

ConVar cv_hintCount, cv_hintType;

public Plugin myinfo = 
{
	name        = "L4D2 Left Safearea Hint",
	author      = "HatsuneImagine",
	version     = "1.2",
	description = "Print hint message to all players when leaving starting safearea."
};

public void OnPluginStart()
{
	cv_hintCount = CreateConVar("l4d2_left_safearea_hint_count", "3", "How many hints to display.");
	cv_hintType = CreateConVar("l4d2_left_safearea_hint_type", "2", "Which hint type to display.\n1 = Print to chat.\n2 = Print hint text.\n4 = Print center text.\nYou can add them all together.");
	AutoExecConfig(true, "l4d2_left_safearea_hint");
	LoadTranslations("l4d2_left_safearea_hint.phrases");
}

public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	for (int i = 1; i <= cv_hintCount.IntValue; i++)
	{
		CreateTimer((i - 1) * 10.0, Timer_PrintMsg, i);
	}

	return Plugin_Continue;
}

Action Timer_PrintMsg(Handle timer, any args)
{
	char phrase[64];
	Format(phrase, sizeof(phrase), "Msg%d", args);
	if (TranslationPhraseExists(phrase))
	{
		if (cv_hintType.IntValue & FLAG_CHAT)
			PrintToChatAll("%t", phrase);
		if (cv_hintType.IntValue & FLAG_HINT_TEXT)
			PrintHintTextToAll("%t", phrase);
		if (cv_hintType.IntValue & FLAG_CENTER_TEXT)
			PrintCenterTextAll("%t", phrase);
	}
	return Plugin_Continue;
}
